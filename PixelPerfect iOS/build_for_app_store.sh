#!/bin/bash

# PixelPerfect iOS - App Store Release Build Script

echo "🚀 Building PixelPerfect iOS for App Store Release..."

# Set project directory
PROJECT_DIR="/Users/waderzhang/Documents/PixelPerfect Project/PixelPerfect iOS"
cd "$PROJECT_DIR"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
xcodebuild clean -scheme "PixelPerfect iOS" -configuration Release

# Archive for App Store (Universal Binary)
echo "📦 Creating App Store archive..."
xcodebuild archive \
    -scheme "PixelPerfect iOS" \
    -configuration Release \
    -destination "generic/platform=iOS" \
    -archivePath "./build/PixelPerfect_iOS.xcarchive" \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM="YOUR_TEAM_ID_HERE"

# Check if archive was successful
if [ $? -eq 0 ]; then
    echo "✅ Archive created successfully!"
    echo "📍 Location: $PROJECT_DIR/build/PixelPerfect_iOS.xcarchive"
    echo ""
    echo "Next steps:"
    echo "1. Open Xcode"
    echo "2. Window → Organizer"
    echo "3. Select your archive"
    echo "4. Click 'Distribute App'"
    echo "5. Choose 'App Store Connect'"
else
    echo "❌ Archive failed. Please check the errors above."
    exit 1
fi
