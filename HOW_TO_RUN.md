# 🚀 Running Your Gita App

## ✅ Build Successful! Now Let's Run It

You have **3 options** to run the app:

---

## Option 1: Run in Android Studio (RECOMMENDED) 🎨

This is the easiest and best way for development.

### Steps:

1. **Open Android Studio** (if not already open)

2. **Make sure your project is loaded**:
   - You should see the project structure on the left

3. **Select a device**:
   - Look at the top toolbar
   - Find the device dropdown (next to the ▶️ button)
   - Select either:
     - Your Android emulator (e.g., "Pixel 6 API 35")
     - Your physical device (if connected via USB)

4. **Click the green ▶️ Run button**:
   - Or press `Ctrl + R` (Mac: `Cmd + R`)
   - Or go to: Run → Run 'app'

5. **Wait for the app to install and launch**:
   - First time takes ~30-60 seconds
   - The emulator will boot (if not already running)
   - App will install automatically
   - App will launch on the device

6. **You should see**:
   - ✅ Login screen with saffron gradient
   - ✅ Email and password fields
   - ✅ "Login with Google" button

---

## Option 2: Install APK on Physical Device 📱

If you have a physical Android phone:

### Steps:

1. **Enable Developer Options** on your phone:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - "You are now a developer!" message appears

2. **Enable USB Debugging**:
   - Settings → Developer Options
   - Turn on "USB Debugging"

3. **Connect your phone** via USB cable

4. **Install the APK**:
   ```bash
   adb install /Users/anshul/Documents/GitHub/gita/app/build/outputs/apk/debug/app-debug.apk
   ```

5. **Launch the app**:
   - Find "Gita" icon on your phone
   - Tap to open

---

## Option 3: Use Android Emulator from Command Line 🖥️

If you want to use the emulator without Android Studio:

### Step 1: List Available Emulators

```bash
/Users/anshul/Library/Android/sdk/emulator/emulator -list-avds
```

### Step 2: Start an Emulator

```bash
# Replace "Pixel_6_API_35" with your actual AVD name from step 1
/Users/anshul/Library/Android/sdk/emulator/emulator -avd Pixel_6_API_35 &
```

### Step 3: Wait for Emulator to Boot

Wait ~30-60 seconds until you see the home screen.

### Step 4: Install and Run the App

```bash
# Install the APK
adb install /Users/anshul/Documents/GitHub/gita/app/build/outputs/apk/debug/app-debug.apk

# Launch the app
adb shell am start -n com.schepor.gita/.MainActivity
```

---

## 🎯 Quick Command Reference

### Check if Device is Connected

```bash
adb devices
```

Should show:
```
List of devices attached
emulator-5554   device
```

### Install APK

```bash
cd /Users/anshul/Documents/GitHub/gita
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

The `-r` flag reinstalls if already installed.

### Launch App

```bash
adb shell am start -n com.schepor.gita/.MainActivity
```

### View Logs

```bash
adb logcat | grep com.schepor.gita
```

### Uninstall App

```bash
adb uninstall com.schepor.gita
```

---

## 🎨 Recommended: Use Android Studio

**Why Android Studio is best for development:**

✅ **Live Reload**: See changes instantly  
✅ **Debugger**: Set breakpoints, inspect variables  
✅ **Logcat**: See all logs in real-time  
✅ **Layout Inspector**: Debug UI issues  
✅ **Profiler**: Monitor performance, memory  
✅ **Device Manager**: Easy emulator control  
✅ **Hot Reload**: Change code without full restart  

**Just click the ▶️ button and you're done!**

---

## 🐛 Troubleshooting

### "No devices found"

**Solution 1 - Create Emulator:**
1. Android Studio → Device Manager
2. Create Device → Pixel 6
3. Download System Image (API 35)
4. Finish

**Solution 2 - Use Physical Device:**
1. Enable Developer Options
2. Enable USB Debugging
3. Connect USB cable
4. Accept debugging prompt on phone

### "Installation failed"

```bash
# Uninstall first
adb uninstall com.schepor.gita

# Then install again
adb install app/build/outputs/apk/debug/app-debug.apk
```

### "App crashes immediately"

Check logs:
```bash
adb logcat -c  # Clear logs
adb logcat | grep -E "AndroidRuntime|com.schepor.gita"
```

Look for red error messages.

---

## 📱 What You'll See When App Runs

### Login Screen

```
┌─────────────────────────────────┐
│                                 │
│        🕉️ Gita - Wisdom        │
│                                 │
│   [Gradient: Saffron→Purple]    │
│                                 │
│   ┌─────────────────────────┐   │
│   │ Email                   │   │
│   └─────────────────────────┘   │
│                                 │
│   ┌─────────────────────────┐   │
│   │ Password                │   │
│   └─────────────────────────┘   │
│                                 │
│   ┌─────────────────────────┐   │
│   │   Login with Email      │   │
│   └─────────────────────────┘   │
│                                 │
│   ┌─────────────────────────┐   │
│   │  Login with Google      │   │
│   └─────────────────────────┘   │
│                                 │
│   Don't have an account?        │
│   Sign up                       │
│                                 │
└─────────────────────────────────┘
```

### After Sign Up/Login

You'll see the **Wisdom Tree Home Screen** with:
- Chapter cards
- Progress indicators
- "Start Learning" buttons

---

## ✅ Quick Start (Fastest Way)

**In Android Studio:**

1. Click ▶️ Run button (top toolbar)
2. Select device from dropdown
3. Wait ~30 seconds
4. App launches! 🎉

That's it!

---

## 🔗 Next Steps

Once the app is running:

1. **Test the UI**:
   - Navigate through screens
   - Check the design
   - Test buttons

2. **Check Firebase**:
   - Try signing up
   - Check Firebase Console → Authentication
   - See if user was created

3. **Continue Development**:
   - Implement AuthViewModel
   - Build repositories
   - Add lesson screens
   - Track progress

---

**Ready to run? Just click the ▶️ button in Android Studio!** 🚀
