#!/bin/bash

# Build script for Gita Android app
# This ensures we're building from the correct directory

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Building Gita App...${NC}"

# Navigate to project root
cd /Users/anshul/Documents/GitHub/gita || exit 1

echo -e "${YELLOW}Current directory: $(pwd)${NC}"
echo -e "${YELLOW}Cleaning previous build...${NC}"

# Clean build
./gradlew clean

echo -e "${YELLOW}Building debug APK...${NC}"

# Build debug APK
./gradlew assembleDebug

# Check if build succeeded
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Build SUCCESS!${NC}"
    echo -e "${GREEN}APK location: app/build/outputs/apk/debug/app-debug.apk${NC}"
    
    # Get APK size
    if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
        SIZE=$(du -h app/build/outputs/apk/debug/app-debug.apk | cut -f1)
        echo -e "${GREEN}APK size: ${SIZE}${NC}"
    fi
else
    echo -e "${RED}❌ Build FAILED!${NC}"
    echo -e "${RED}Check the error messages above.${NC}"
    exit 1
fi
