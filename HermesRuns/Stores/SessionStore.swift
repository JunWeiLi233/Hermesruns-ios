import Foundation
import Combine

enum HermesSessionPhase: Equatable {
    case restoring
    case signedOut
    case loading
    case ready
    case failed
}

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var phase: HermesSessionPhase = .restoring
    @Published private(set) var dashboard: HermesTodayDashboard?
    @Published private(set) var analysisRuns: [HermesRun] = []
    @Published private(set) var schedule: [HermesScheduledWorkout] = []
    @Published private(set) var email: String?
    @Published private(set) var errorMessage: String?
    @Published var apiBaseURL: String

    private let keychain: KeychainStore
    private var apiClient: HermesAPIClient
    private var token: String?

    private let tokenAccount = "session-token"
    private let emailAccount = "session-email"

    init(keychain: KeychainStore = KeychainStore(), previewDashboard: HermesTodayDashboard? = nil) {
        self.keychain = keychain
        self.apiClient = HermesAPIClient(baseURL: HermesAPIClient.defaultBaseURL())
        self.apiBaseURL = self.apiClient.baseURL.absoluteString
        self.dashboard = previewDashboard
        if previewDashboard != nil { self.phase = .ready }
    }

    var isAuthenticated: Bool { token != nil }

    func restore() async {
        token = keychain.read(account: tokenAccount)
        email = keychain.read(account: emailAccount)
        guard token != nil else {
            phase = .signedOut
            return
        }
        await refreshDashboard()
    }

    func login(email: String, password: String) async {
        errorMessage = nil
        phase = .loading
        do {
            let response = try await apiClient.login(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            token = response.token
            self.email = response.email
            try keychain.save(response.token, account: tokenAccount)
            try keychain.save(response.email, account: emailAccount)
            await refreshDashboard()
        } catch {
            phase = .failed
            errorMessage = error.localizedDescription
        }
    }

    func requestPasswordReset(email: String) async throws {
        try await apiClient.requestPasswordReset(email: email.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    func saveShoe(_ draft: HermesShoeDraft, id: Int64? = nil) async throws {
        guard let token else { throw HermesAPIError.unauthorized }
        if let id {
            _ = try await apiClient.updateShoe(token: token, id: id, draft: draft)
        } else {
            _ = try await apiClient.createShoe(token: token, draft: draft)
        }
        await refreshDashboard()
    }

    func retireShoe(id: Int64) async throws {
        guard let token else { throw HermesAPIError.unauthorized }
        try await apiClient.retireShoe(token: token, id: id)
        await refreshDashboard()
    }

    func refreshDashboard() async {
        guard let token else {
            phase = .signedOut
            return
        }
        phase = .loading
        errorMessage = nil
        do {
            dashboard = try await apiClient.fetchTodayDashboard(token: token)
            if let fetchedAnalysis = try? await apiClient.fetchAnalysis(token: token) {
                analysisRuns = fetchedAnalysis
            }
            if let fetchedSchedule = try? await apiClient.fetchSchedule(token: token) {
                schedule = fetchedSchedule
            }
            phase = .ready
        } catch HermesAPIError.unauthorized {
            clearSession()
            phase = .signedOut
            errorMessage = HermesAPIError.unauthorized.localizedDescription
        } catch {
            phase = .failed
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func updateAPIBaseURL(_ value: String) -> Bool {
        do {
            try apiClient.updateBaseURL(value)
            apiBaseURL = apiClient.baseURL.absoluteString
            UserDefaults.standard.set(apiBaseURL, forKey: "hermes.api.baseURL")
            dashboard = nil
            analysisRuns = []
            schedule = []
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func logout() async {
        if let token { await apiClient.logout(token: token) }
        clearSession()
        phase = .signedOut
    }

    private func clearSession() {
        keychain.delete(account: tokenAccount)
        keychain.delete(account: emailAccount)
        token = nil
        email = nil
        dashboard = nil
        analysisRuns = []
        schedule = []
    }
}
