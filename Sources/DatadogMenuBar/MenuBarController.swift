import Cocoa
import SwiftUI

class MenuBarController: NSObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var datadogAPI: DatadogAPI
    private var timer: Timer?
    private var alertCount: Int = 0
    
    override init() {
        self.datadogAPI = DatadogAPI()
        super.init()
        setupMenuBar()
        setupPopover()
        startPeriodicUpdates()
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let statusItem = statusItem else { return }
        
        // Set initial icon
        updateIcon(alertCount: 0)
        
        // Set up click handler - we'll handle both left and right clicks
        statusItem.button?.action = #selector(statusItemClicked)
        statusItem.button?.target = self
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 300)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: AlertsView(datadogAPI: datadogAPI)
        )
    }
    
    private func startPeriodicUpdates() {
        // Update every 30 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            self.refreshAlerts()
        }
        
        // Initial fetch
        refreshAlerts()
    }
    
    private func updateIcon(alertCount: Int) {
        guard let statusItem = statusItem else { return }
        
        let iconName: String
        let title: String
        
        switch alertCount {
        case 0:
            iconName = "checkmark.circle.fill"
            title = "0"
        case 1...5:
            iconName = "exclamationmark.triangle.fill"
            title = "\(alertCount)"
        default:
            iconName = "exclamationmark.octagon.fill"
            title = "\(alertCount)"
        }
        
        // Create attributed string with icon and count
        let image = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)
        image?.size = NSSize(width: 18, height: 18)
        
        // Set template rendering for proper menu bar appearance
        image?.isTemplate = true
        
        if alertCount > 0 {
            statusItem.button?.title = title
            statusItem.button?.image = image
        } else {
            statusItem.button?.title = ""
            statusItem.button?.image = image
        }
        
        self.alertCount = alertCount
    }
    
    @objc private func statusItemClicked() {
        guard statusItem != nil else { return }
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            // Right click - show context menu
            showContextMenu()
        } else {
            // Left click - toggle popover
            togglePopover()
        }
    }
    
    private func togglePopover() {
        guard let statusItem = statusItem else { return }
        
        if popover?.isShown == true {
            popover?.performClose(nil)
        } else {
            popover?.show(relativeTo: statusItem.button?.bounds ?? NSRect.zero,
                         of: statusItem.button ?? NSView(),
                         preferredEdge: .minY)
        }
    }
    
    private func showContextMenu() {
        guard let statusItem = statusItem else { return }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(refreshAlerts), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApplication), keyEquivalent: "q"))
        
        // Set target for all menu items
        for item in menu.items {
            item.target = self
        }
        
        // Use modern approach for showing menu
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }
    
    @objc private func refreshAlerts() {
        Task {
            do {
                let alerts = try await datadogAPI.fetchAlerts()
                await MainActor.run {
                    updateIcon(alertCount: alerts.count)
                }
            } catch {
                print("Error fetching alerts: \(error)")
                await MainActor.run {
                    updateIcon(alertCount: -1) // Error state
                }
            }
        }
    }
    

    
    @objc private func quitApplication() {
        NSApplication.shared.terminate(nil)
    }
    
    deinit {
        timer?.invalidate()
    }
} 