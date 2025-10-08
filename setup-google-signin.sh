#!/bin/bash

# Google Sign-In Setup Script for Firebase
# This script helps you configure Google Sign-In for your Android app

echo "🔥 Firebase Google Sign-In Setup Helper"
echo "========================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Get SHA-1 fingerprint
echo "📋 Step 1: Getting your SHA-1 fingerprint..."
echo ""
echo "Debug keystore SHA-1:"
echo "-------------------"
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep -A 1 "SHA1:"

echo ""
echo "${YELLOW}⚠️  Copy the SHA1 fingerprint above${NC}"
echo ""

# Step 2: Firebase Console Instructions
echo "📋 Step 2: Configure Firebase Console"
echo "======================================"
echo ""
echo "1. Open Firebase Console:"
echo "   ${GREEN}https://console.firebase.google.com/project/gita-58861${NC}"
echo ""
echo "2. Enable Google Sign-In:"
echo "   → Go to: Authentication → Sign-in method"
echo "   → Click 'Google' provider"
echo "   → Toggle 'Enable' to ON"
echo "   → Set support email (your email)"
echo "   → Click 'Save'"
echo ""
echo "3. Add SHA-1 Fingerprint:"
echo "   → Go to: Project Settings (⚙️ icon)"
echo "   → Scroll to 'Your apps' section"
echo "   → Click on your Android app (com.schepor.gita)"
echo "   → Click 'Add fingerprint' button"
echo "   → Paste the SHA1 fingerprint from above"
echo "   → Click 'Save'"
echo ""
echo "4. Download Updated google-services.json:"
echo "   → In Project Settings, scroll down"
echo "   → Click 'google-services.json' download button"
echo "   → Replace the file at: app/google-services.json"
echo ""

# Step 3: Wait for user
echo "Press ENTER when you've completed all steps above..."
read

# Step 4: Verify oauth_client exists
echo ""
echo "📋 Step 3: Verifying Configuration"
echo "==================================="
echo ""

if [ -f "app/google-services.json" ]; then
    oauth_count=$(grep -c '"client_type": 3' app/google-services.json)
    
    if [ "$oauth_count" -gt 0 ]; then
        echo "${GREEN}✅ Web OAuth client found in google-services.json${NC}"
        echo ""
        echo "OAuth Client ID:"
        grep -A 2 '"client_type": 3' app/google-services.json | grep 'client_id' | sed 's/.*"client_id": "\(.*\)".*/\1/'
    else
        echo "${RED}❌ No Web OAuth client found in google-services.json${NC}"
        echo ""
        echo "This means Google Sign-In wasn't properly enabled in Firebase Console."
        echo "Please go back and make sure you:"
        echo "1. Enabled Google Sign-In provider"
        echo "2. Added SHA-1 fingerprint"
        echo "3. Downloaded the NEW google-services.json after adding SHA-1"
        echo ""
        echo "Then run this script again."
        exit 1
    fi
else
    echo "${RED}❌ google-services.json not found${NC}"
    exit 1
fi

# Step 5: Update code with correct client ID
echo ""
echo "📋 Step 4: Next Steps"
echo "===================="
echo ""
echo "1. Rebuild the app:"
echo "   ${GREEN}./gradlew clean assembleDebug${NC}"
echo ""
echo "2. Install on device:"
echo "   ${GREEN}./gradlew installDebug${NC}"
echo ""
echo "3. Test Google Sign-In!"
echo ""
echo "${GREEN}✅ Setup complete!${NC}"
echo ""
