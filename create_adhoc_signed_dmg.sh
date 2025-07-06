#!/bin/bash

# Script to create an ad-hoc signed DMG file
# This provides some signature but won't work for all users

set -e

APP_NAME="Datadog Menu Bar"
APP_BUNDLE="$APP_NAME.app"
BUILD_DIR="build"
DMG_NAME="DatadogMenuBar-v1.0.0"
DMG_DIR="dmg_temp"

echo "📦 Creating ad-hoc signed DMG for $APP_NAME..."

# Check if app bundle exists
if [ ! -d "$BUILD_DIR/$APP_BUNDLE" ]; then
    echo "❌ App bundle not found. Run ./create_app_bundle.sh first"
    exit 1
fi

# Ad-hoc sign the app bundle (no Developer account needed)
echo "🔐 Ad-hoc signing app bundle..."
codesign --force --deep --sign - "$BUILD_DIR/$APP_BUNDLE"

# Verify the signature
echo "✅ Verifying ad-hoc signature..."
codesign --verify --deep --strict "$BUILD_DIR/$APP_BUNDLE"

# Create temporary DMG directory
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"

# Copy signed app bundle to DMG directory
echo "📋 Copying signed app bundle..."
cp -R "$BUILD_DIR/$APP_BUNDLE" "$DMG_DIR/"

# Create Applications symlink for easy installation
echo "🔗 Creating Applications symlink..."
ln -s /Applications "$DMG_DIR/Applications"

# Create a README file with installation instructions
echo "📄 Creating README..."
cat > "$DMG_DIR/README.txt" << EOF
Datadog Menu Bar v1.0.0 (Ad-hoc Signed)

IMPORTANT: This app is ad-hoc signed and may still be blocked by macOS Gatekeeper.

Installation:
1. Drag "Datadog Menu Bar.app" to the Applications folder
2. If macOS blocks the app, right-click it and select "Open"
3. Click "Open" when prompted about the unidentified developer

Alternative if still blocked:
1. Open Terminal and run: xattr -d com.apple.quarantine "/Applications/Datadog Menu Bar.app"
2. Then launch the app normally

Setup:
1. Click the menu bar icon to configure your Datadog credentials
2. Enter your API key and Application key
3. Select your Datadog region
4. Click "Save" to start monitoring

For more information, visit: https://github.com/your-repo/dd_menu_bar
EOF

# Create the DMG
echo "💾 Creating DMG file..."
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov -format UDZO \
    "$BUILD_DIR/$DMG_NAME-adhoc.dmg"

# Clean up temporary directory
rm -rf "$DMG_DIR"

echo "✅ Ad-hoc signed DMG created: $BUILD_DIR/$DMG_NAME-adhoc.dmg"
echo ""
echo "⚠️  Note: This ad-hoc signing may still be blocked by some macOS versions."
echo "📋 Include the README.txt instructions for users." 