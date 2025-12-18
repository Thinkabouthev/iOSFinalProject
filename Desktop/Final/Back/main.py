# main.py
import os
import json
from typing import List

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from openai import OpenAI
from dotenv import load_dotenv
load_dotenv()

app = FastAPI()

# (не обязательно для simulator, но норм практика)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# OPENAI_API_KEY должен быть в .env или в переменных окружения
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


class EpisodeNotesRequest(BaseModel):
    showName: str
    season: int
    episode: int
    episodeName: str = ""
    overview: str = ""
    userNotes: str = ""


class EpisodeNotesResponse(BaseModel):
    summary: str
    key_points: List[str]
    questions: List[str]


@app.get("/health")
def health():
    return {"ok": True}


@app.post("/ai/episode_notes", response_model=EpisodeNotesResponse)
def ai_episode_notes(req: EpisodeNotesRequest):
    if not os.getenv("OPENAI_API_KEY"):
        raise HTTPException(status_code=500, detail="OPENAI_API_KEY is missing")

    system = (
        "You are a helpful assistant for TV episode notes. "
        "Return ONLY valid JSON with keys: summary (string), key_points (array of strings), questions (array of strings)."
    )

    user = f"""
Show: {req.showName}
Season: {req.season}
Episode: {req.episode}
Episode name: {req.episodeName}
Overview: {req.overview}
User notes: {req.userNotes}

Generate a short summary + key points + questions.
Return ONLY JSON.
"""

    try:
        # максимально совместимый вариант (Chat Completions)
        resp = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": system},
                {"role": "user", "content": user},
            ],
            temperature=0.3,
        )
        text = resp.choices[0].message.content or ""

        # пробуем распарсить JSON
        try:
            data = json.loads(text)
        except Exception:
            # если модель случайно вернула не чистый JSON — не падаем
            return EpisodeNotesResponse(summary=text, key_points=[], questions=[])

        return EpisodeNotesResponse(
            summary=str(data.get("summary", "")),
            key_points=list(data.get("key_points", [])),
            questions=list(data.get("questions", [])),
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))