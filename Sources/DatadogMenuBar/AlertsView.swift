import SwiftUI

struct AlertsView: View {
    @ObservedObject var datadogAPI: DatadogAPI
    @State private var showingSettings = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text("Datadog Alerts")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    Task {
                        do {
                            _ = try await datadogAPI.fetchAlerts()
                        } catch {
                            print("Error refreshing alerts: \(error)")
                        }
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                }
                .buttonStyle(PlainButtonStyle())
                .help("Refresh alerts")
                
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gear")
                        .font(.system(size: 12))
                }
                .buttonStyle(PlainButtonStyle())
                .help("Settings")
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            Divider()
            
            // Content
            if datadogAPI.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading alerts...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else if let error = datadogAPI.error {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text("Error")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }
                    
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    if !datadogAPI.hasValidCredentials() {
                        Button("Configure API Keys") {
                            showingSettings = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else if datadogAPI.alerts.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.green)
                    
                    Text("All Clear!")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Text("No active alerts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(datadogAPI.alerts) { alert in
                            AlertRow(alert: alert)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(maxHeight: 250)
            }
            
            // Footer
            if !datadogAPI.alerts.isEmpty {
                Divider()
                
                HStack {
                    Text("\(datadogAPI.alerts.count) active alert\(datadogAPI.alerts.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("Open Datadog") {
                        let region = datadogAPI.getCurrentRegion()
                        if let url = URL(string: region.webURL) {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .frame(width: 400, height: 300)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showingSettings) {
            SettingsView(datadogAPI: datadogAPI, isPresented: $showingSettings)
        }
    }
}

struct AlertRow: View {
    let alert: DatadogAlert
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // Status indicator
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                
                Text(alert.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer()
                
                Text(alert.state.rawValue.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(4)
            }
            
            if !alert.message.isEmpty {
                Text(alert.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            if !alert.tags.isEmpty {
                HStack {
                    ForEach(alert.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(2)
                    }
                    
                    if alert.tags.count > 3 {
                        Text("+\(alert.tags.count - 3)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
    
    private var statusColor: Color {
        switch alert.state {
        case .alert:
            return .red
        case .warn:
            return .orange
        case .noData:
            return .gray
        case .ok:
            return .green
        }
    }
}

struct SettingsView: View {
    @ObservedObject var datadogAPI: DatadogAPI
    @Binding var isPresented: Bool
    @State private var apiKey: String = ""
    @State private var appKey: String = ""
    @State private var selectedRegion: DatadogRegion = .us1
    @State private var autoStartEnabled: Bool = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let launchAgentManager = LaunchAgentManager()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Datadog API Configuration")
                .font(.headline)
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Region")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Picker("Region", selection: $selectedRegion) {
                    ForEach(DatadogRegion.allCases, id: \.self) { region in
                        Text(region.displayName).tag(region)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Auto-start at login")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Toggle("", isOn: $autoStartEnabled)
                        .onChange(of: autoStartEnabled) { newValue in
                            handleAutoStartToggle(newValue)
                        }
                }
                
                Text("Automatically start the app when you log in to macOS")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("API Key")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                SecureField("Enter your Datadog API key", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Application Key")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                SecureField("Enter your Datadog Application key", text: $appKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Text("You can find your API keys in your Datadog account settings.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Save") {
                    if !apiKey.isEmpty && !appKey.isEmpty {
                        datadogAPI.saveCredentials(apiKey: apiKey, appKey: appKey, region: selectedRegion)
                        
                        // Refresh alerts with new credentials
                        Task {
                            do {
                                _ = try await datadogAPI.fetchAlerts()
                            } catch {
                                print("Error fetching alerts after saving credentials: \(error)")
                            }
                        }
                        
                        // Close the settings sheet
                        isPresented = false
                    } else {
                        alertMessage = "Please enter both API key and Application key."
                        showingAlert = true
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(apiKey.isEmpty || appKey.isEmpty)
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 400, height: 350)
        .alert("Settings", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            // Load existing credentials if available
            if let savedApiKey = UserDefaults.standard.string(forKey: "DatadogAPIKey") {
                apiKey = savedApiKey
            }
            if let savedAppKey = UserDefaults.standard.string(forKey: "DatadogAppKey") {
                appKey = savedAppKey
            }
            // Load saved region
            selectedRegion = datadogAPI.getCurrentRegion()
            // Load auto-start status
            autoStartEnabled = launchAgentManager.isAutoStartEnabled()
        }
    }
    
    private func handleAutoStartToggle(_ enabled: Bool) {
        if enabled {
            let success = launchAgentManager.enableAutoStart()
            if !success {
                // Revert the toggle if it failed
                DispatchQueue.main.async {
                    autoStartEnabled = false
                }
                alertMessage = "Failed to enable auto-start. Please try again."
                showingAlert = true
            }
        } else {
            let success = launchAgentManager.disableAutoStart()
            if !success {
                // Revert the toggle if it failed
                DispatchQueue.main.async {
                    autoStartEnabled = true
                }
                alertMessage = "Failed to disable auto-start. Please try again."
                showingAlert = true
            }
        }
    }
}

#Preview {
    AlertsView(datadogAPI: DatadogAPI())
} 