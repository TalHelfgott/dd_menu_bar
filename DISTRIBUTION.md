# Distribution Guide

This guide explains how to build and distribute the Datadog Menu Bar application.

## Building for Distribution

### 1. Create App Bundle
```bash
./create_app_bundle.sh
```

This script:
- Builds the Swift project in release mode
- Creates a proper macOS app bundle structure
- Copies the executable to the correct location
- Generates the Info.plist with proper metadata
- Sets up the app for distribution

### 2. Create DMG
```bash
./create_dmg.sh
```

This script:
- Creates a DMG file with the app bundle
- Adds an Applications symlink for easy installation
- Includes a README with installation instructions
- Compresses the DMG for distribution

## App Bundle Structure

The created app bundle has the following structure:
```
Datadog Menu Bar.app/
├── Contents/
│   ├── Info.plist           # App metadata
│   ├── MacOS/
│   │   └── DatadogMenuBar   # Executable
│   └── Resources/           # (empty for now)
```

## Auto-start Behavior

### macOS 13+ (Ventura and later)
- Uses `ServiceManagement` framework
- Registers with Login Items via `SMAppService.mainApp`
- **Appears in System Settings > General > Login Items**
- Users can manage it directly in System Settings

### macOS 12 (Monterey)
- Falls back to Launch Agents
- Creates plist in `~/Library/LaunchAgents/`
- Managed programmatically via `launchctl`

## Distribution Checklist

Before releasing:

- [ ] Test the app bundle on a clean system
- [ ] Verify auto-start works on different macOS versions
- [ ] Test DMG installation process
- [ ] Ensure all Datadog regions work correctly
- [ ] Verify the app appears in Applications after installation
- [ ] Test that Login Items integration works (macOS 13+)

## File Sizes

Typical file sizes:
- Executable: ~2-3 MB
- App Bundle: ~3-4 MB
- DMG: ~150-200 KB (compressed)

## Code Signing (Future)

For wider distribution, consider:
- Developer ID Application certificate
- Notarization for Gatekeeper
- DMG signing for integrity

## Release Process

1. Update version in `create_dmg.sh` (DMG_NAME variable)
2. Update version in `Info.plist` generation
3. Run `./create_app_bundle.sh && ./create_dmg.sh`
4. Test the DMG on a clean system
5. Upload to GitHub releases
6. Update README with download link 