import json
import os
import requests

# Configuration
PROJECT_ID = "gita-58861"
CONFIG_PATH = os.path.expanduser('~/.config/configstore/firebase-tools.json')
FIRESTORE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"
TOKEN_URL = "https://oauth2.googleapis.com/token"
CLIENT_ID = "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com"
CLIENT_SECRET = "ssVPMULxI8rXlS115U8a42qS"

import datetime
import time

# ... constants ...

def get_access_token():
    try:
        with open(CONFIG_PATH, 'r') as f:
            config = json.load(f)
    except Exception as e:
        print(f"Error reading config: {e}")
        exit(1)
    
    tokens = config.get('tokens', {})
    if not tokens:
        tokens = config.get('user', {}).get('tokens', {})

    # Check for valid access token
    access_token = tokens.get('access_token')
    expires_at = tokens.get('expires_at') # Check format (ms or s)
    
    # Simple check: if expires_at is in future
    if access_token and expires_at:
        # Assuming expires_at is milliseconds timestamp (common in JS/Firebase)
        # Verify if it's ms or s? usually ms.
        now_ms = time.time() * 1000
        if int(expires_at) > now_ms + 60000: # Buffer 1 min
            print("Using cached access_token")
            return access_token
        else:
            print(f"Cached token expired. Expires at: {expires_at}, Now: {now_ms}")

    refresh_token = tokens.get('refresh_token')
    if not refresh_token:
        print("Error: Could not find refresh token in firebase-tools.json")
        exit(1)
        
    data = {
        'client_id': CLIENT_ID,
        'client_secret': CLIENT_SECRET,
        'refresh_token': refresh_token,
        'grant_type': 'refresh_token'
    }
    
    print("Attempting to refresh token...")
    response = requests.post(TOKEN_URL, data=data)
    if response.status_code != 200:
        print(f"Error refreshing token: {response.text}")
        exit(1)
        
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

def create_document(access_token, collection, doc_id, data):
    url = f"{FIRESTORE_URL}/{collection}/{doc_id}"
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json'
    }
    
    fields = {k: to_firestore_value(v) for k, v in data.items()}
    payload = {"fields": fields}
    
    # Use PATCH to upsert
    response = requests.patch(url, headers=headers, json=payload)
    
    if response.status_code != 200:
        print(f"Error writing {collection}/{doc_id}: {response.text}")
    else:
        print(f"Successfully wrote {collection}/{doc_id}")

chapters = [
    {
        "id": "chapter_1",
        "data": {
            "chapterNumber": 1,
            "chapterName": "अर्जुन विषाद योग",
            "chapterNameEn": "Arjuna Vishada Yoga",
            "description": "अर्जुन का विषाद",
            "descriptionEn": "The Yoga of Arjuna's Dejection",
            "shlokaCount": 47,
            "order": 1,
            "isUnlocked": True,
            "icon": "🏹",
            "color": "#FF9933"
        }
    },
    {
        "id": "chapter_2",
        "data": {
            "chapterNumber": 2,
            "chapterName": "सांख्य योग",
            "chapterNameEn": "Sankhya Yoga",
            "description": "ज्ञान योग",
            "descriptionEn": "The Yoga of Knowledge",
            "shlokaCount": 72,
            "order": 2,
            "isUnlocked": False,
            "icon": "🧘",
            "color": "#4A148C"
        }
    },
    {
        "id": "chapter_3",
        "data": {
            "chapterNumber": 3,
            "chapterName": "कर्म योग",
            "chapterNameEn": "Karma Yoga",
            "description": "कर्म का योग",
            "descriptionEn": "The Yoga of Action",
            "shlokaCount": 43,
            "order": 3,
            "isUnlocked": False,
            "icon": "⚡",
            "color": "#FF6F00"
        }
    }
]

lessons = [
    # Chapter 1 Lessons
    {
        "id": "lesson_1_1",
        "data": {
            "chapterId": "chapter_1",
            "lessonNumber": 1,
            "lessonName": "अर्जुन की दुविधा",
            "lessonNameEn": "Arjuna's Dilemma",
            "order": 1,
            "estimatedTime": 300,
            "difficulty": "beginner",
            "shlokasCovered": [1, 2, 3],
            "xpReward": 50,
            "prerequisite": None
        }
    },
    {
        "id": "lesson_1_2",
        "data": {
            "chapterId": "chapter_1",
            "lessonNumber": 2,
            "lessonName": "कर्तव्य का स्वरूप",
            "lessonNameEn": "The Nature of Duty",
            "order": 2,
            "estimatedTime": 300,
            "difficulty": "beginner",
            "shlokasCovered": [4, 5, 6],
            "xpReward": 50,
            "prerequisite": None
        }
    },
    {
        "id": "lesson_1_3",
        "data": {
            "chapterId": "chapter_1",
            "lessonNumber": 3,
            "lessonName": "मार्गदर्शन की खोज",
            "lessonNameEn": "Seeking Guidance",
            "order": 3,
            "estimatedTime": 300,
            "difficulty": "beginner",
            "shlokasCovered": [7, 8, 9],
            "xpReward": 50,
            "prerequisite": None
        }
    },
    # Chapter 2 Lessons
    {
        "id": "lesson_2_1",
        "data": {
            "chapterId": "chapter_2",
            "lessonNumber": 1,
            "lessonName": "आत्मा का स्वरूप",
            "lessonNameEn": "The Eternal Soul",
            "order": 1,
            "estimatedTime": 300,
            "difficulty": "intermediate",
            "shlokasCovered": [11, 12, 13],
            "xpReward": 60,
            "prerequisite": None
        }
    },
    {
        "id": "lesson_2_2",
        "data": {
            "chapterId": "chapter_2",
            "lessonNumber": 2,
            "lessonName": "स्थितप्रज्ञ की विशेषताएं",
            "lessonNameEn": "Characteristics of the Wise",
            "order": 2,
            "estimatedTime": 300,
            "difficulty": "intermediate",
            "shlokasCovered": [54, 55, 56],
            "xpReward": 60,
            "prerequisite": None
        }
    },
     {
        "id": "lesson_2_3",
        "data": {
            "chapterId": "chapter_2",
            "lessonNumber": 3,
            "lessonName": "सुख-दुःख में समता",
            "lessonNameEn": "Equanimity in Pleasure and Pain",
            "order": 3,
            "estimatedTime": 300,
            "difficulty": "intermediate",
            "shlokasCovered": [38],
            "xpReward": 60,
            "prerequisite": None
        }
    },
    # Chapter 3 Lessons
    {
        "id": "lesson_3_1",
        "data": {
            "chapterId": "chapter_3",
            "lessonNumber": 1,
            "lessonName": "निष्काम कर्म",
            "lessonNameEn": "Selfless Action",
            "order": 1,
            "estimatedTime": 300,
            "difficulty": "intermediate",
            "shlokasCovered": [1, 2, 3],
            "xpReward": 60,
            "prerequisite": None
        }
    },
    {
        "id": "lesson_3_2",
        "data": {
            "chapterId": "chapter_3",
            "lessonNumber": 2,
            "lessonName": "यज्ञ का महत्व",
            "lessonNameEn": "The Importance of Yajna",
            "order": 2,
            "estimatedTime": 300,
            "difficulty": "intermediate",
            "shlokasCovered": [9, 10, 11],
            "xpReward": 60,
            "prerequisite": None
        }
    },
    {
        "id": "lesson_3_3",
        "data": {
            "chapterId": "chapter_3",
            "lessonNumber": 3,
            "lessonName": "लोकसंग्रह",
            "lessonNameEn": "Leading by Example",
            "order": 3,
            "estimatedTime": 300,
            "difficulty": "intermediate",
            "shlokasCovered": [20, 21],
            "xpReward": 60,
            "prerequisite": None
        }
    }
]

def main():
    print("Starting database population...")
    try:
        token = get_access_token()
        print("Successfully authenticated.")
    except Exception as e:
        print(f"Authentication failed: {e}")
        return

    print(f"Writing {len(chapters)} chapters...")
    for chap in chapters:
        create_document(token, "chapters", chap['id'], chap['data'])

    print(f"Writing {len(lessons)} lessons...")
    for lesson in lessons:
        create_document(token, "lessons", lesson['id'], lesson['data'])
        
    print("Database population complete.")

if __name__ == "__main__":
    main()
