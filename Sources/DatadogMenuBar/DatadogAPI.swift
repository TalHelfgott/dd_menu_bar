import Foundation

// MARK: - Data Models

struct DatadogAlert: Codable, Identifiable {
    let id: String
    let name: String
    let message: String
    let state: AlertState
    let created: String
    let modified: String
    let tags: [String]
    let priority: Int?
    
    enum AlertState: String, Codable {
        case alert = "Alert"
        case warn = "Warn"
        case noData = "No Data"
        case ok = "OK"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case message
        case state
        case created
        case modified
        case tags
        case priority
    }
}

struct DatadogAlertsResponse: Codable {
    let monitors: [DatadogMonitor]
}

struct DatadogMonitor: Codable {
    let id: Int
    let name: String
    let message: String
    let state: MonitorState
    let created: String
    let modified: String
    let tags: [String]
    let priority: Int?
    
    enum MonitorState: String, Codable {
        case alert = "Alert"
        case warn = "Warn"
        case noData = "No Data"
        case ok = "OK"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case message
        case state = "overall_state"
        case created
        case modified
        case tags
        case priority
    }
}

// MARK: - Datadog Regions

enum DatadogRegion: String, CaseIterable {
    case us1 = "US1"
    case eu1 = "EU1"
    case us3 = "US3"
    case us5 = "US5"
    case ap1 = "AP1"
    case gov = "GOV"
    
    var baseURL: String {
        switch self {
        case .us1:
            return "https://api.datadoghq.com/api/v1"
        case .eu1:
            return "https://api.datadoghq.eu/api/v1"
        case .us3:
            return "https://api.us3.datadoghq.com/api/v1"
        case .us5:
            return "https://api.us5.datadoghq.com/api/v1"
        case .ap1:
            return "https://api.ap1.datadoghq.com/api/v1"
        case .gov:
            return "https://api.ddog-gov.com/api/v1"
        }
    }
    
    var displayName: String {
        switch self {
        case .us1:
            return "US1 (Default)"
        case .eu1:
            return "EU1 (Europe)"
        case .us3:
            return "US3"
        case .us5:
            return "US5"
        case .ap1:
            return "AP1 (Asia Pacific)"
        case .gov:
            return "GOV (Government)"
        }
    }
    
    var webURL: String {
        switch self {
        case .us1:
            return "https://app.datadoghq.com/monitors/manage"
        case .eu1:
            return "https://app.datadoghq.eu/monitors/manage"
        case .us3:
            return "https://us3.datadoghq.com/monitors/manage"
        case .us5:
            return "https://us5.datadoghq.com/monitors/manage"
        case .ap1:
            return "https://ap1.datadoghq.com/monitors/manage"
        case .gov:
            return "https://app.ddog-gov.com/monitors/manage"
        }
    }
}

// MARK: - API Client

class DatadogAPI: ObservableObject {
    @Published var alerts: [DatadogAlert] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private var apiKey: String?
    private var appKey: String?
    private var region: DatadogRegion = .us1
    
    init() {
        loadCredentials()
    }
    
    private var baseURL: String {
        return region.baseURL
    }
    
    private func loadCredentials() {
        // Try to load from environment variables first
        apiKey = ProcessInfo.processInfo.environment["DATADOG_API_KEY"]
        appKey = ProcessInfo.processInfo.environment["DATADOG_APP_KEY"]
        
        // If not found in environment, try to load from user defaults
        if apiKey == nil {
            apiKey = UserDefaults.standard.string(forKey: "DatadogAPIKey")
        }
        if appKey == nil {
            appKey = UserDefaults.standard.string(forKey: "DatadogAppKey")
        }
        
        // Load region from environment variable first, then user defaults
        if let regionEnv = ProcessInfo.processInfo.environment["DATADOG_REGION"],
           let envRegion = DatadogRegion(rawValue: regionEnv) {
            region = envRegion
        } else if let regionString = UserDefaults.standard.string(forKey: "DatadogRegion"),
                  let savedRegion = DatadogRegion(rawValue: regionString) {
            region = savedRegion
        }
    }
    
    func saveCredentials(apiKey: String, appKey: String, region: DatadogRegion) {
        self.apiKey = apiKey
        self.appKey = appKey
        self.region = region
        
        UserDefaults.standard.set(apiKey, forKey: "DatadogAPIKey")
        UserDefaults.standard.set(appKey, forKey: "DatadogAppKey")
        UserDefaults.standard.set(region.rawValue, forKey: "DatadogRegion")
    }
    
    func getCurrentRegion() -> DatadogRegion {
        return region
    }
    
    func fetchAlerts() async throws -> [DatadogAlert] {
        guard let apiKey = apiKey, let appKey = appKey else {
            throw DatadogAPIError.missingCredentials
        }
        
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        // Construct URL for monitors endpoint
        var components = URLComponents(string: "\(baseURL)/monitor")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "application_key", value: appKey),
            URLQueryItem(name: "group_states", value: "alert,warn"), // Only fetch alerting monitors
            URLQueryItem(name: "with_downtimes", value: "false")
        ]
        
        guard let url = components.url else {
            throw DatadogAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw DatadogAPIError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw DatadogAPIError.httpError(httpResponse.statusCode)
            }
            
            let monitors = try JSONDecoder().decode([DatadogMonitor].self, from: data)
            
            // Convert monitors to alerts and filter for alerting states
            let alertingMonitors = monitors.filter { 
                $0.state == .alert || $0.state == .warn 
            }
            
            let convertedAlerts = alertingMonitors.map { monitor in
                DatadogAlert(
                    id: String(monitor.id),
                    name: monitor.name,
                    message: monitor.message,
                    state: DatadogAlert.AlertState(rawValue: monitor.state.rawValue) ?? .ok,
                    created: monitor.created,
                    modified: monitor.modified,
                    tags: monitor.tags,
                    priority: monitor.priority
                )
            }
            
            await MainActor.run {
                self.alerts = convertedAlerts
                self.isLoading = false
            }
            
            return convertedAlerts
            
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.error = error.localizedDescription
            }
            throw error
        }
    }
    
    func hasValidCredentials() -> Bool {
        return apiKey != nil && appKey != nil && 
               !(apiKey?.isEmpty ?? true) && !(appKey?.isEmpty ?? true)
    }
}

// MARK: - Error Types

enum DatadogAPIError: Error, LocalizedError {
    case missingCredentials
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "Datadog API credentials are missing. Please set your API key and App key."
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from Datadog API"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError:
            return "Failed to decode response from Datadog API"
        }
    }
} 