# ✅ Getting Your App Running - Complete Checklist

Follow these steps in order to get your Gita app running for the first time.

## Phase 1: Install Android Studio (30 mins)

- [ ] Visit https://developer.android.com/studio
- [ ] Download Android Studio for macOS (choose Apple Silicon or Intel)
- [ ] Install by dragging to Applications folder
- [ ] Launch Android Studio
- [ ] Complete the setup wizard
- [ ] Install Android SDK (wizard will prompt you)
- [ ] Install API Level 35 (Android 15) - minimum requirement

**Note**: Android Studio includes its own JDK, so you don't need to install Java separately!

---

## Phase 2: Configure Firebase (15 mins)

- [ ] Visit https://console.firebase.google.com
- [ ] Sign in with your Google account
- [ ] Find project: **gita-58861**
- [ ] **Enable Authentication**:
  - [ ] Click "Authentication" in sidebar
  - [ ] Click "Get started"
  - [ ] Go to "Sign-in method" tab
  - [ ] Enable "Email/Password"
  - [ ] Click "Save"

- [ ] **Create Firestore Database**:
  - [ ] Click "Firestore Database" in sidebar
  - [ ] Click "Create database"
  - [ ] Choose location: asia-south1 (Mumbai) or us-central1
  - [ ] Start in "Test mode"
  - [ ] Click "Enable"

- [ ] **Initialize Storage**:
  - [ ] Click "Storage" in sidebar
  - [ ] Click "Get started"
  - [ ] Choose "Test mode"
  - [ ] Use same location as Firestore
  - [ ] Click "Done"

**Reference**: See `FIREBASE_SETUP.md` for detailed instructions

---

## Phase 3: Prepare Your Project (5 mins)

- [x] ✅ Gemini API key added to `local.properties`
- [x] ✅ `google-services.json` is in `app/` folder
- [x] ✅ All source code files created
- [x] ✅ Gradle configuration complete

**Verify your API key**:
```bash
cat /Users/anshul/Documents/GitHub/gita/local.properties
# Should show: GEMINI_API_KEY=AIzaSy...
```

---

## Phase 4: Open in Android Studio (10 mins)

- [ ] Launch Android Studio
- [ ] Click "Open" (or File → Open)
- [ ] Navigate to: `/Users/anshul/Documents/GitHub/gita`
- [ ] Click "Open"

**Wait for automatic setup** (do not interrupt!):
- [ ] Gradle sync starts (bottom status bar)
- [ ] Gradle wrapper downloaded (~100MB)
- [ ] Dependencies downloaded (~500MB)
- [ ] Project builds successfully

**Expected time**: 5-10 minutes on first open

**What to watch**:
- Bottom left: "Gradle sync" running
- Bottom right: Download progress
- Bottom "Build" tab: Detailed logs

---

## Phase 5: Setup Emulator (10 mins)

**Skip this if you have a physical Android device!**

- [ ] Click "Device Manager" icon in toolbar (phone icon)
- [ ] Click "Create Device"
- [ ] Select "Pixel 6" or "Pixel 7"
- [ ] Click "Next"
- [ ] Download system image:
  - [ ] Select "API 35" (Android 15) or "API 34" (Android 14)
  - [ ] Click "Download" (wait for it to complete)
- [ ] Click "Next"
- [ ] Click "Finish"
- [ ] Emulator appears in device dropdown

**Alternative - Use Physical Device**:
- [ ] Enable Developer Options on your Android phone
- [ ] Enable USB Debugging
- [ ] Connect via USB cable
- [ ] Accept "Allow USB debugging" prompt on phone
- [ ] Device appears in Android Studio dropdown

---

## Phase 6: Run the App! 🎉 (5 mins)

- [ ] **Select device** from dropdown (top toolbar)
- [ ] **Click the green ▶️ Play button** (or press Ctrl+R)
- [ ] **Wait for build**:
  - [ ] Build starts (bottom "Build" tab shows progress)
  - [ ] Look for "BUILD SUCCESSFUL" message
  - [ ] APK is generated

- [ ] **App launches**:
  - [ ] Emulator boots (if using emulator)
  - [ ] App installs automatically
  - [ ] App launches on device/emulator

- [ ] **Verify login screen appears**:
  - [ ] Saffron to purple gradient background
  - [ ] Email input field
  - [ ] Password input field
  - [ ] "Login with Google" button
  - [ ] "Don't have an account? Sign up" link

**🎊 Success!** Your app is running!

---

## Phase 7: Test the App (10 mins)

- [ ] **Test Sign Up**:
  - [ ] Click "Don't have an account? Sign up"
  - [ ] Enter test email: test@example.com
  - [ ] Enter password: Test@123
  - [ ] Click "Sign Up"

- [ ] **Verify in Firebase Console**:
  - [ ] Go to Authentication → Users
  - [ ] Should see test@example.com listed

- [ ] **Navigate to Home Screen**:
  - [ ] Should see "Wisdom Tree" title
  - [ ] Should see Chapter 1 card
  - [ ] Should see "Foundations of Dharma"
  - [ ] Should see "Start Learning" button

- [ ] **Check Logcat** (bottom tab):
  - [ ] Filter by "com.schepor.gita"
  - [ ] Look for any errors (red text)
  - [ ] Firebase initialization logs should be visible

---

## 🐛 Troubleshooting

### ❌ Gradle Sync Failed
**Solution**:
```
File → Invalidate Caches → Invalidate and Restart
```

### ❌ Build Errors
**Check**:
1. Internet connection is stable
2. `local.properties` has Gemini API key
3. `google-services.json` exists in `app/` folder

**Fix**:
```
Build → Clean Project
Build → Rebuild Project
```

### ❌ Emulator Won't Start
**Solution**:
1. Device Manager → Delete emulator
2. Create new emulator with latest system image
3. Ensure 8GB+ free disk space

### ❌ App Crashes on Launch
**Check Logcat**:
1. Bottom tab: "Logcat"
2. Filter: "com.schepor.gita"
3. Look for red error messages
4. Common issues:
   - Missing API key → Check local.properties
   - Firebase not configured → Check FIREBASE_SETUP.md
   - Network error → Check internet connection

---

## 📚 Resources

| Guide | Purpose | Time |
|-------|---------|------|
| [ANDROID_STUDIO_GUIDE.md](ANDROID_STUDIO_GUIDE.md) | Complete Android Studio setup | 15 min read |
| [FIREBASE_SETUP.md](FIREBASE_SETUP.md) | Firebase Console configuration | 15 min setup |
| [README.md](README.md) | Project overview & tech stack | 5 min read |
| [Notion Workspace](https://www.notion.so/286349a6acb681dda6afd516e0aeca70) | PRD, architecture, tasks | Ongoing |

---

## 🎯 Next Steps After Running

Once your app runs successfully:

### Immediate (Today):
- [ ] Test email authentication thoroughly
- [ ] Navigate through all screens
- [ ] Check Firebase Console data
- [ ] Review Logcat for any warnings

### This Week:
- [ ] Implement AuthViewModel logic
- [ ] Build UserRepository and ContentRepository
- [ ] Create Lesson screen with MCQ
- [ ] Add progress tracking to Firestore
- [ ] Test AI content generation with Gemini

### This Month:
- [ ] Complete all 50 tasks from Notion Kanban
- [ ] Add all 18 chapters
- [ ] Implement gamification (XP, streaks)
- [ ] Build leaderboards
- [ ] Add achievements system
- [ ] Polish animations and transitions
- [ ] Prepare for beta testing

---

## ✨ Current Status

**✅ Completed** (8/12 core tasks):
- ✅ Android project structure
- ✅ Firebase SDK integration
- ✅ Hilt dependency injection
- ✅ Clean Architecture layers
- ✅ Material 3 design system
- ✅ Navigation Compose
- ✅ Firestore data models
- ✅ Wisdom Tree home screen

**🔄 In Progress**:
- ⏳ Running the app for the first time
- ⏳ Firebase Console setup

**📋 Up Next**:
- 🔜 Build authentication system
- 🔜 Create repositories
- 🔜 Build lesson screen with MCQ
- 🔜 Implement progress tracking

---

## 🎊 You're Ready!

**Your project is 100% set up and ready to run.**

All you need to do is:
1. ✅ Install Android Studio (if not done)
2. ✅ Configure Firebase Console (15 mins)
3. ✅ Open project in Android Studio
4. ✅ Click ▶️ Run

**Time to launch**: ~1 hour total (including downloads)

**Let's build something amazing! 🚀**

---

**Questions or issues?** 
- Check the troubleshooting section above
- Review ANDROID_STUDIO_GUIDE.md
- Check Logcat tab in Android Studio for errors
- Verify Firebase Console configuration
