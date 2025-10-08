# 🐛 App Crash Debugging Guide

## Step 1: Get Crash Logs from Android Studio

To help debug the crash, I need to see the actual error. Please do the following:

### Method 1: From Logcat (BEST)

1. **Open Logcat tab** in Android Studio (bottom of screen)

2. **Filter by your app**:
   - In the filter dropdown, select your device
   - In the search box, type: `com.schepor.gita`

3. **Look for RED error lines** that say:
   - `FATAL EXCEPTION`
   - `AndroidRuntime`
   - `Caused by:`

4. **Copy the entire stack trace** (the red error text)

5. **Share it with me** - I'll identify the exact issue

### Method 2: From Terminal (Alternative)

If the app is currently running and crashing:

```bash
# Get crash logs
adb logcat -d | grep -A 50 "FATAL EXCEPTION"
```

Or for more detail:
```bash
adb logcat AndroidRuntime:E *:S
```

---

## Common Crash Causes & Quick Fixes

While you get the logs, here are the most common issues:

### 🔴 Crash 1: Hilt Dependency Injection Error

**Error looks like:**
```
Caused by: java.lang.IllegalStateException: 
Hilt Activity must be attached to an @HiltAndroidApp Application
```

**Fix:** Check AndroidManifest.xml has:
```xml
<application
    android:name=".GitaApplication"
    ...>
```

### 🔴 Crash 2: Firebase Not Initialized

**Error looks like:**
```
Caused by: java.lang.IllegalStateException: 
FirebaseApp initialization unsuccessful
```

**Fix:** Ensure:
- `google-services.json` is in `app/` folder ✓ (we fixed this)
- Firebase dependencies are in `build.gradle.kts`

### 🔴 Crash 3: Missing Font Files

**Error looks like:**
```
Caused by: android.content.res.Resources$NotFoundException: 
Font resource ID #0x...
```

**Fix:** The placeholder font files might be causing issues

### 🔴 Crash 4: Navigation Issue

**Error looks like:**
```
Caused by: java.lang.IllegalArgumentException: 
Navigation destination ... is not known to this NavController
```

**Fix:** Navigation routes mismatch

### 🔴 Crash 5: Compose Runtime Error

**Error looks like:**
```
Caused by: java.lang.IllegalStateException: 
ViewTreeLifecycleOwner not found
```

**Fix:** MainActivity setup issue

---

## Quick Diagnostic Steps

### Step 1: Check Build Success

```bash
cd /Users/anshul/Documents/GitHub/gita
./gradlew clean assembleDebug
```

Does it build successfully? If not, there's a compilation error.

### Step 2: Check AndroidManifest.xml

```bash
cat app/src/main/AndroidManifest.xml | grep -A 3 "application"
```

Should show:
```xml
<application
    android:name=".GitaApplication"
    ...>
```

### Step 3: Check if Font Files Exist

```bash
ls -la app/src/main/res/font/
```

If fonts are missing or placeholder, they might crash the app.

---

## Temporary Fix: Bypass Potential Issues

Let me create a minimal working version to isolate the issue:

### Option 1: Remove Font Loading (Temporary)

If font files are the issue, we can use system fonts temporarily.

### Option 2: Simplify Navigation

Start with just one screen to see if navigation is the problem.

### Option 3: Check Firebase Initialization

Ensure Firebase initializes before any Firebase calls.

---

## What I Need from You

**To fix this quickly, please provide:**

1. **The exact crash log** from Logcat (the red error text)
   - Specifically the lines that say `Caused by:` and the stack trace

2. **When does it crash?**
   - On app launch (before any screen shows)?
   - After login screen appears?
   - When clicking a button?

3. **What you see before crash:**
   - White screen?
   - Login screen?
   - Splash screen?
   - Nothing (immediate crash)?

---

## How to Share Crash Logs

### In Android Studio:

1. Open **Logcat** tab (Alt+6 or bottom toolbar)
2. Filter by: `com.schepor.gita`
3. Look for **red text** (errors)
4. **Right-click on error** → Copy
5. **Paste here** (the entire error message)

### Example of What I Need:

```
2025-10-08 15:45:32.123 12345-12345/com.schepor.gita E/AndroidRuntime: FATAL EXCEPTION: main
    Process: com.schepor.gita, PID: 12345
    java.lang.RuntimeException: Unable to start activity ComponentInfo{...}
        at android.app.ActivityThread.performLaunchActivity(...)
        ...
    Caused by: java.lang.IllegalStateException: [THE ACTUAL ERROR]
        at com.schepor.gita.MainActivity.onCreate(MainActivity.kt:25)
        at ...
```

---

## Immediate Actions

While waiting for logs, let me check the most critical files for obvious issues...

**Please share the crash logs, and I'll fix it immediately!** 🔧
