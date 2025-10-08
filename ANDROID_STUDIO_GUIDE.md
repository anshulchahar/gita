# 🚀 Running Your Gita App in Android Studio

## Quick Start Guide

### Step 1: Download Android Studio (if not installed)

1. **Visit**: https://developer.android.com/studio
2. **Download**: Android Studio for macOS
   - Choose "Apple Silicon" if you have M1/M2/M3 Mac
   - Choose "Intel" for older Macs
3. **Install**: Drag Android Studio to Applications folder
4. **Launch**: Open Android Studio for the first time
   - Follow the setup wizard
   - Install Android SDK (it will prompt you)
   - Install at least API level 35 (Android 15)

### Step 2: Open Your Project

1. **Launch Android Studio**
2. Click **"Open"** (or File → Open)
3. Navigate to: `/Users/anshul/Documents/GitHub/gita`
4. Click **"Open"**

### Step 3: Wait for Initial Setup (IMPORTANT!)

Android Studio will now automatically:

✅ **Download Gradle Distribution** (~100MB)
- You'll see: "Gradle sync" in the bottom status bar
- First time takes 2-5 minutes

✅ **Download Dependencies** (~500MB total)
- All libraries: Compose, Firebase, Hilt, etc.
- You'll see progress in the bottom "Build" tab
- First time takes 5-10 minutes depending on internet speed

✅ **Build the Project**
- Compiles all Kotlin code
- Generates necessary files
- May show some warnings (normal for first build)

**DO NOT interrupt this process!** Let it complete fully.

### Step 4: Setup Android Emulator (if needed)

If you don't have a physical Android device:

1. **Click "Device Manager"** icon in toolbar (looks like a phone)
2. Click **"Create Device"**
3. Select **"Pixel 6"** or **"Pixel 7"** (recommended)
4. Click **"Next"**
5. Download a **System Image**:
   - Recommended: **API 35 (Android 15)** or **API 34 (Android 14)**
   - Click "Download" next to the system image
   - Wait for download to complete
6. Click **"Next"** → **"Finish"**
7. Your emulator will appear in the device dropdown

### Step 5: Run the App! 🎉

1. **Select Device**:
   - Top toolbar: Click the device dropdown
   - Choose your emulator or connected physical device

2. **Click Run**:
   - Click the green **▶️ Play button** (or press `Ctrl+R`)
   - Or: Menu → Run → Run 'app'

3. **Wait for Build**:
   - First build takes 2-3 minutes
   - You'll see build progress in the bottom "Build" tab
   - Look for "BUILD SUCCESSFUL"

4. **Emulator Launches**:
   - If using emulator, it will boot up (takes 30-60 seconds first time)
   - App will automatically install and launch

5. **See Your App**:
   - Login screen with saffron gradient should appear!
   - You're now running your Gita app! 🙏

## 📱 What You'll See

### Login Screen
- Beautiful saffron (#FF9933) to deep purple (#4A148C) gradient
- Email and password input fields
- "Login with Google" button
- "Don't have an account? Sign up" link

### After Login/Signup
- **Wisdom Tree Home Screen**
- Chapter 1: "Foundations of Dharma" card
- Sacred gold accents
- "Start Learning" button

## 🐛 Troubleshooting

### Gradle Sync Failed
**Solution**:
```
File → Invalidate Caches → Invalidate and Restart
```

### "SDK Platform not found"
**Solution**:
1. Tools → SDK Manager
2. Check "Android 15.0 (API 35)"
3. Click "Apply"

### Build Errors
**Check**:
- ✅ `local.properties` has your Gemini API key
- ✅ `google-services.json` is in the `app/` folder
- ✅ Internet connection is stable (for downloading dependencies)

**Fix**:
```
Build → Clean Project
Build → Rebuild Project
```

### Emulator Won't Start
**Solution**:
1. Device Manager → Delete old emulator
2. Create new emulator with latest system image
3. Ensure you have at least 8GB free disk space

### Firebase Errors at Runtime
**Action Required**:
Go to Firebase Console and ensure:
1. **Authentication** → Enable "Email/Password" sign-in method
2. **Firestore Database** → Create database (start in test mode for now)
3. **Storage** → Initialize default bucket

## 🎯 Next Steps After Running

Once the app runs successfully:

### 1. Test Authentication
- Try signing up with an email
- Check Firebase Console → Authentication → Users
- Should see your test user created

### 2. Explore the UI
- Navigate through login → signup flow
- See the Wisdom Tree home screen
- Check the Material 3 design system in action

### 3. Continue Development
Refer to your Notion Kanban board for next tasks:
https://www.notion.so/286349a6acb681dda6afd516e0aeca70

**Priority Tasks**:
- [ ] Implement AuthViewModel with Firebase Auth logic
- [ ] Build UserRepository and ContentRepository
- [ ] Create Lesson screen with MCQ functionality
- [ ] Implement progress tracking

### 4. Monitor Logs
- **Logcat tab** (bottom): See runtime logs
- **Build tab** (bottom): See build output
- Filter by "com.schepor.gita" to see your app's logs only

## 📚 Useful Android Studio Shortcuts

- `Ctrl + R` - Run app
- `Ctrl + F9` - Build project
- `Shift + F10` - Run with debugger
- `Ctrl + Shift + F` - Find in files
- `Ctrl + Click` - Navigate to definition
- `Alt + Enter` - Quick fix suggestions

## 🔥 Firebase Integration Status

✅ **Already Configured**:
- Firebase SDK integrated
- google-services.json in place
- Auth, Firestore, Storage modules added
- Analytics ready

⏳ **Needs Setup in Console**:
- Enable Email/Password authentication
- Create Firestore database
- Initialize Storage bucket
- (Optional) Add SHA fingerprints for Google Sign-in

## 🎨 Design System Preview

Your app uses:
- **Primary Color**: Saffron (#FF9933)
- **Secondary Color**: Deep Purple (#4A148C)
- **Accent Color**: Sacred Gold (#FFD700)
- **Typography**: Inter (English), Noto Sans Devanagari (Sanskrit)
- **Architecture**: Clean Architecture + MVVM
- **DI**: Hilt
- **UI**: Jetpack Compose + Material 3

## 💡 Pro Tips

1. **Keep Android Studio Updated**: Check for updates regularly
2. **Enable Auto-Import**: Settings → Editor → Auto Import → Optimize imports on the fly
3. **Use Logcat Filters**: Create filters for different log levels
4. **Git Integration**: Android Studio has built-in Git support (VCS menu)
5. **Code Style**: Use `Ctrl + Alt + L` to format code

---

## ✅ Pre-flight Checklist

Before running, verify:
- [x] Android Studio installed
- [x] Project opened in Android Studio
- [x] Gradle sync completed successfully
- [x] Emulator created (or device connected)
- [x] API key in local.properties
- [ ] Firebase console configured
- [ ] Device/emulator selected in toolbar

**You're all set! Click that green ▶️ button and watch your app come to life!** 🚀

---

Need help? Check the Build/Logcat tabs in Android Studio for detailed error messages.
