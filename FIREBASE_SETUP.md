# 🔥 Firebase Console Setup Checklist

Your Firebase project is already integrated with the app, but you need to configure it in the Firebase Console.

## 📋 Quick Setup (15 minutes)

### Step 1: Open Firebase Console

1. Visit: https://console.firebase.google.com
2. Sign in with your Google account
3. Find your project: **gita-58861**
4. Click to open it

### Step 2: Enable Authentication

1. In the left sidebar, click **"Authentication"**
2. Click **"Get started"** (if first time)
3. Go to **"Sign-in method"** tab
4. Click **"Email/Password"**
5. **Enable** the toggle switch
6. Click **"Save"**

**Optional - Google Sign-In**:
1. Also enable **"Google"** sign-in method
2. You'll need to add SHA-1 fingerprint later for this to work

### Step 3: Create Firestore Database

1. In the left sidebar, click **"Firestore Database"**
2. Click **"Create database"**
3. Choose a location:
   - Recommended for India: **asia-south1 (Mumbai)**
   - Or: **us-central1** (default)
4. Start in **"Test mode"** for now (we'll secure it later)
5. Click **"Enable"**

**Initial Collections** (Create these):
```
chapters/
  - Add document ID: "chapter1"
  - Fields:
    • id: "chapter1"
    • title: "Foundations of Dharma"
    • order: 1
    • totalLessons: 5
    • description: "Understanding the fundamental principles of righteous living"

users/
  - Will be auto-created when users sign up

progress/
  - Will be auto-created when users start lessons
```

### Step 4: Initialize Storage

1. In the left sidebar, click **"Storage"**
2. Click **"Get started"**
3. Choose **"Production mode"** (we have custom rules ready)
4. Use same location as Firestore (asia-south1 or us-central1)
5. Click **"Done"**

This will be used for:
- User profile pictures
- Achievement badges
- Custom content images

**📝 Detailed Storage Setup**: See [STORAGE_SETUP.md](STORAGE_SETUP.md) for:
- Complete security rules
- Folder structure
- Upload/download examples
- Testing instructions

### Step 5: Verify Configuration

Go to **Project Settings** (⚙️ gear icon):

**General tab**:
- ✅ Default GCP resource location: (should be set to your chosen region)
- ✅ Public-facing name: "Gita"
- ✅ Support email: (your email)

**Your apps**:
- ✅ Android app registered (package: com.schepor.gita)
- ✅ google-services.json downloaded (already in your project)

### Step 6: Security Rules (After Initial Testing)

Once you've tested the app, update these rules:

**Firestore Rules**:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Everyone can read chapters and lessons
    match /chapters/{chapterId} {
      allow read: if true;
      allow write: if false; // Only admins via console
    }
    
    // Users can read/write their own progress
    match /progress/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

**Storage Rules**:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile pictures
    match /users/{userId}/profile.jpg {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Achievement badges (read-only for users)
    match /badges/{badge} {
      allow read: if true;
      allow write: if false; // Only admins
    }
  }
}
```

## 📊 Test Data Setup

### Sample Chapter Data

Add this to Firestore via Console (optional, for testing):

**Collection: chapters**

Document: `chapter1`
```json
{
  "id": "chapter1",
  "title": "Foundations of Dharma",
  "description": "Understanding the fundamental principles of righteous living and moral duty",
  "order": 1,
  "totalLessons": 5,
  "verseCount": 47,
  "estimatedMinutes": 25,
  "category": "philosophy",
  "isLocked": false,
  "prerequisites": []
}
```

Document: `chapter2`
```json
{
  "id": "chapter2",
  "title": "The Path of Action",
  "description": "Exploring the nature of selfless action and karma yoga",
  "order": 2,
  "totalLessons": 6,
  "verseCount": 72,
  "estimatedMinutes": 35,
  "category": "action",
  "isLocked": false,
  "prerequisites": ["chapter1"]
}
```

### Sample Lesson Data

**Sub-collection: chapters/chapter1/lessons**

Document: `lesson1`
```json
{
  "id": "lesson1",
  "chapterId": "chapter1",
  "title": "What is Dharma?",
  "order": 1,
  "content": "Dharma is the cosmic law underlying right behavior and social order...",
  "realLifeScenario": "You find a wallet with money. What should you do?",
  "estimatedMinutes": 5,
  "xpReward": 50,
  "questions": [
    {
      "questionText": "What is the primary meaning of Dharma?",
      "options": [
        "Religious duty",
        "Cosmic law and righteous living",
        "Meditation practice",
        "Social status"
      ],
      "correctAnswer": 1,
      "explanation": "Dharma encompasses the cosmic law that underlies right behavior, moral duty, and the path to righteousness."
    }
  ]
}
```

## 🔐 Security Checklist (Before Production)

- [ ] Change Firestore rules from test mode to authenticated mode
- [ ] Change Storage rules from test mode to authenticated mode
- [ ] Add password reset email template
- [ ] Configure email verification settings
- [ ] Add SHA-1/SHA-256 fingerprints for release builds
- [ ] Set up App Check for additional security
- [ ] Enable required Firebase services billing (if needed)

## 🧪 Testing in App

Once Firebase is configured, test these flows:

1. **Authentication**:
   - Sign up with email/password
   - Login with existing account
   - Check Firebase Console → Authentication → Users

2. **Firestore**:
   - View chapters in the app
   - Complete a lesson
   - Check Firebase Console → Firestore → Data

3. **Storage** (when implemented):
   - Upload profile picture
   - Check Firebase Console → Storage

## 📈 Enable Analytics (Optional)

1. Firebase Console → **Analytics**
2. Click **"Enable Google Analytics"**
3. Select/create Analytics account
4. Link to project

This gives you:
- User engagement metrics
- Screen flow analysis
- Retention tracking
- Custom event tracking (already in code)

## 🔗 Useful Links

- **Firebase Console**: https://console.firebase.google.com/project/gita-58861
- **Firebase Docs**: https://firebase.google.com/docs
- **Firestore Queries**: https://firebase.google.com/docs/firestore/query-data/queries
- **Auth Best Practices**: https://firebase.google.com/docs/auth/android/start

## ✅ Firebase Setup Complete Checklist

Before running the app for the first time:

- [ ] Opened Firebase Console (console.firebase.google.com)
- [ ] Found project: gita-58861
- [ ] Enabled Email/Password authentication
- [ ] Created Firestore database (in test mode)
- [ ] Initialized Storage bucket (in test mode)
- [ ] Added sample chapter data (optional)
- [ ] Verified google-services.json is in app/ folder
- [ ] Ready to run the app! 🚀

---

**Next Step**: Open Android Studio and run the app! Refer to `ANDROID_STUDIO_GUIDE.md` for detailed instructions.
