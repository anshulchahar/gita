# Google Sign-In Setup Guide

## Firebase Console Configuration

To complete the Google Sign-In setup, you need to configure it in the Firebase Console:

### Step 1: Enable Google Sign-In Provider

1. Go to [Firebase Console](https://console.firebase.google.com/project/gita-58861)
2. Navigate to **Authentication** → **Sign-in method**
3. Click on **Google** provider
4. Enable it by toggling the switch
5. Set a support email (your email address)
6. Click **Save**

### Step 2: Get Your SHA-1 Fingerprint

For development/debug builds:

```bash
cd /Users/anshul/Documents/GitHub/gita

# For debug keystore (default)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

For release builds:

```bash
# Replace with your actual keystore path
keytool -list -v -keystore /path/to/your/release.keystore -alias your-alias-name
```

### Step 3: Add SHA-1 to Firebase Project

1. Copy the SHA-1 fingerprint from the command output
2. In Firebase Console, go to **Project Settings** (gear icon)
3. Scroll down to **Your apps** section
4. Click on your Android app
5. Click **Add fingerprint**
6. Paste the SHA-1 fingerprint
7. Click **Save**

### Step 4: Download Updated google-services.json

1. After adding the SHA-1 fingerprint, download the updated `google-services.json`
2. Replace the existing file at `/Users/anshul/Documents/GitHub/gita/app/google-services.json`
3. The file will now include the OAuth client ID for Google Sign-In

### Step 5: Verify OAuth Client ID

The OAuth client ID in the code is currently:
```
1091827331036-s76h7kefpj9spt9o3ug6d4cebedtc0n1.apps.googleusercontent.com
```

This should match the Web client ID from Firebase Console:
1. Go to **Project Settings** → **Service Accounts**
2. You can find the Web client (auto-created by Google Service) in the Google Cloud Console
3. Or check in the updated `google-services.json` file under `oauth_client`

### Step 6: Test the Integration

1. Build and run the app:
   ```bash
   cd /Users/anshul/Documents/GitHub/gita
   ./gradlew assembleDebug
   ```

2. Install on device/emulator:
   ```bash
   ./gradlew installDebug
   ```

3. Test the flow:
   - Launch the app
   - Go to Login or Signup screen
   - Tap "Sign in with Google" button
   - Select a Google account
   - Verify successful login and navigation to Home screen
   - Check Firestore for the created User document

### Troubleshooting

**Issue: "Sign-In Failed" or "Error 10"**
- Solution: Verify SHA-1 fingerprint is added correctly
- Ensure you're using the correct keystore (debug vs release)

**Issue: "Developer Error"**
- Solution: Check OAuth client ID matches the Web client ID from Firebase Console
- Ensure google-services.json is up to date

**Issue: "Network Error"**
- Solution: Ensure device has internet connection
- Check Firebase project is properly configured

**Issue: User not created in Firestore**
- Solution: Check Firestore Security Rules allow writes
- Verify AuthViewModel.signInWithGoogle() is being called correctly

### Current Implementation Status

✅ **Completed:**
- GoogleSignInModule with Hilt DI
- AuthViewModel.signInWithGoogle() function
- LoginScreen with Google button and activity result launcher
- SignupScreen with Google button and activity result launcher
- Navigation integration with GoogleSignInClient

⏳ **Pending:**
- Firebase Console configuration (SHA-1, enable Google provider)
- End-to-end testing with real Google account

### Files Modified

1. `app/src/main/java/com/schepor/gita/di/GoogleSignInModule.kt` - New
2. `app/src/main/java/com/schepor/gita/presentation/auth/AuthViewModel.kt` - Updated
3. `app/src/main/java/com/schepor/gita/presentation/auth/LoginScreen.kt` - Updated
4. `app/src/main/java/com/schepor/gita/presentation/auth/SignupScreen.kt` - Updated
5. `app/src/main/java/com/schepor/gita/presentation/navigation/GitaNavigation.kt` - Updated

### Next Steps

1. Follow steps 1-5 above to configure Firebase Console
2. Test Google Sign-In on a real device or emulator with Google Play Services
3. Verify user data is correctly saved to Firestore with photoUrl
4. Move on to the next critical task: **LessonViewModel & State Management**
