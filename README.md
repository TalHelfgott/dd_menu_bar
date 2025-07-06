# Datadog Menu Bar

A macOS menu bar application that displays your Datadog alerts at a glance.

## Features

- **Menu Bar Integration**: Shows alert count and status directly in your macOS menu bar
- **Visual Indicators**: Icon changes based on alert severity and count
- **Alert List**: Click the menu bar icon to view detailed alert information
- **Real-time Updates**: Automatically refreshes alerts every 30 seconds
- **Multi-Region Support**: Works with all Datadog regions (US1, EU1, US3, US5, AP1, GOV)
- **Auto-start**: Option to automatically start the app when you log in to macOS
- **Datadog Integration**: Direct link to open Datadog in your browser (region-aware)
- **Secure Configuration**: Store API keys securely using macOS UserDefaults

## Installation

### Requirements
- macOS 12.0 or later
- Datadog account with API access

### Option 1: Download DMG (Recommended)

1. Download the latest DMG from releases
2. Open the DMG file
3. Drag "Datadog Menu Bar.app" to the Applications folder
4. Launch the app from Applications or Spotlight

### Option 2: Build from Source

1. Clone this repository:
```bash
git clone <repository-url>
cd dd_menu_bar
```

2. Create app bundle and DMG:
```bash
./create_app_bundle.sh  # Creates the .app bundle
./create_dmg.sh         # Creates the DMG for distribution
```

3. Install the app:
```bash
open "build/Datadog Menu Bar.app"
```

### Option 3: Development Mode

1. Build and run directly:
```bash
./build.sh
.build/release/DatadogMenuBar
```

If you encounter issues with multiple instances or auto-start problems:
```bash
./cleanup.sh
```

## Configuration

### Getting Your Datadog API Keys

1. Log into your Datadog account
2. Navigate to **Organization Settings** > **API Keys**
3. Create or copy your **API Key**
4. Navigate to **Organization Settings** > **Application Keys**
5. Create or copy your **Application Key**

### Datadog Regions

The application supports all Datadog regions:

- **US1 (Default)**: `api.datadoghq.com` - Original US region
- **EU1**: `api.datadoghq.eu` - Europe region
- **US3**: `api.us3.datadoghq.com` - US3 region
- **US5**: `api.us5.datadoghq.com` - US5 region  
- **AP1**: `api.ap1.datadoghq.com` - Asia Pacific region
- **GOV**: `api.ddog-gov.com` - Government region

If you're in Europe, make sure to select **EU1** in the settings. You can find your region by looking at the URL when you're logged into Datadog (e.g., `app.datadoghq.eu` indicates EU1 region).

### Setting Up the Application

#### Option 1: Using the GUI
1. Launch the application
2. Click the menu bar icon
3. Click the gear icon (⚙️) to open settings
4. Select your Datadog region (US1, EU1, etc.)
5. Toggle "Auto-start at login" if you want the app to start automatically
6. Enter your API Key and Application Key
7. Click "Save"

#### Option 2: Using Environment Variables
Set the following environment variables before launching the app:
```bash
export DATADOG_API_KEY="your-api-key-here"
export DATADOG_APP_KEY="your-app-key-here"
export DATADOG_REGION="EU1"  # Optional: US1, EU1, US3, US5, AP1, GOV (default: US1)
```

## Usage

### Menu Bar Icons

The menu bar icon changes based on your alert status:

- **✅ Green Checkmark**: No active alerts
- **⚠️ Orange Triangle**: 1-5 active alerts
- **🛑 Red Octagon**: 6+ active alerts

### Alert List

Click the menu bar icon to view:
- List of all active alerts
- Alert names, states, and messages
- Associated tags
- Quick refresh button
- Link to open Datadog in your browser

### Right-Click Menu

Right-click the menu bar icon for quick actions:
- **Refresh**: Manually refresh alerts
- **Quit**: Exit the application

### Auto-start Feature

The application can automatically start when you log in to macOS:
- Enable/disable via the settings panel (gear icon ⚙️)
- **macOS 13+**: Uses modern Login Items (appears in System Settings > General > Login Items)
- **macOS 12**: Uses Launch Agents for compatibility
- Automatically manages the registration when toggled
- Survives system restarts and user logouts

## Troubleshooting

### Common Issues

**No alerts showing despite having active alerts in Datadog:**
- Verify your API keys are correct
- **Check that you've selected the correct region** (EU1 for Europe, US1 for US, etc.)
- Check that your API key has the necessary permissions
- Ensure your Datadog organization is accessible

**"Missing credentials" error:**
- Make sure you've entered both API Key and Application Key
- Check that the keys are not empty or contain only whitespace

**Network/API errors:**
- Verify your internet connection
- Check Datadog's service status
- Ensure your API keys haven't expired

**Multiple instances or auto-start issues:**
- Run the cleanup script: `./cleanup.sh`
- This will terminate any running instances and remove problematic Launch Agents
- Then restart the app normally

### Debug Mode

To run with debug logging:
```bash
DATADOG_DEBUG=1 .build/release/DatadogMenuBar
```

If you encounter issues with multiple instances or auto-start problems:
```bash
./cleanup.sh
```

## Security

- API keys are stored securely in macOS UserDefaults
- Network requests are made over HTTPS
- No sensitive data is logged (except in debug mode)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is open source and available under the MIT License.

## Support

For issues and feature requests, please create an issue in the GitHub repository.

---

**Note**: This application requires valid Datadog API credentials to function. Make sure you have the necessary permissions in your Datadog organization to access monitor data. 