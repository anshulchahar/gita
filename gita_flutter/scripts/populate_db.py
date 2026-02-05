#!/usr/bin/env python3
"""
Gita App Database Seeder
Reads content from JSON files and uploads to Firebase Firestore.
Supports Journey -> Unit -> Section -> Lesson hierarchy.
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

# Content directory (relative to this script)
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CONTENT_DIR = os.path.join(os.path.dirname(SCRIPT_DIR), "..", "content")

# Journey Definitions (metadata)
JOURNEYS = [
    {
        "id": "journey_1",
        "title": "Tvam (You, The Seeker)",
        "titleHi": "त्वम् (तुम, साधक)",
        "description": "Self-Discovery & Inner Mastery",
        "descriptionHi": "आत्म-खोज और आंतरिक महारत",
        "shlokasCovered": "Chapters 1-6",
        "order": 1,
        "icon": "🏹",
        "color": "#FF9933"
    },
    {
        "id": "journey_2",
        "title": "Tat (That, The Divine)",
        "titleHi": "तत् (वह, परमात्मा)",
        "description": "Understanding the Divine",
        "descriptionHi": "परमात्मा को समझना",
        "shlokasCovered": "Chapters 7-12",
        "order": 2,
        "icon": "🙏",
        "color": "#4A148C"
    },
    {
        "id": "journey_3",
        "title": "Asi (Are, The Union)",
        "titleHi": "असि (हो, मिलन)",
        "description": "Integration & Liberation",
        "descriptionHi": "एकीकरण और मुक्ति",
        "shlokasCovered": "Chapters 13-18",
        "order": 3,
        "icon": "🔥",
        "color": "#FF6F00"
    }
]

def get_access_token():
    """Get access token from Firebase config or refresh it."""
    try:
        with open(CONFIG_PATH, 'r') as f:
            config = json.load(f)
    except Exception as e:
        print(f"Error reading config: {e}")
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
        exit(1)
        
    return response.json()['access_token']

def to_firestore_value(value):
    """Convert Python values to Firestore format."""
    if isinstance(value, bool):
        return {"booleanValue": value}
    elif isinstance(value, str):
        return {"stringValue": value}
    elif isinstance(value, int):
        return {"integerValue": str(value)}
    elif isinstance(value, float):
        return {"doubleValue": value}
    elif isinstance(value, list):
        return {"arrayValue": {"values": [to_firestore_value(v) for v in value]}}
    elif isinstance(value, dict):
        return {"mapValue": {"fields": {k: to_firestore_value(v) for k, v in value.items()}}}
    elif value is None:
        return {"nullValue": None}
    return {"stringValue": str(value)}

def create_document(access_token, collection, doc_id, data):
    """Create or update a Firestore document."""
    url = f"{FIRESTORE_URL}/{collection}/{doc_id}"
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json'
    }
    
    fields = {k: to_firestore_value(v) for k, v in data.items()}
    payload = {"fields": fields}
    
    response = requests.patch(url, headers=headers, json=payload)
    
    if response.status_code != 200:
        print(f"  ❌ Error writing {collection}/{doc_id}: {response.text[:100]}")
        return False
    else:
        print(f"  ✅ {collection}/{doc_id}")
        return True

def load_content_file(filename):
    """Load a JSON content file."""
    filepath = os.path.join(CONTENT_DIR, filename)
    if not os.path.exists(filepath):
        # Only print warning if we explicitly expect it, but here we loop 1-18 so quiet fail is better or just ignore
        # print(f"Warning: Content file not found: {filepath}")
        return None
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"❌ Error loading JSON {filename}: {e}")
        return None

def seed_journeys(token):
    """Seed the 3 main Journeys."""
    print("\n🛤️  Seeding Journeys...")
    for journey in JOURNEYS:
        create_document(token, "journeys", journey['id'], journey)

def seed_unit(token, content):
    """Seed a unit and all its sections, lessons, and questions."""
    if not content:
        return
    
    unit = content.get('unit', {})
    sections = content.get('sections', [])
    lessons = content.get('lessons', [])
    questions = content.get('questions', [])
    
    # Map unit number to chapter ID for app compatibility
    unit_number = unit.get('unitNumber', 1)
    chapter_id = f"chapter_{unit_number}"
    
    # Determine Journey ID based on Unit/Chapter number
    journey_id = "journey_1"
    if 7 <= unit_number <= 12:
        journey_id = "journey_2"
    elif 13 <= unit_number <= 18:
        journey_id = "journey_3"
    
    unit['journeyId'] = journey_id
    
    # Ensure shlokaCount matches JSON or default
    shloka_count = unit.get("shlokaCount", 0)
    
    print(f"\n📚 Seeding Unit: {unit.get('unitName', 'Unknown')} (Unit {unit_number}) -> {journey_id}")
    
    # Create unit document (modern structure)
    if unit:
        create_document(token, "units", unit['id'], unit)
        
        # ALSO Create chapter document (legacy/app compatibility)
        # The app listens to 'chapters' collection. We map Unit -> Chapter.
        chapter_data = {
            "chapterNumber": unit_number,
            "chapterName": unit.get("unitNameHi", ""), # Mapping DB schema to App expectations
            "chapterNameEn": unit.get("unitName", ""),
            "description": unit.get("descriptionHi", ""),
            "descriptionEn": unit.get("description", ""),
            "shlokaCount": shloka_count,
            "shlokasCovered": unit.get("shlokasCovered", ""),
            "order": unit_number,
            "isUnlocked": unit_number <= 2, # Unlock first 2 units for testing
            "icon": unit.get("icon", "📜"),
            "color": unit.get("color", "#FF9933"),
            "journeyId": journey_id
        }
        create_document(token, "chapters", chapter_id, chapter_data)

    
    # Create sections
    print(f"\n  📑 Creating {len(sections)} sections...")
    for section in sections:
        section['journeyId'] = journey_id # Propagate journeyId
        create_document(token, "sections", section['id'], section)
    
    # Create lessons
    print(f"\n  📖 Creating {len(lessons)} lessons...")
    for lesson in lessons:
        # Add chapterId for app compatibility (app queries by chapterId)
        lesson_data = lesson.copy()
        lesson_data['chapterId'] = chapter_id
        lesson_data['journeyId'] = journey_id
        create_document(token, "lessons", lesson['id'], lesson_data)
    
    # Create questions
    print(f"\n  ❓ Creating {len(questions)} questions...")
    for question in questions:
        # Flatten the content for Firestore
        doc_data = {
            'questionId': question['questionId'],
            'lessonId': question['lessonId'],
            'type': question['type'],
            'order': question['order'],
            'xpReward': question['xpReward'],
            'content': question['content']
        }
        create_document(token, "questions", question['questionId'], doc_data)

def main():
    print("=" * 50)
    print("🕉️  Gita App Database Seeder")
    print("=" * 50)
    
    # Authenticate
    print("\n🔐 Authenticating...")
    try:
        token = get_access_token()
        print("✅ Authentication successful!")
    except Exception as e:
        print(f"❌ Authentication failed: {e}")
        return
    
    # Seed Journeys
    seed_journeys(token)
    
    # Find and seed all unit content files
    # We iterate 1 through 18, checking if file exists
    
    found_any = False
    for i in range(1, 19):
        filename = f"unit{i}.json"
        content = load_content_file(filename)
        if content:
            found_any = True
            seed_unit(token, content)
            
    if not found_any:
        print("\n❌ No unit content files found (checked unit1.json to unit18.json)")
    
    print("\n" + "=" * 50)
    print("✅ Database seeding complete!")
    print("=" * 50)

if __name__ == "__main__":
    main()
