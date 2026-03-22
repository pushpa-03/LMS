from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import whisper
import requests
import os
import faiss
import pickle
from sentence_transformers import SentenceTransformer
from fastapi.responses import StreamingResponse
import json
import docx
import PyPDF2

BASE_VIDEO_PATH = "../Uploads/Videos"
DATA_PATH = "../AIData"

TRANSCRIPT_PATH = os.path.join(DATA_PATH, "transcripts")
INDEX_PATH = os.path.join(DATA_PATH, "index")

os.makedirs(TRANSCRIPT_PATH, exist_ok=True)
os.makedirs(INDEX_PATH, exist_ok=True)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

print("Loading Whisper...")
whisper_model = whisper.load_model("tiny")  # 🔥 faster

print("Loading embeddings...")
embedder = SentenceTransformer("all-MiniLM-L6-v2")

# ------------------ HELPERS ------------------

def get_video_path(video_name):
    if not video_name.endswith(".mp4"):
        video_name += ".mp4"
    return os.path.join(BASE_VIDEO_PATH, video_name)

def get_txt_path(video_name):
    return os.path.join(TRANSCRIPT_PATH, video_name + ".txt")

def get_index_path(video_name):
    return os.path.join(INDEX_PATH, video_name + ".index")

def get_chunks_path(video_name):
    return os.path.join(INDEX_PATH, video_name + ".pkl")

# ------------------ TRANSCRIBE ONCE ------------------

def transcribe_video(video_name):
    txt_file = get_txt_path(video_name)

    if os.path.exists(txt_file):
        return open(txt_file, "r", encoding="utf8").read()

    video_path = get_video_path(video_name)
    result = whisper_model.transcribe(video_path)
    text = result["text"]

    with open(txt_file, "w", encoding="utf8") as f:
        f.write(text)

    return text

# ------------------ CHUNK ------------------

def chunk_text(text, size=300):
    return [text[i:i+size] for i in range(0, len(text), size)]

# ------------------ BUILD INDEX ONCE ------------------

def build_index(video_name):
    index_file = get_index_path(video_name)
    chunk_file = get_chunks_path(video_name)

    if os.path.exists(index_file):
        index = faiss.read_index(index_file)
        chunks = pickle.load(open(chunk_file, "rb"))
        return index, chunks

    text = transcribe_video(video_name)
    chunks = chunk_text(text)

    embeddings = embedder.encode(chunks)
    dim = len(embeddings[0])

    index = faiss.IndexFlatL2(dim)
    index.add(embeddings)

    faiss.write_index(index, index_file)
    pickle.dump(chunks, open(chunk_file, "wb"))

    return index, chunks

# ------------------ SEARCH ------------------

def search_context(video_name, question):
    index, chunks = build_index(video_name)

    q_emb = embedder.encode([question])
    D, I = index.search(q_emb, 3)

    context = "\n".join([chunks[i] for i in I[0]])
    return context

# ------------------ FAST LLM ------------------

def stream_llm(prompt):
    def generate():
        response = requests.post(
            "http://localhost:11434/api/generate",
            json={
                "model": "phi3",
                "prompt": prompt,
                "stream": True
            },
            stream=True
        )

        for line in response.iter_lines():
            if line:
                data = json.loads(line.decode("utf-8"))
                token = data.get("response", "")
                yield token

    return generate()

# ------------------Material-------------------
BASE_MATERIAL_PATH = "../Uploads/Materials"

def get_material_path(file_path):
    return os.path.join("..", file_path.strip("/"))


def extract_text(file_path):
    text = ""

    if file_path.endswith(".pdf"):
        reader = PyPDF2.PdfReader(file_path)
        for page in reader.pages:
            text += page.extract_text() or ""

    elif file_path.endswith(".docx"):
        doc = docx.Document(file_path)
        for p in doc.paragraphs:
            text += p.text

    else:
        text = "This is a study material file."

    return text[:2000]  # 🔥 speed

def get_full_response(prompt):
    response = requests.post(
        "http://localhost:11434/api/generate",
        json={
            "model": "phi3",
            "prompt": prompt,
            "stream": False
        }
    )
    return response.json()["response"]

# ------------------ APIs ------------------

#-----------For video--------
@app.post("/generate-summary")
async def generate_summary(video_name: str):
    text = transcribe_video(video_name)
    short_text = text[:2000]  # 🔥 limit size

    prompt = f"Summarize:\n{short_text}"

    return {"summary": stream_llm(prompt)}

@app.post("/generate-quiz")
async def generate_quiz(video_name: str):
    text = transcribe_video(video_name)
    short_text = text[:2000]

    prompt = f"Create 5 MCQ:\n{short_text}"

    return {"quiz": stream_llm(prompt)}

@app.post("/generate-notes")
async def generate_notes(video_name: str):
    text = transcribe_video(video_name)
    short_text = text[:2000]

    prompt = f"Make notes:\n{short_text}"

    return {"notes": stream_llm(prompt)}

@app.post("/ask-ai")
def ask_ai(video_name: str, question: str):
    context = search_context(video_name, question)[:800]

    prompt = f"""
    Context: {context}
    Question: {question}
    Answer shortly:
    """

    return StreamingResponse(
        stream_llm(prompt),
        media_type="text/plain"
    )

#--------For material------------

@app.post("/material-quiz")
def material_quiz(data: dict):
    try:
        # Use .get() to avoid KeyErrors
        file_path = data.get("file_path")
        path = get_material_path(file_path)
        
        text = extract_text(path)
        prompt = f"Generate 5 MCQ questions with answers based on this text:\n\n{text}"
        
        # Use stream=False for the full response at once
        response_text = get_full_response(prompt)
        return {"result": response_text}
    except Exception as e:
        return {"error": str(e)}

@app.post("/material-notes")
def material_notes(data: dict):
    try:
        path = get_material_path(data.get("file_path"))
        text = extract_text(path)
        prompt = f"Generate short notes in bullet points:\n\n{text}"
        return get_full_response(prompt)
    except Exception as e:
        return f"Error: {str(e)}"

@app.post("/material-ask")
def material_ask(data: dict):
    try:
        path = get_material_path(data.get("file_path"))
        question = data.get("question")
        text = extract_text(path)
        prompt = f"Answer in simple points:\n\nContext: {text[:1500]}\nQuestion: {question}"
        return get_full_response(prompt)
    except Exception as e:
        return f"Error: {str(e)}"

