#!/usr/bin/env python3
"""
Seed Units 3-18 to Firestore.
"""

import json
import os
import requests
import time

# Configuration
PROJECT_ID = "gita-58861"
CONFIG_PATH = os.path.expanduser('~/.config/configstore/firebase-tools.json')
FIRESTORE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"
TOKEN_URL = "https://oauth2.googleapis.com/token"
CLIENT_ID = "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com"
CLIENT_SECRET = "ssVPMULxI8rXlS115U8a42qS"

# Content directory
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CONTENT_DIR = os.path.join(os.path.dirname(SCRIPT_DIR), "..", "content")

def get_access_token():
    """Get access token from Firebase config or refresh it."""
    try:
        with open(CONFIG_PATH, 'r') as f:
            config = json.load(f)
    except Exception as e:
        print(f"Error reading config: {e}")
        print("💡 TIP: Run 'firebase login' in your terminal to fix this.")
        exit(1)
    
    tokens = config.get('tokens', {})
    if not tokens:
        tokens = config.get('user', {}).get('tokens', {})

    access_token = tokens.get('access_token')
    expires_at = tokens.get('expires_at')
    
    if access_token and expires_at:
        now_ms = time.time() * 1000
        if int(expires_at) > now_ms + 60000:
            print("Using cached access_token")
            return access_token
        else:
            print(f"Cached token expired. Refreshing...")

    refresh_token = tokens.get('refresh_token')
    if not refresh_token:
        print("Error: Could not find refresh token in firebase-tools.json")
        print("💡 TIP: Run 'firebase login' to regenerate tokens.")
        exit(1)
        
    data = {
        'client_id': CLIENT_ID,
        'client_secret': CLIENT_SECRET,
        'refresh_token': refresh_token,
        'grant_type': 'refresh_token'
    }
    
    print("Refreshing token...")
    response = requests.post(TOKEN_URL, data=data)
    if response.status_code != 200:
        print(f"Error refreshing token: {response.text}")
        print("💡 TIP: Your session has expired. Run 'firebase login' in your terminal.")
        exit(1)
        
    return response.json()['access_token']

def to_firestore_value(value):
    if isinstance(value, bool): return {"booleanValue": value}
    elif isinstance(value, str): return {"stringValue": value}
    elif isinstance(value, int): return {"integerValue": str(value)}
    elif isinstance(value, float): return {"doubleValue": value}
    elif isinstance(value, list): return {"arrayValue": {"values": [to_firestore_value(v) for v in value]}}
    elif isinstance(value, dict): return {"mapValue": {"fields": {k: to_firestore_value(v) for k, v in value.items()}}}
    elif value is None: return {"nullValue": None}
    return {"stringValue": str(value)}

def create_document(access_token, collection, doc_id, data):
    url = f"{FIRESTORE_URL}/{collection}/{doc_id}"
    headers = {'Authorization': f'Bearer {access_token}', 'Content-Type': 'application/json'}
    fields = {k: to_firestore_value(v) for k, v in data.items()}
    payload = {"fields": fields}
    response = requests.patch(url, headers=headers, json=payload)
    if response.status_code != 200:
        print(f"  ❌ Error writing {collection}/{doc_id}: {response.text[:100]}")
        return False
    else:
        # print(f"  ✅ {collection}/{doc_id}")
        return True

def load_content_file(filename):
    filepath = os.path.join(CONTENT_DIR, filename)
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"❌ Error loading JSON {filename}: {e}")
        return None

def seed_unit(token, content):
    unit = content.get('unit', {})
    sections = content.get('sections', [])
    lessons = content.get('lessons', [])
    questions = content.get('questions', [])
    
    unit_number = unit.get('unitNumber', 1)
    chapter_id = f"chapter_{unit_number}"
    
    journey_id = "journey_1"
    if 7 <= unit_number <= 12: journey_id = "journey_2"
    elif 13 <= unit_number <= 18: journey_id = "journey_3"
    
    unit['journeyId'] = journey_id
    shloka_count = unit.get("shlokaCount", 0)
    
    print(f"\n📚 Seeding Unit {unit_number}: {unit.get('unitName', 'Unknown')} -> {journey_id}")
    
    create_document(token, "units", unit['id'], unit)
    
    chapter_data = {
        "chapterNumber": unit_number,
        "chapterName": unit.get("unitNameHi", ""),
        "chapterNameEn": unit.get("unitName", ""),
        "description": unit.get("descriptionHi", ""),
        "descriptionEn": unit.get("description", ""),
        "shlokaCount": shloka_count,
        "shlokasCovered": unit.get("shlokasCovered", ""),
        "order": unit_number,
        "isUnlocked": True, # Unlock all for now or logic? Let's just say true or strictly based on unit number. 
                            # Actually, user might want to lock them. But for seeding, let's keep previous logic or default false except 1-2.
                            # But wait, we are seeding 3-18. Let's make them locked by default except maybe 3?
                            # Let's keep isUnlocked = False for 3-18 to simulate progression.
        "isUnlocked": False,
        "icon": unit.get("icon", "📜"),
        "color": unit.get("color", "#FF9933"),
        "journeyId": journey_id
    }
    create_document(token, "chapters", chapter_id, chapter_data)

    print(f"  Writing {len(sections)} sections, {len(lessons)} lessons, {len(questions)} questions...")
    for section in sections:
        section['journeyId'] = journey_id
        section['chapterId'] = chapter_id
        create_document(token, "sections", section['id'], section)
    
    for lesson in lessons:
        lesson_data = lesson.copy()
        lesson_data['chapterId'] = chapter_id
        lesson_data['journeyId'] = journey_id
        create_document(token, "lessons", lesson['id'], lesson_data)
    
    for question in questions:
        doc_data = {
            'questionId': question['questionId'],
            'lessonId': question['lessonId'],
            'type': question['type'],
            'order': question['order'],
            'xpReward': question['xpReward'],
            'content': question['content']
        }
        create_document(token, "questions", question['questionId'], doc_data)
    print("  ✅ Done")

def main():
    print("=" * 50)
    print("🕉️  Gita App - Seeding Units 3-18")
    print("=" * 50)
    
    print("\n🔐 Authenticating...")
    try:
        token = get_access_token()
        print("✅ Authentication successful!")
    except Exception as e:
        print(f"❌ Authentication failed: {e}")
        return

    # Loop 3 to 18
    for i in range(3, 19):
        filename = f"unit{i}.json"
        content = load_content_file(filename)
        if content:
            seed_unit(token, content)
        else:
            print(f"❌ Could not load {filename}")
            
    print("\n" + "=" * 50)
    print("✅ All Units Updated!")
    print("=" * 50)

if __name__ == "__main__":
    main()
