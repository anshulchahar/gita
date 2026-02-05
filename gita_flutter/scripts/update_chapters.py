#!/usr/bin/env python3
"""Update chapters collection with unit names."""

import json
import os
import requests

PROJECT_ID = "gita-58861"
CONFIG_PATH = os.path.expanduser('~/.config/configstore/firebase-tools.json')
FIRESTORE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"
TOKEN_URL = "https://oauth2.googleapis.com/token"
CLIENT_ID = "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com"
CLIENT_SECRET = "ssVPMULxI8rXlS115U8a42qS"

def get_access_token():
    with open(CONFIG_PATH, 'r') as f:
        config = json.load(f)
    tokens = config.get('tokens', {}) or config.get('user', {}).get('tokens', {})
    refresh_token = tokens.get('refresh_token')
    data = {
        'client_id': CLIENT_ID,
        'client_secret': CLIENT_SECRET,
        'refresh_token': refresh_token,
        'grant_type': 'refresh_token'
    }
    response = requests.post(TOKEN_URL, data=data)
    return response.json()['access_token']

def to_firestore_value(value):
    if isinstance(value, bool):
        return {"booleanValue": value}
    elif isinstance(value, str):
        return {"stringValue": value}
    elif isinstance(value, int):
        return {"integerValue": str(value)}
    elif isinstance(value, list):
        return {"arrayValue": {"values": [to_firestore_value(v) for v in value]}}
    elif value is None:
        return {"nullValue": None}
    return {"stringValue": str(value)}

def update_chapter(token, doc_id, data):
    url = f"{FIRESTORE_URL}/chapters/{doc_id}"
    headers = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}
    fields = {k: to_firestore_value(v) for k, v in data.items()}
    response = requests.patch(url, headers=headers, json={"fields": fields})
    if response.status_code == 200:
        print(f"✅ Updated chapters/{doc_id}")
    else:
        print(f"❌ Error: {response.text[:200]}")

def main():
    token = get_access_token()
    print("Updating chapters with unit names...")

    # Update Chapter 1 with Unit 1 data
    update_chapter(token, "chapter_1", {
        "chapterNumber": 1,
        "chapterName": "भीतर का युद्धक्षेत्र",
        "chapterNameEn": "The Battlefield Within",
        "description": "कठिन निर्णयों का सामना करना",
        "descriptionEn": "Facing Life's Dilemmas - Explore Arjuna's crisis",
        "shlokaCount": 47,
        "order": 1,
        "isUnlocked": True,
        "icon": "🏹",
        "color": "#FF9933"
    })

    # Update Chapter 2 with Unit 2 data  
    update_chapter(token, "chapter_2", {
        "chapterNumber": 2,
        "chapterName": "शाश्वत आत्मा",
        "chapterNameEn": "The Eternal You",
        "description": "आत्मा और ज्ञान",
        "descriptionEn": "Soul & Wisdom - Discover your immortal soul",
        "shlokaCount": 72,
        "order": 2,
        "isUnlocked": True,
        "icon": "🧘",
        "color": "#4A148C"
    })

    print("Done!")

if __name__ == "__main__":
    main()
