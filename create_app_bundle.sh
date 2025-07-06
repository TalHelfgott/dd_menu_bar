#!/bin/bash

# Script to create a proper macOS app bundle

set -e

APP_NAME="Datadog Menu Bar"
APP_BUNDLE="$APP_NAME.app"
BUILD_DIR="build"
EXECUTABLE_NAME="DatadogMenuBar"

echo "🔨 Building macOS app bundle..."

# Build the Swift project first
echo "📦 Building Swift project..."
swift build -c release

# Create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Create app bundle structure
echo "📁 Creating app bundle structure..."
mkdir -p "$BUILD_DIR/$APP_BUNDLE/Contents/MacOS"
mkdir -p "$BUILD_DIR/$APP_BUNDLE/Contents/Resources"

# Copy the executable
echo "📋 Copying executable..."
cp ".build/release/$EXECUTABLE_NAME" "$BUILD_DIR/$APP_BUNDLE/Contents/MacOS/$EXECUTABLE_NAME"

# Create Info.plist
echo "📄 Creating Info.plist..."
cat > "$BUILD_DIR/$APP_BUNDLE/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$EXECUTABLE_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.datadogmenubar.app</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSRequiresAquaSystemAppearance</key>
    <false/>
</dict>
</plist>
EOF

# Create app icon
echo "🎨 Creating app icon..."
if [ ! -f "AppIcon.icns" ]; then
    ./create_icon.sh
fi

# Copy icon to app bundle
if [ -f "AppIcon.icns" ]; then
    cp "AppIcon.icns" "$BUILD_DIR/$APP_BUNDLE/Contents/Resources/"
    echo "✅ Icon added to app bundle"
else
    echo "⚠️  Icon not found, app will use default icon"
fi

echo "✅ App bundle created: $BUILD_DIR/$APP_BUNDLE"
echo ""
echo "🚀 To run the app:"
echo "   open \"$BUILD_DIR/$APP_BUNDLE\""
echo ""
echo "📦 To create a DMG:"
echo "   ./create_dmg.sh" 