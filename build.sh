#!/bin/bash

set -e

APP_NAME="OrchestratorCaffeine"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

echo "🎼 Building Orchestrator Caffeine..."

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Create app bundle structure
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Compile Swift code
echo "📦 Compiling..."
swiftc OrchestratorCaffeine.swift -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# Copy GIF to Resources
if [ -f "assets/pet.gif" ]; then
    cp "assets/pet.gif" "$APP_BUNDLE/Contents/Resources/pet.gif"
    echo "✅ Bundled pet.gif"
else
    echo "⚠️  Warning: assets/pet.gif not found"
fi

# Copy icon to Resources
if [ -f "assets/icon.png" ]; then
    cp "assets/icon.png" "$APP_BUNDLE/Contents/Resources/icon.png"
    echo "✅ Bundled icon.png"
    
    # Create icns for app icon
    mkdir -p "$APP_BUNDLE/Contents/Resources/AppIcon.iconset"
    sips -z 16 16 "assets/icon.png" --out "$APP_BUNDLE/Contents/Resources/AppIcon.iconset/icon_16x16.png" > /dev/null 2>&1
    sips -z 32 32 "assets/icon.png" --out "$APP_BUNDLE/Contents/Resources/AppIcon.iconset/icon_16x16@2x.png" > /dev/null 2>&1
    sips -z 32 32 "assets/icon.png" --out "$APP_BUNDLE/Contents/Resources/AppIcon.iconset/icon_32x32.png" > /dev/null 2>&1
    sips -z 64 64 "assets/icon.png" --out "$APP_BUNDLE/Contents/Resources/AppIcon.iconset/icon_32x32@2x.png" > /dev/null 2>&1
    sips -z 128 128 "assets/icon.png" --out "$APP_BUNDLE/Contents/Resources/AppIcon.iconset/icon_128x128.png" > /dev/null 2>&1
    sips -z 256 256 "assets/icon.png" --out "$APP_BUNDLE/Contents/Resources/AppIcon.iconset/icon_128x128@2x.png" > /dev/null 2>&1
    sips -z 256 256 "assets/icon.png" --out "$APP_BUNDLE/Contents/Resources/AppIcon.iconset/icon_256x256.png" > /dev/null 2>&1
    sips -z 512 512 "assets/icon.png" --out "$APP_BUNDLE/Contents/Resources/AppIcon.iconset/icon_256x256@2x.png" > /dev/null 2>&1
    sips -z 512 512 "assets/icon.png" --out "$APP_BUNDLE/Contents/Resources/AppIcon.iconset/icon_512x512.png" > /dev/null 2>&1
    
    iconutil -c icns "$APP_BUNDLE/Contents/Resources/AppIcon.iconset" -o "$APP_BUNDLE/Contents/Resources/AppIcon.icns" > /dev/null 2>&1
    rm -rf "$APP_BUNDLE/Contents/Resources/AppIcon.iconset"
    echo "✅ Created app icon"
else
    echo "⚠️  Warning: assets/icon.png not found"
fi

# Create Info.plist
cat > "$APP_BUNDLE/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.yourcompany.orchestratorcaffeine</string>
    <key>CFBundleName</key>
    <string>Orchestrator Caffeine</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "✅ Build complete: $APP_BUNDLE"
echo ""
echo "To test locally:"
echo "  open $APP_BUNDLE"
echo ""
echo "To distribute:"
echo "  cd $BUILD_DIR && zip -r $APP_NAME.zip $APP_NAME.app"
echo "  Upload to GitHub Releases"
