#!/bin/bash

# Cleanup script for Datadog Menu Bar

echo "🧹 Cleaning up Datadog Menu Bar..."

# Kill any running instances
echo "Terminating any running instances..."
pkill -f "DatadogMenuBar" || true

# Unload and remove the Launch Agent
echo "Removing Launch Agent..."
launchctl unload ~/Library/LaunchAgents/com.datadogmenubar.plist 2>/dev/null || true
rm -f ~/Library/LaunchAgents/com.datadogmenubar.plist

echo "✅ Cleanup complete!"
echo ""
echo "You can now safely run the app again:"
echo "   .build/release/DatadogMenuBar" 