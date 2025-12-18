iOS Final Project — TV Tracker (TMDB + Notes + AI Summary)

Overview

This is an iOS app for tracking TV shows:
	•	Search TV shows from TMDB
	•	Add shows to your personal library
	•	Open show details → browse seasons/episodes
	•	Open episode screen → write notes, mark watched, and generate AI summary + key points + questions

The app demonstrates the core course requirements: UI components, Storyboards + AutoLayout, lists with custom cells, multi-module structure (Tab Bar + Navigation), networking, and local data storage. ￼


Tech stack

iOS (Frontend)
	•	UIKit
	•	Storyboards + Auto Layout (constraints set for adaptive UI) ￼
	•	UITableView / custom cells for lists ￼
	•	URLSession networking ￼
	•	Kingfisher (image loading & caching) ￼
	•	UserDefaults (watched + notes persistence) ￼

Backend (AI)
	•	FastAPI
	•	OpenAI API (AI summary endpoint)


Features
	•	Library tab: your saved shows
	•	Search/Add: search TMDB and add shows
	•	Show Details: seasons + episodes list
	•	Episode Details:
	•	Notes (local save)
	•	Watched toggle (local save)
	•	AI Summary (calls backend /ai/episode_notes)


Recommended extras included: error handling + user feedback, loading states (where implemented). ￼
Setup

1) Frontend (iOS)

Requirements
	•	Xcode (latest)
	•	iOS Simulator / device

Install dependencies
	•	If you use Swift Package Manager:
Xcode → File → Add Packages… → add Kingfisher.

Secrets (IMPORTANT — don’t commit)
Create a file like Secrets.swift (or .xcconfig) locally:
enum Secrets {
    static let tmdbApiKey = "YOUR_TMDB_API_KEY"
    static let backendBaseURL = "http://127.0.0.1:8000" // local backend
}
TMDB images load via Kingfisher; API requests use URLSession.

Run:
	1.	Open the .xcodeproj
	2.	Select a simulator
	3.	Run

2) Backend (FastAPI)

Requirements
	•	Python 3.10+ recommended (3.13 works but can be picky with some packages)
	•	pip

Install
cd Back
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
Environment variable
export OPENAI_API_KEY="YOUR_OPENAI_KEY"
Run
uvicorn main:app --reload --port 8000
Endpoint used by iOS
	•	POST /ai/episode_notes

⸻

How to use (quick)
	1.	Open app → Search show → Add to Library
	2.	Tap a show → Show Details (episodes list)
	3.	Tap an episode → Episode Details
	4.	Write notes → mark watched → press “Generate summary”
Credits
	•	Data: TMDB API
	•	Image loading: Kingfisher 
