# from fastapi import FastAPI
# from fastapi.middleware.cors import CORSMiddleware
# import whisper
# import requests
# import os
# import faiss
# import pickle
# from sentence_transformers import SentenceTransformer
# from fastapi.responses import StreamingResponse
# import json
# import docx
# import PyPDF2

# BASE_VIDEO_PATH = "../Uploads/Videos"
# DATA_PATH = "../AIData"

# TRANSCRIPT_PATH = os.path.join(DATA_PATH, "transcripts")
# INDEX_PATH = os.path.join(DATA_PATH, "index")

# os.makedirs(TRANSCRIPT_PATH, exist_ok=True)
# os.makedirs(INDEX_PATH, exist_ok=True)

# app = FastAPI()

# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# print("Loading Whisper...")
# whisper_model = whisper.load_model("tiny")  # 🔥 faster

# print("Loading embeddings...")
# embedder = SentenceTransformer("all-MiniLM-L6-v2")

# # ------------------ HELPERS ------------------

# def get_video_path(video_name):
#     if not video_name.endswith(".mp4"):
#         video_name += ".mp4"
#     return os.path.join(BASE_VIDEO_PATH, video_name)

# def get_txt_path(video_name):
#     return os.path.join(TRANSCRIPT_PATH, video_name + ".txt")

# def get_index_path(video_name):
#     return os.path.join(INDEX_PATH, video_name + ".index")

# def get_chunks_path(video_name):
#     return os.path.join(INDEX_PATH, video_name + ".pkl")

# # ------------------ TRANSCRIBE ONCE ------------------

# def transcribe_video(video_name):
#     txt_file = get_txt_path(video_name)

#     if os.path.exists(txt_file):
#         return open(txt_file, "r", encoding="utf8").read()

#     video_path = get_video_path(video_name)
#     result = whisper_model.transcribe(video_path)
#     text = result["text"]

#     with open(txt_file, "w", encoding="utf8") as f:
#         f.write(text)

#     return text

# # ------------------ CHUNK ------------------

# def chunk_text(text, size=300):
#     return [text[i:i+size] for i in range(0, len(text), size)]

# # ------------------ BUILD INDEX ONCE ------------------

# def build_index(video_name):
#     index_file = get_index_path(video_name)
#     chunk_file = get_chunks_path(video_name)

#     if os.path.exists(index_file):
#         index = faiss.read_index(index_file)
#         chunks = pickle.load(open(chunk_file, "rb"))
#         return index, chunks

#     text = transcribe_video(video_name)
#     chunks = chunk_text(text)

#     embeddings = embedder.encode(chunks)
#     dim = len(embeddings[0])

#     index = faiss.IndexFlatL2(dim)
#     index.add(embeddings)

#     faiss.write_index(index, index_file)
#     pickle.dump(chunks, open(chunk_file, "wb"))

#     return index, chunks

# # ------------------ SEARCH ------------------

# def search_context(video_name, question):
#     index, chunks = build_index(video_name)

#     q_emb = embedder.encode([question])
#     D, I = index.search(q_emb, 3)

#     context = "\n".join([chunks[i] for i in I[0]])
#     return context

# # ------------------ FAST LLM ------------------

# def stream_llm(prompt):
#     def generate():
#         response = requests.post(
#             "http://localhost:11434/api/generate",
#             json={
#                 "model": "phi3",
#                 "prompt": prompt,
#                 "stream": True
#             },
#             stream=True
#         )

#         for line in response.iter_lines():
#             if line:
#                 data = json.loads(line.decode("utf-8"))
#                 token = data.get("response", "")
#                 yield token

#     return generate()

# # ------------------Material-------------------
# BASE_MATERIAL_PATH = "../Uploads/Materials"

# def get_material_path(file_path):
#     return os.path.join("..", file_path.strip("/"))


# def extract_text(file_path):
#     text = ""

#     if file_path.endswith(".pdf"):
#         reader = PyPDF2.PdfReader(file_path)
#         for page in reader.pages:
#             text += page.extract_text() or ""

#     elif file_path.endswith(".docx"):
#         doc = docx.Document(file_path)
#         for p in doc.paragraphs:
#             text += p.text

#     else:
#         text = "This is a study material file."

#     return text[:2000]  # 🔥 speed

# def get_full_response(prompt):
#     response = requests.post(
#         "http://localhost:11434/api/generate",
#         json={
#             "model": "phi3",
#             "prompt": prompt,
#             "stream": False
#         }
#     )
#     return response.json()["response"]

# # ------------------ APIs ------------------

# #-----------For video--------
# @app.post("/generate-summary")
# async def generate_summary(video_name: str):
#     text = transcribe_video(video_name)
#     short_text = text[:2000]  # 🔥 limit size

#     prompt = f"Summarize:\n{short_text}"

#     return {"summary": stream_llm(prompt)}

# @app.post("/generate-quiz")
# async def generate_quiz(video_name: str):
#     text = transcribe_video(video_name)
#     short_text = text[:2000]

#     prompt = f"Create 5 MCQ:\n{short_text}"

#     return {"quiz": stream_llm(prompt)}

# @app.post("/generate-notes")
# async def generate_notes(video_name: str):
#     text = transcribe_video(video_name)
#     short_text = text[:2000]

#     prompt = f"Make notes:\n{short_text}"

#     return {"notes": stream_llm(prompt)}

# @app.post("/ask-ai")
# def ask_ai(video_name: str, question: str):
#     context = search_context(video_name, question)[:800]

#     prompt = f"""
#     Context: {context}
#     Question: {question}
#     Answer shortly:
#     """

#     return StreamingResponse(
#         stream_llm(prompt),
#         media_type="text/plain"
#     )

# #--------For material------------

# @app.post("/material-quiz")
# def material_quiz(data: dict):
#     try:
#         # Use .get() to avoid KeyErrors
#         file_path = data.get("file_path")
#         path = get_material_path(file_path)
        
#         text = extract_text(path)
#         prompt = f"Generate 5 MCQ questions with answers based on this text:\n\n{text}"
        
#         # Use stream=False for the full response at once
#         response_text = get_full_response(prompt)
#         return {"result": response_text}
#     except Exception as e:
#         return {"error": str(e)}

# @app.post("/material-notes")
# def material_notes(data: dict):
#     try:
#         path = get_material_path(data.get("file_path"))
#         text = extract_text(path)
#         prompt = f"Generate short notes in bullet points:\n\n{text}"
#         return get_full_response(prompt)
#     except Exception as e:
#         return f"Error: {str(e)}"

# @app.post("/material-ask")
# def material_ask(data: dict):
#     try:
#         path = get_material_path(data.get("file_path"))
#         question = data.get("question")
#         text = extract_text(path)
#         prompt = f"Answer in simple points:\n\nContext: {text[:1500]}\nQuestion: {question}"
#         return get_full_response(prompt)
#     except Exception as e:
#         return f"Error: {str(e)}"



#-----------------------------------------------------------------------------------------------------------------------------------------------------

"""
LMS AI Server — FastAPI  v3.0
Run:  uvicorn ai_server:app --reload --port 8000

pip install fastapi uvicorn openai-whisper requests faiss-cpu
        sentence-transformers python-docx PyPDF2 numpy scipy torch
        python-pptx openpyxl
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from typing import Optional
import os, json, re, pickle
import requests
import faiss
import docx
import PyPDF2

# ── Paths ──────────────────────────────────────────────────────────────────────
BASE_VIDEO_PATH = "../Uploads/Videos"
DATA_PATH       = "../AIData"
TRANSCRIPT_PATH = os.path.join(DATA_PATH, "transcripts")
INDEX_PATH      = os.path.join(DATA_PATH, "index")
os.makedirs(TRANSCRIPT_PATH, exist_ok=True)
os.makedirs(INDEX_PATH,      exist_ok=True)

# ── App ────────────────────────────────────────────────────────────────────────
app = FastAPI(title="LMS AI Server", version="3.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], allow_credentials=True,
    allow_methods=["*"], allow_headers=["*"],
)

# ── Lazy model loading (saves startup time) ────────────────────────────────────
_whisper  = None
_embedder = None

def get_whisper():
    global _whisper
    if _whisper is None:
        import whisper
        print("Loading Whisper tiny …")
        _whisper = whisper.load_model("tiny")
    return _whisper

def get_embedder():
    global _embedder
    if _embedder is None:
        from sentence_transformers import SentenceTransformer
        print("Loading sentence-transformer …")
        _embedder = SentenceTransformer("all-MiniLM-L6-v2")
    return _embedder

# ── Ollama ─────────────────────────────────────────────────────────────────────
OLLAMA_URL   = "http://localhost:11434/api/generate"
OLLAMA_MODEL = "phi3"          # change to qwen2.5:0.5b for lighter

def llm_full(prompt: str) -> str:
    """Single blocking call — returns full text."""
    try:
        r = requests.post(OLLAMA_URL,
            json={"model": OLLAMA_MODEL, "prompt": prompt, "stream": False},
            timeout=180)
        return r.json().get("response", "")
    except Exception as e:
        return f"LLM error: {e}"

def llm_stream(prompt: str):
    """Generator that yields tokens for StreamingResponse."""
    def _gen():
        try:
            r = requests.post(OLLAMA_URL,
                json={"model": OLLAMA_MODEL, "prompt": prompt, "stream": True},
                stream=True, timeout=180)
            for line in r.iter_lines():
                if line:
                    d = json.loads(line.decode())
                    yield d.get("response", "")
        except Exception as e:
            yield f"\n[Error: {e}]"
    return _gen()

# ── Request models ─────────────────────────────────────────────────────────────
class VideoReq(BaseModel):
    video_name: str

class MaterialReq(BaseModel):
    file_path: str

class MaterialAskReq(BaseModel):
    file_path: str
    question: str

class AskReq(BaseModel):
    video_name: str
    question: str

# ─────────────────────────────────────────────────────────────────────────────
#  VIDEO HELPERS
# ─────────────────────────────────────────────────────────────────────────────
def _safe_name(name: str) -> str:
    return re.sub(r'[^\w\-.]', '_', name)

def _video_path(name: str) -> str:
    n = name if name.endswith(".mp4") else name + ".mp4"
    return os.path.join(BASE_VIDEO_PATH, n)

def _txt_path(name: str)   -> str: return os.path.join(TRANSCRIPT_PATH, _safe_name(name) + ".txt")
def _idx_path(name: str)   -> str: return os.path.join(INDEX_PATH, _safe_name(name) + ".index")
def _chunks_path(name: str)-> str: return os.path.join(INDEX_PATH, _safe_name(name) + ".pkl")

def transcribe(name: str) -> str:
    txt = _txt_path(name)
    if os.path.exists(txt):
        return open(txt, encoding="utf-8").read()
    vp = _video_path(name)
    if not os.path.exists(vp):
        # try without subdir — maybe path already contains folder
        vp2 = os.path.join("..", name) if not os.path.isabs(name) else name
        if not os.path.exists(vp2):
            return f"[Video file not found: {vp}]"
        vp = vp2
    result = get_whisper().transcribe(vp)
    text   = result["text"]
    with open(txt, "w", encoding="utf-8") as f:
        f.write(text)
    return text

def build_index(name: str):
    idx_f   = _idx_path(name)
    chk_f   = _chunks_path(name)
    if os.path.exists(idx_f) and os.path.exists(chk_f):
        return faiss.read_index(idx_f), pickle.load(open(chk_f, "rb"))
    text   = transcribe(name)
    chunks = [text[i:i+400] for i in range(0, len(text), 400)] or ["No content"]
    emb    = get_embedder().encode(chunks)
    idx    = faiss.IndexFlatL2(len(emb[0]))
    idx.add(emb)
    faiss.write_index(idx, idx_f)
    pickle.dump(chunks, open(chk_f, "wb"))
    return idx, chunks

def search_ctx(name: str, question: str, k: int = 3) -> str:
    idx, chunks = build_index(name)
    q_emb = get_embedder().encode([question])
    _, I  = idx.search(q_emb, k)
    return "\n".join(chunks[i] for i in I[0] if i < len(chunks))

# ─────────────────────────────────────────────────────────────────────────────
#  MATERIAL HELPERS
# ─────────────────────────────────────────────────────────────────────────────
def resolve_mat(path: str) -> str:
    """Try several locations to find the material file."""
    candidates = [
        path,
        os.path.join("..", path.lstrip("/\\")),
        os.path.join("..", path.lstrip("/\\").replace("/", os.sep)),
    ]
    for c in candidates:
        if os.path.exists(c):
            return c
    return candidates[1]   # return best guess even if missing

def extract_mat_text(path: str, max_chars: int = 3000) -> str:
    if not os.path.exists(path):
        return f"[File not found: {path}]"
    ext  = os.path.splitext(path)[1].lower()
    text = ""
    try:
        if ext == ".pdf":
            rdr = PyPDF2.PdfReader(path)
            for pg in rdr.pages:
                text += pg.extract_text() or ""
        elif ext == ".docx":
            doc  = docx.Document(path)
            text = "\n".join(p.text for p in doc.paragraphs)
        elif ext in (".txt", ".md", ".csv"):
            text = open(path, encoding="utf-8", errors="ignore").read()
        elif ext in (".ppt", ".pptx"):
            try:
                from pptx import Presentation
                prs  = Presentation(path)
                for sl in prs.slides:
                    for sh in sl.shapes:
                        if hasattr(sh, "text"):
                            text += sh.text + "\n"
            except ImportError:
                text = "python-pptx not installed."
        elif ext in (".xls", ".xlsx"):
            try:
                import openpyxl
                wb = openpyxl.load_workbook(path, read_only=True, data_only=True)
                for ws in wb.worksheets:
                    for row in ws.iter_rows(values_only=True):
                        text += " | ".join(str(c) for c in row if c is not None) + "\n"
            except ImportError:
                text = "openpyxl not installed."
        else:
            text = "Unsupported file type for text extraction."
    except Exception as ex:
        text = f"Error reading file: {ex}"
    return text[:max_chars]

# ─────────────────────────────────────────────────────────────────────────────
#  VIDEO AI ENDPOINTS
# ─────────────────────────────────────────────────────────────────────────────

@app.post("/generate-summary")
def gen_summary(req: VideoReq):
    text   = transcribe(req.video_name)[:2500]
    prompt = (
        "You are an educational AI. Summarize the following lecture transcript "
        "in clear, student-friendly bullet points:\n\n"
        f"Transcript:\n{text}\n\nSummary:"
    )
    return {"result": llm_full(prompt)}

@app.post("/generate-notes")
def gen_notes(req: VideoReq):
    text   = transcribe(req.video_name)[:2500]
    prompt = (
        "You are an educational AI. Create well-structured study notes with "
        "headings, bullet points and key definitions from this lecture:\n\n"
        f"Transcript:\n{text}\n\nStudy Notes:"
    )
    return {"result": llm_full(prompt)}

@app.post("/generate-quiz")
def gen_quiz(req: VideoReq):
    text   = transcribe(req.video_name)[:2500]
    prompt = (
        "You are an educational AI. Create 5 multiple-choice questions from this lecture.\n"
        "Format: Q1. [question]\nA) B) C) D)\nAnswer: [letter]\n\n"
        f"Transcript:\n{text}\n\nQuiz:"
    )
    return {"result": llm_full(prompt)}

@app.post("/generate-mindmap")
def gen_mindmap(req: VideoReq):
    text   = transcribe(req.video_name)[:2500]
    prompt = (
        "You are an educational AI. Create a detailed hierarchical mind map "
        "using indented tree format. Use ├─ └─ │ characters.\n"
        "Start with the main topic, branch into subtopics, then details.\n\n"
        f"Transcript:\n{text}\n\nMind Map:"
    )
    return {"result": llm_full(prompt)}

@app.get("/ask-ai")
@app.post("/ask-ai")
def ask_ai(video_name: str = "", question: str = "", req: Optional[AskReq] = None):
    vn = (req.video_name if req else None) or video_name
    q  = (req.question   if req else None) or question
    if not vn or not q:
        return StreamingResponse(iter(["Provide video_name and question."]),
                                 media_type="text/plain")
    ctx    = search_ctx(vn, q)[:1200]
    prompt = (
        f"You are a helpful educational assistant. Answer the student's question "
        f"using the lecture transcript context below.\n\n"
        f"Context:\n{ctx}\n\nQuestion: {q}\n\nAnswer clearly:"
    )
    return StreamingResponse(llm_stream(prompt), media_type="text/plain")

# ─────────────────────────────────────────────────────────────────────────────
#  MATERIAL AI ENDPOINTS
# ─────────────────────────────────────────────────────────────────────────────

@app.post("/material-summary")
def mat_summary(req: MaterialReq):
    path = resolve_mat(req.file_path)
    text = extract_mat_text(path)
    prompt = f"Summarize this study material in clear bullet points for a student:\n\n{text}\n\nSummary:"
    return {"result": llm_full(prompt)}

@app.post("/material-notes")
def mat_notes(req: MaterialReq):
    path = resolve_mat(req.file_path)
    text = extract_mat_text(path)
    prompt = f"Create structured study notes with headings and bullet points:\n\n{text}\n\nNotes:"
    return {"result": llm_full(prompt)}

@app.post("/material-quiz")
def mat_quiz(req: MaterialReq):
    path = resolve_mat(req.file_path)
    text = extract_mat_text(path)
    prompt = (
        "Create 5 multiple-choice questions from this study material.\n"
        "Format: Q1. [question]\nA) B) C) D)\nAnswer: [letter]\n\n"
        f"Material:\n{text}\n\nQuiz:"
    )
    return {"result": llm_full(prompt)}

@app.post("/material-mindmap")
def mat_mindmap(req: MaterialReq):
    path = resolve_mat(req.file_path)
    text = extract_mat_text(path)
    prompt = (
        "Create a hierarchical mind map with ├─ └─ tree format from this study material:\n\n"
        f"{text}\n\nMind Map:"
    )
    return {"result": llm_full(prompt)}

@app.post("/material-ask")
def mat_ask(req: MaterialAskReq):
    path = resolve_mat(req.file_path)
    text = extract_mat_text(path, max_chars=2000)
    prompt = f"Answer this question based on the study material:\n\nMaterial: {text}\n\nQuestion: {req.question}\n\nAnswer:"
    return {"result": llm_full(prompt)}

# ─────────────────────────────────────────────────────────────────────────────
#  HEALTH
# ─────────────────────────────────────────────────────────────────────────────
@app.get("/health")
def health():
    return {"status": "ok", "model": OLLAMA_MODEL}