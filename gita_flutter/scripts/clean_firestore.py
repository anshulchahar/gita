#!/usr/bin/env python3
"""
Clean Firestore Script
Deletes ALL documents in questions, lessons, and chapters collections.
Use this to fix "Map is not subtype of String" errors caused by corrupted legacy data.
"""

import json
import os
import requests
import time

# Configuration (Same as populate_db.py)
PROJECT_ID = "gita-58861"
CONFIG_PATH = os.path.expanduser('~/.config/configstore/firebase-tools.json')
FIRESTORE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"
TOKEN_URL = "https://oauth2.googleapis.com/token"
CLIENT_ID = "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com"
CLIENT_SECRET = "ssVPMULxI8rXlS115U8a42qS"

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

    access_token = tokens.get('access_token')
    if access_token:
        return access_token
        
    refresh_token = tokens.get('refresh_token')
    if not refresh_token:
        print("Error: Could not find refresh token.")
        exit(1)
        
    data = {'client_id': CLIENT_ID, 'client_secret': CLIENT_SECRET, 'refresh_token': refresh_token, 'grant_type': 'refresh_token'}
    response = requests.post(TOKEN_URL, data=data)
    if response.status_code != 200:
        print(f"Error refreshing token: {response.text}")
        exit(1)
        
    return response.json()['access_token']

def delete_collection(token, collection_name):
    print(f"Cleaning '{collection_name}'...")
    url = f"{FIRESTORE_URL}/{collection_name}"
    headers = {'Authorization': f'Bearer {token}'}
    
    # List documents
    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        print(f"  Error listing {collection_name}: {response.text}")
        return
        
    data = response.json()
    documents = data.get('documents', [])
    
    if not documents:
        print(f"  Collection {collection_name} is already empty.")
        return

    print(f"  Found {len(documents)} documents. Deleting...")
    
    for doc in documents:
        doc_path = doc['name'] # full resource path
        doc_id = doc_path.split('/')[-1]
        
        del_url = f"{FIRESTORE_URL}/{collection_name}/{doc_id}"
        del_res = requests.delete(del_url, headers=headers)
        if del_res.status_code == 200:
            print(f"    Deleted {doc_id}")
        else:
            print(f"    Failed to delete {doc_id}")

def main():
    print("=" * 50)
    print("🧹 Firestore Cleaner")
    print("=" * 50)
    
    token = get_access_token()
    
    # Delete in order
    delete_collection(token, "questions")
    delete_collection(token, "lessons")
    delete_collection(token, "chapters")
    delete_collection(token, "sections")
    delete_collection(token, "units")
    
    print("\n✅ Cleanup Complete! Now run your app to re-seed fresh data.")

if __name__ == "__main__":
    main()
