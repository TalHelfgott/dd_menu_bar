import Cocoa

// Check if another instance is already running
let runningApps = NSWorkspace.shared.runningApplications
let currentAppName = ProcessInfo.processInfo.processName
let existingInstances = runningApps.filter { $0.localizedName == currentAppName && $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }

if !existingInstances.isEmpty {
    print("Another instance of DatadogMenuBar is already running. Exiting.")
    exit(0)
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

app.setActivationPolicy(.accessory)
app.run() 