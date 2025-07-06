#!/bin/bash

# Script to create a DMG file for distribution

set -e

APP_NAME="Datadog Menu Bar"
APP_BUNDLE="$APP_NAME.app"
BUILD_DIR="build"
DMG_NAME="DatadogMenuBar-v1.0.0"
DMG_DIR="dmg_temp"

echo "📦 Creating DMG for $APP_NAME..."

# Check if app bundle exists
if [ ! -d "$BUILD_DIR/$APP_BUNDLE" ]; then
    echo "❌ App bundle not found. Run ./create_app_bundle.sh first"
    exit 1
fi

# Create temporary DMG directory
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"

# Copy app bundle to DMG directory
echo "📋 Copying app bundle..."
cp -R "$BUILD_DIR/$APP_BUNDLE" "$DMG_DIR/"

# Create Applications symlink for easy installation
echo "🔗 Creating Applications symlink..."
ln -s /Applications "$DMG_DIR/Applications"

# Create a README file
echo "📄 Creating README..."
cat > "$DMG_DIR/README.txt" << EOF
Datadog Menu Bar v1.0.0

Installation:
1. Drag "Datadog Menu Bar.app" to the Applications folder
2. Launch the app from Applications
3. Click the menu bar icon to configure your Datadog credentials

Features:
- Real-time Datadog alert monitoring
- Support for all Datadog regions (US1, EU1, US3, US5, AP1, GOV)
- Auto-start at login option
- Menu bar integration with visual indicators

For more information, visit: https://github.com/your-repo/dd_menu_bar
EOF

# Create the DMG
echo "💾 Creating DMG file..."
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov -format UDZO \
    "$BUILD_DIR/$DMG_NAME.dmg"

# Clean up temporary directory
rm -rf "$DMG_DIR"

echo "✅ DMG created: $BUILD_DIR/$DMG_NAME.dmg"
echo ""
echo "🎉 Your app is ready for distribution!"
echo "📎 Users can now:"
echo "   1. Download the DMG file"
echo "   2. Open it and drag the app to Applications"
echo "   3. Launch from Applications or Spotlight" 