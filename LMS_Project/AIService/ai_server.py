from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import whisper
import requests
import os
import faiss
from sentence_transformers import SentenceTransformer

BASE_VIDEO_PATH = "../Uploads/Videos"
TRANSCRIPT_PATH = "../AIData/transcripts"

os.makedirs(TRANSCRIPT_PATH, exist_ok=True)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

print("Loading Whisper...")
whisper_model = whisper.load_model("base")

print("Loading embedding model...")
embedder = SentenceTransformer("all-MiniLM-L6-v2")

vector_store = {}
text_store = {}

def transcribe_video(video_name):

    txt_file = os.path.join(
        TRANSCRIPT_PATH,
        video_name.replace(".mp4", ".txt")
    )

    if os.path.exists(txt_file):
        with open(txt_file, "r", encoding="utf8") as f:
            return f.read()

    video_path = os.path.join(BASE_VIDEO_PATH, video_name)

    result = whisper_model.transcribe(video_path)

    transcript = result["text"]

    with open(txt_file, "w", encoding="utf8") as f:
        f.write(transcript)

    return transcript

def chunk_text(text):

    size = 500
    chunks = []

    for i in range(0, len(text), size):
        chunks.append(text[i:i+size])

    return chunks

def build_index(video_name, text):

    chunks = chunk_text(text)

    embeddings = embedder.encode(chunks)

    dim = len(embeddings[0])

    index = faiss.IndexFlatL2(dim)

    index.add(embeddings)

    vector_store[video_name] = index
    text_store[video_name] = chunks

def search_context(video_name, question):

    index = vector_store.get(video_name)

    if index is None:
        transcript = transcribe_video(video_name)
        build_index(video_name, transcript)
        index = vector_store[video_name]

    q_emb = embedder.encode([question])

    D, I = index.search(q_emb, 3)

    chunks = text_store[video_name]

    context = ""

    for i in I[0]:
        context += chunks[i] + "\n"

    return context

def ask_llm(prompt):

    response = requests.post(
        "http://localhost:11434/api/generate",
        json={
            "model": "llama3",
            "prompt": prompt,
            "stream": False
        }
    )

    return response.json()["response"]

@app.post("/generate-summary")
async def generate_summary(video_name: str):

    transcript = transcribe_video(video_name)

    prompt = f"""
Summarize this lecture clearly.

{transcript}
"""

    summary = ask_llm(prompt)

    return {"summary": summary}

@app.post("/generate-quiz")
async def generate_quiz(video_name: str):

    transcript = transcribe_video(video_name)

    prompt = f"""
Create 5 MCQ questions from this lecture.

{transcript}
"""

    quiz = ask_llm(prompt)

    return {"quiz": quiz}

@app.post("/generate-notes")
async def generate_notes(video_name: str):

    transcript = transcribe_video(video_name)

    prompt = f"""
Convert this lecture into structured study notes.

{transcript}
"""

    notes = ask_llm(prompt)

    return {"notes": notes}

@app.post("/ask-ai")
async def ask_ai(video_name: str, question: str):

    context = search_context(video_name, question)

    prompt = f"""
Lecture context:

{context}

Student question:
{question}

Answer clearly.
"""

    answer = ask_llm(prompt)

    return {"answer": answer}


