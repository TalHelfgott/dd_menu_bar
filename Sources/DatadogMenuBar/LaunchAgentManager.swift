import Foundation
import ServiceManagement

class LaunchAgentManager {
    private let launchAgentLabel = "com.datadogmenubar.agent"
    private let launchAgentPath = NSHomeDirectory() + "/Library/LaunchAgents/com.datadogmenubar.plist"
    
    func isAutoStartEnabled() -> Bool {
        // Check modern Login Items first (macOS 13+)
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }
        
        // Fallback to Launch Agent check
        return FileManager.default.fileExists(atPath: launchAgentPath)
    }
    
    func enableAutoStart() -> Bool {
        // Use modern Login Items API for macOS 13+
        if #available(macOS 13.0, *) {
            do {
                try SMAppService.mainApp.register()
                return true
            } catch {
                print("Failed to register with Login Items: \(error)")
                // Fall through to legacy method
            }
        }
        
        // Legacy Launch Agent method for older macOS versions
        guard let executablePath = getExecutablePath() else {
            print("Could not determine executable path")
            return false
        }
        
        let launchAgentContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>\(launchAgentLabel)</string>
            <key>ProgramArguments</key>
            <array>
                <string>\(executablePath)</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
            <key>StandardOutPath</key>
            <string>/dev/null</string>
            <key>StandardErrorPath</key>
            <string>/dev/null</string>
        </dict>
        </plist>
        """
        
        do {
            // Create LaunchAgents directory if it doesn't exist
            let launchAgentsDir = NSHomeDirectory() + "/Library/LaunchAgents"
            try FileManager.default.createDirectory(atPath: launchAgentsDir, withIntermediateDirectories: true)
            
            // Write the plist file
            try launchAgentContent.write(toFile: launchAgentPath, atomically: true, encoding: .utf8)
            
            // Load the launch agent
            let task = Process()
            task.launchPath = "/bin/launchctl"
            task.arguments = ["load", launchAgentPath]
            task.launch()
            task.waitUntilExit()
            
            return task.terminationStatus == 0
        } catch {
            print("Error creating launch agent: \(error)")
            return false
        }
    }
    
    func disableAutoStart() -> Bool {
        // Use modern Login Items API for macOS 13+
        if #available(macOS 13.0, *) {
            do {
                try SMAppService.mainApp.unregister()
                return true
            } catch {
                print("Failed to unregister from Login Items: \(error)")
                // Fall through to legacy method
            }
        }
        
        // Legacy Launch Agent method
        guard FileManager.default.fileExists(atPath: launchAgentPath) else {
            return true // Already disabled
        }
        
        // Unload the launch agent
        let unloadTask = Process()
        unloadTask.launchPath = "/bin/launchctl"
        unloadTask.arguments = ["unload", launchAgentPath]
        unloadTask.launch()
        unloadTask.waitUntilExit()
        
        // Remove the plist file
        do {
            try FileManager.default.removeItem(atPath: launchAgentPath)
            return true
        } catch {
            print("Error removing launch agent: \(error)")
            return false
        }
    }
    
    func forceCleanup() {
        // Force unload any existing agent
        let unloadTask = Process()
        unloadTask.launchPath = "/bin/launchctl"
        unloadTask.arguments = ["unload", launchAgentPath]
        unloadTask.launch()
        unloadTask.waitUntilExit()
        
        // Remove the plist file if it exists
        if FileManager.default.fileExists(atPath: launchAgentPath) {
            try? FileManager.default.removeItem(atPath: launchAgentPath)
        }
    }
    
    private func getExecutablePath() -> String? {
        // Get the path of the currently running executable
        let executablePath = ProcessInfo.processInfo.arguments[0]
        
        // If we're running from an app bundle, prefer the Applications path
        let bundlePath = Bundle.main.bundlePath
        if bundlePath.contains(".app") && bundlePath.hasPrefix("/Applications/") {
            return bundlePath + "/Contents/MacOS/DatadogMenuBar"
        }
        
        // If running from app bundle elsewhere, use that path
        if bundlePath.contains(".app") {
            return bundlePath + "/Contents/MacOS/DatadogMenuBar"
        }
        
        // Fallback to current executable path (development mode)
        if executablePath.hasPrefix("/") {
            return executablePath
        } else {
            let currentDirectory = FileManager.default.currentDirectoryPath
            return currentDirectory + "/" + executablePath
        }
    }
} 