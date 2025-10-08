# 🚀 Setup and Run Guide

## Prerequisites
- [ ] Android Studio (latest version recommended)
- [ ] Java 17 JDK
- [ ] Android SDK with API level 35
- [ ] Android device/emulator running Android 8.0 (API 26) or higher

## 🔧 Initial Setup Steps

### 1. Configure API Keys (CRITICAL)

Before building the app, you MUST add your Gemini API key:

```bash
# Edit local.properties
nano local.properties
```

Replace `your_gemini_api_key_here` with your actual Gemini API key from:
https://makersuite.google.com/app/apikey

The file should look like:
```properties
GEMINI_API_KEY=AIzaSyBxxx...your_actual_key_here
```

### 2. Open Project in Android Studio

1. Launch Android Studio
2. Click "Open"
3. Navigate to: `/Users/anshul/Documents/GitHub/gita`
4. Click "Open"

### 3. Wait for Gradle Sync

Android Studio will automatically:
- Download Gradle wrapper (gradle-wrapper.jar)
- Download all dependencies
- Sync the project

**This may take 5-10 minutes on first run.**

Watch the bottom status bar for "Gradle Build Running..." to complete.

### 4. Setup Android Emulator (if needed)

If you don't have a physical device:

1. Click "Device Manager" in Android Studio (phone icon in toolbar)
2. Click "Create Device"
3. Select "Pixel 6" or similar
4. Download system image (API 35 recommended)
5. Finish setup

### 5. Run the App

1. Select your device/emulator from the dropdown (top toolbar)
2. Click the green ▶️ "Run" button (or press Ctrl+R)
3. Wait for build and installation

## ⚠️ Known Setup Notes

### Firebase Configuration
- `google-services.json` is already in place ✅
- Firebase project: `gita-58861`
- Make sure your Firebase project has:
  - Authentication enabled (Email/Password)
  - Firestore database created
  - Storage bucket configured

### Font Files
- Inter and Noto Sans Devanagari fonts are placeholders
- The app will use system fonts until actual TTF files are added
- This won't prevent the app from running

### Launcher Icons
- Placeholder icons are in place
- Replace with actual icons in `app/src/main/res/mipmap-*/` for production

## 🐛 Troubleshooting

### Gradle Sync Failed
```bash
# Clean and rebuild
cd /Users/anshul/Documents/GitHub/gita
./gradlew clean
./gradlew build
```

### Missing Gradle Wrapper
```bash
# Download Gradle wrapper
gradle wrapper --gradle-version 8.7
```

### Build Errors Related to API Key
- Ensure `GEMINI_API_KEY` is set in `local.properties`
- Restart Android Studio after adding the key
- File > Invalidate Caches / Restart

### Firebase Errors
- Verify `google-services.json` is in `app/` directory
- Check Firebase Console for project configuration
- Ensure SHA fingerprints are added for debug builds

## 📱 First Run Experience

When you first run the app, you should see:

1. **Login Screen** with:
   - Saffron gradient background (#FF9933)
   - Email and Password fields
   - "Login with Google" button
   - "Don't have an account?" link

2. After signing up/logging in:
   - **Wisdom Tree Home Screen** with Chapter 1 card
   - "Foundations of Dharma" chapter
   - "Start Learning" button

## 🔍 Verify Installation

Check that these files exist:
- [x] `app/src/main/AndroidManifest.xml`
- [x] `app/src/main/java/com/schepor/gita/MainActivity.kt`
- [x] `app/src/main/java/com/schepor/gita/GitaApplication.kt`
- [x] `google-services.json` (root app/)
- [x] `local.properties` (with GEMINI_API_KEY)

## 📞 Need Help?

If you encounter issues:
1. Check the "Build" tab in Android Studio for specific errors
2. Look at "Logcat" tab for runtime errors
3. Verify all setup steps above are completed
4. Clean and rebuild the project

## 🎯 Next Steps After Running

Once the app runs successfully:
1. Test authentication (Firebase Auth)
2. Navigate through screens
3. Check Firestore data sync
4. Test AI content generation (requires Gemini API key)
5. Implement remaining features from Notion Kanban board

---

**Ready to run?** Follow steps 1-5 above! 🚀
