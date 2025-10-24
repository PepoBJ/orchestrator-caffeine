#!/bin/bash

set -e

APP_NAME="OrchestratorCaffeine"
APP_PATH="build/$APP_NAME.app"
ZIP_FILE="build/$APP_NAME.zip"

echo "📦 Creating release package..."

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ App not found. Run ./build.sh first"
    exit 1
fi

# Clean up
rm -f "$ZIP_FILE"

# Create zip with just the app
cd build
zip -r "$APP_NAME.zip" "$APP_NAME.app"
cd ..

echo "✅ Release package created: $ZIP_FILE"
echo ""
echo "Ready to upload to GitHub Releases!"
