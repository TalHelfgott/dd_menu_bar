#!/bin/bash

# Script to create an app icon for Datadog Menu Bar

set -e

ICON_DIR="icon_temp"
ICONSET_DIR="AppIcon.iconset"
ICON_NAME="AppIcon.icns"

echo "🎨 Creating app icon..."

# Create temporary directories
rm -rf "$ICON_DIR" "$ICONSET_DIR"
mkdir -p "$ICON_DIR" "$ICONSET_DIR"

# Create a simple SVG icon representing monitoring/alerts
cat > "$ICON_DIR/icon.svg" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bgGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#4A90E2;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#357ABD;stop-opacity:1" />
    </linearGradient>
    <linearGradient id="chartGradient" x1="0%" y1="100%" x2="0%" y2="0%">
      <stop offset="0%" style="stop-color:#50E3C2;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#B2F5EA;stop-opacity:1" />
    </linearGradient>
  </defs>
  
  <!-- Background circle -->
  <circle cx="512" cy="512" r="480" fill="url(#bgGradient)" stroke="#2C5F8B" stroke-width="16"/>
  
  <!-- Monitor screen -->
  <rect x="256" y="256" width="512" height="320" rx="32" ry="32" fill="#1A1A1A" stroke="#333" stroke-width="8"/>
  
  <!-- Chart bars -->
  <rect x="320" y="480" width="48" height="64" fill="url(#chartGradient)" rx="4"/>
  <rect x="400" y="440" width="48" height="104" fill="url(#chartGradient)" rx="4"/>
  <rect x="480" y="400" width="48" height="144" fill="url(#chartGradient)" rx="4"/>
  <rect x="560" y="360" width="48" height="184" fill="url(#chartGradient)" rx="4"/>
  <rect x="640" y="420" width="48" height="124" fill="url(#chartGradient)" rx="4"/>
  
  <!-- Alert indicator -->
  <circle cx="680" cy="300" r="40" fill="#FF6B6B" stroke="#FFF" stroke-width="6"/>
  <text x="680" y="315" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="36" font-weight="bold">!</text>
  
  <!-- Datadog dog silhouette (simplified) -->
  <path d="M400 650 Q420 640 440 650 Q460 640 480 650 L480 680 Q470 690 460 680 Q450 690 440 680 Q430 690 420 680 Q410 690 400 680 Z" fill="#8B5A3C"/>
  <circle cx="430" cy="665" r="8" fill="#654321"/>
  <circle cx="450" cy="665" r="8" fill="#654321"/>
  <path d="M435 675 Q440 680 445 675" stroke="#654321" stroke-width="2" fill="none"/>
</svg>
EOF

# Function to create PNG from SVG at specific size
create_png() {
    local size=$1
    local output=$2
    
    # Use rsvg-convert if available, otherwise try other methods
    if command -v rsvg-convert >/dev/null 2>&1; then
        rsvg-convert -w $size -h $size "$ICON_DIR/icon.svg" -o "$output"
    elif command -v inkscape >/dev/null 2>&1; then
        inkscape -w $size -h $size "$ICON_DIR/icon.svg" -o "$output"
    elif command -v convert >/dev/null 2>&1; then
        convert -size ${size}x${size} "$ICON_DIR/icon.svg" "$output"
    else
        echo "⚠️  No SVG converter found. Installing librsvg..."
        if command -v brew >/dev/null 2>&1; then
            brew install librsvg
            rsvg-convert -w $size -h $size "$ICON_DIR/icon.svg" -o "$output"
        else
            echo "❌ Cannot create PNG icons. Please install librsvg, inkscape, or imagemagick"
            echo "   brew install librsvg"
            exit 1
        fi
    fi
}

# Create all required icon sizes
echo "📐 Generating icon sizes..."
create_png 16 "$ICONSET_DIR/icon_16x16.png"
create_png 32 "$ICONSET_DIR/icon_16x16@2x.png"
create_png 32 "$ICONSET_DIR/icon_32x32.png"
create_png 64 "$ICONSET_DIR/icon_32x32@2x.png"
create_png 128 "$ICONSET_DIR/icon_128x128.png"
create_png 256 "$ICONSET_DIR/icon_128x128@2x.png"
create_png 256 "$ICONSET_DIR/icon_256x256.png"
create_png 512 "$ICONSET_DIR/icon_256x256@2x.png"
create_png 512 "$ICONSET_DIR/icon_512x512.png"
create_png 1024 "$ICONSET_DIR/icon_512x512@2x.png"

# Create the .icns file
echo "📦 Creating .icns file..."
iconutil -c icns "$ICONSET_DIR" -o "$ICON_NAME"

# Clean up temporary files
rm -rf "$ICON_DIR" "$ICONSET_DIR"

echo "✅ Icon created: $ICON_NAME"
echo "🎯 Icon features:"
echo "   • Modern gradient design"
echo "   • Monitoring dashboard representation"
echo "   • Alert indicator (red circle with !)"
echo "   • Datadog-inspired elements"
echo "   • All required macOS icon sizes" 