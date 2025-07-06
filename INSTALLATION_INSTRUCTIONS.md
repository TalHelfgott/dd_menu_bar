# Installation Instructions for Datadog Menu Bar

## Download and Install

### Method 1: If you get "damaged and can't be opened" error

This error occurs because the app isn't code-signed. Here's how to install it safely:

1. **Download the DMG** from the GitHub releases page
2. **Open Terminal** (Applications → Utilities → Terminal)
3. **Remove the quarantine attribute** from the downloaded DMG:
   ```bash
   xattr -d com.apple.quarantine ~/Downloads/DatadogMenuBar-v1.0.0.dmg
   ```
4. **Open the DMG** - it should now open without error
5. **Drag the app** to Applications folder
6. **Launch the app** from Applications or Spotlight

### Method 2: Alternative bypass

If Method 1 doesn't work:

1. **Download and open the DMG** (ignore the error for now)
2. **Copy the app** to Applications folder
3. **Right-click** on "Datadog Menu Bar.app" in Applications
4. **Select "Open"** from the context menu
5. **Click "Open"** when prompted about the unidentified developer

### Method 3: System Settings (macOS 13+)

1. Try to open the app normally
2. Go to **System Settings** → **Privacy & Security**
3. Find the blocked app message and click **"Open Anyway"**
4. Confirm by clicking **"Open"**

## First Launch Setup

After installation:

1. **Click the menu bar icon** (looks like a monitor with charts)
2. **Click "Settings"** to configure your Datadog credentials
3. **Enter your API key and Application key**
4. **Select your Datadog region**
5. **Click "Save"** to start monitoring

## Features

- 🔄 **Real-time monitoring** - Updates every 30 seconds
- 🌍 **All Datadog regions** - US1, EU1, US3, US5, AP1, GOV
- 🚀 **Auto-start option** - Launch at login
- 🎨 **Visual indicators** - Menu bar icon changes based on alert count
- 📊 **Alert details** - Click to see detailed alert information

## Troubleshooting

### "Permission denied" or similar errors
- Make sure you copied the app to `/Applications` folder
- Try restarting your computer after installation

### App doesn't start
- Check Console.app for error messages
- Make sure you have internet connection for API calls

### Menu bar icon doesn't appear
- The app might be running in the background
- Check Activity Monitor for "DatadogMenuBar" process
- Try quitting and relaunching the app

## Security Note

This app is currently unsigned, which is why macOS blocks it initially. The app is open source and safe to use. For production distribution, the app should be properly code-signed and notarized through Apple's Developer Program. 