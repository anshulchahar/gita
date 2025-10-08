# Google Sign-In Troubleshooting Guide

## Issue: Login remains at Login screen after Google Sign-In attempt

### What Was Fixed

1. **Added Better Error Handling**
   - Added `setError()` function to AuthViewModel
   - LoginScreen and SignupScreen now display specific error messages
   - Shows error codes and messages from Google Sign-In API

2. **Button Now Always Enabled**
   - Google Sign-In button is no longer disabled when googleSignInClient is null
   - Shows error message "Google Sign-In is not configured" if client is missing
   - Allows users to try the button and see what's wrong

3. **Improved Error Feedback**
   - Catches ApiException and displays: "Google Sign-In failed: {statusCode} - {message}"
   - Shows cancellation message if user cancels the sign-in flow
   - All errors are displayed in the UI error text area

## How to Debug

### Step 1: Check for Error Messages

After tapping "Sign in with Google", look for error messages displayed in red text below the title. Common errors:

**Error: "Google Sign-In is not configured"**
- **Cause:** GoogleSignInClient is null
- **Solution:** Check that GoogleSignInClient is being created in GitaNavigation.kt

**Error: "Google Sign-In failed: 10 - ..."**
- **Cause:** Developer error - OAuth client ID not configured properly
- **Solution:** 
  1. Go to Firebase Console → Authentication → Sign-in method → Google
  2. Enable Google sign-in provider
  3. Go to Project Settings → Add SHA-1 fingerprint
  4. Download updated google-services.json

**Error: "Google Sign-In failed: 12501 - ..."**
- **Cause:** User cancelled the sign-in
- **Solution:** Try again and select an account

**Error: "Google Sign-In was cancelled"**
- **Cause:** User pressed back or cancelled the account selection
- **Solution:** This is expected behavior

### Step 2: Verify OAuth Client ID

The OAuth client ID in the code is:
```
1091827331036-s76h7kefpj9spt9o3ug6d4cebedtc0n1.apps.googleusercontent.com
```

**To verify:**
1. Open `app/google-services.json`
2. Look for `oauth_client` section
3. Find the `client_id` with `client_type: 3` (Web client)
4. It should match the ID in GoogleSignInModule.kt and GitaNavigation.kt

### Step 3: Check SHA-1 Fingerprint

**Get your debug SHA-1:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Add to Firebase:**
1. Firebase Console → Project Settings
2. Scroll to "Your apps" → Click your Android app
3. Click "Add fingerprint"
4. Paste SHA-1
5. Click Save
6. Download updated google-services.json
7. Replace the file in `app/google-services.json`

### Step 4: Enable Google Sign-In in Firebase

1. Go to Firebase Console → Authentication
2. Click "Sign-in method" tab
3. Click "Google" in the providers list
4. Toggle "Enable"
5. Set support email (your email)
6. Click "Save"

### Step 5: Check Logcat for Detailed Errors

In Android Studio:
1. Open Logcat (View → Tool Windows → Logcat)
2. Filter by "GoogleSignIn" or "Auth"
3. Look for error messages with status codes

Common Logcat errors:
- `Status{statusCode=DEVELOPER_ERROR}` → OAuth client ID issue
- `Status{statusCode=SIGN_IN_CANCELLED}` → User cancelled
- `Status{statusCode=NETWORK_ERROR}` → No internet connection

## Testing the Fix

### What to Look For:

1. **Tap Google Sign-In button**
   - Button should be clickable (not grayed out)
   - Should open Google account picker

2. **Select Google account**
   - If error occurs, check the error message displayed
   - Take note of the error code number

3. **After successful sign-in**
   - Should see loading indicator
   - Should navigate to Home screen
   - User should be signed in

### Expected Flow:

```
User taps "Sign in with Google"
  ↓
Google account picker opens
  ↓
User selects account
  ↓
Google returns account info
  ↓
AuthViewModel.signInWithGoogle() called
  ↓
Firebase authenticates user
  ↓
User document created in Firestore
  ↓
authState.isSuccess = true
  ↓
Navigate to Home screen
```

## Quick Fix Checklist

- [ ] Google Sign-In enabled in Firebase Authentication
- [ ] SHA-1 fingerprint added to Firebase project
- [ ] google-services.json downloaded and updated
- [ ] OAuth client ID matches in code and google-services.json
- [ ] App rebuilt after updating google-services.json
- [ ] Device has Google Play Services installed
- [ ] Device has internet connection
- [ ] No error messages displayed in app

## Code Changes Made

### AuthViewModel.kt
```kotlin
fun setError(message: String) {
    _authState.value = _authState.value.copy(
        isLoading = false,
        error = message
    )
}
```

### LoginScreen.kt & SignupScreen.kt
```kotlin
val googleSignInLauncher = rememberLauncherForActivityResult(
    contract = ActivityResultContracts.StartActivityForResult()
) { result ->
    if (result.resultCode == Activity.RESULT_OK) {
        val task = GoogleSignIn.getSignedInAccountFromIntent(result.data)
        try {
            val account = task.getResult(ApiException::class.java)
            account?.let { 
                viewModel.signInWithGoogle(it) 
            }
        } catch (e: ApiException) {
            viewModel.setError("Google Sign-In failed: ${e.statusCode} - ${e.message}")
        }
    } else {
        viewModel.setError("Google Sign-In was cancelled")
    }
}
```

## Next Steps

1. Run the app and tap "Sign in with Google"
2. Note any error messages displayed
3. Share the error code/message to get specific help
4. If you see "Developer Error (code 10)", follow the Firebase Console setup steps
5. If no error shows but still stuck, check Logcat for detailed logs

## Files Modified

- `app/src/main/java/com/schepor/gita/presentation/auth/AuthViewModel.kt` - Added setError()
- `app/src/main/java/com/schepor/gita/presentation/auth/LoginScreen.kt` - Better error handling
- `app/src/main/java/com/schepor/gita/presentation/auth/SignupScreen.kt` - Better error handling

## Build Status

✅ BUILD SUCCESSFUL - Error handling improvements ready to test
