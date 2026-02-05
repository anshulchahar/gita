#!/usr/bin/env python3
"""
Gita App Database Seeder
Reads content from JSON files and uploads to Firebase Firestore.
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
        print(f"Warning: Content file not found: {filepath}")
        return None
    
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)

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
    
    print(f"\n📚 Seeding Unit: {unit.get('unitName', 'Unknown')}")
    
    # Create unit document
    if unit:
        create_document(token, "units", unit['id'], unit)
    
    # Create sections
    print(f"\n  📑 Creating {len(sections)} sections...")
    for section in sections:
        create_document(token, "sections", section['id'], section)
    
    # Create lessons with chapterId for app compatibility
    print(f"\n  📖 Creating {len(lessons)} lessons...")
    for lesson in lessons:
        # Add chapterId for app compatibility (app queries by chapterId)
        lesson_data = lesson.copy()
        lesson_data['chapterId'] = chapter_id
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

def seed_chapters(token):
    """Seed basic chapter metadata with Unit names."""
    chapters = [
        {
            "id": "chapter_1",
            "data": {
                "chapterNumber": 1,
                "chapterName": "भीतर का युद्धक्षेत्र",
                "chapterNameEn": "The Battlefield Within",
                "description": "कठिन निर्णयों का सामना करना सीखें",
                "descriptionEn": "Facing Life's Dilemmas - Explore Arjuna's crisis",
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
                "chapterName": "शाश्वत आत्मा",
                "chapterNameEn": "The Eternal You",
                "description": "आत्मा और ज्ञान की खोज",
                "descriptionEn": "Soul & Wisdom - Discover your immortal soul",
                "shlokaCount": 72,
                "order": 2,
                "isUnlocked": True,
                "icon": "🧘",
                "color": "#4A148C"
            }
        }
    ]
    
    print("\n📜 Seeding chapters...")
    for chapter in chapters:
        create_document(token, "chapters", chapter['id'], chapter['data'])

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
    
    # Seed chapters first
    seed_chapters(token)
    
    # Find and seed all unit content files
    content_files = ['unit1.json', 'unit2.json']
    
    for filename in content_files:
        content = load_content_file(filename)
        if content:
            seed_unit(token, content)
    
    print("\n" + "=" * 50)
    print("✅ Database seeding complete!")
    print("=" * 50)

if __name__ == "__main__":
    main()
