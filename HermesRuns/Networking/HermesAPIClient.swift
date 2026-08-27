import Foundation

enum HermesAPIError: LocalizedError {
    case invalidBaseURL
    case unauthorized
    case server(String)
    case transport(String)
    case decoding(String)

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL: return "Enter a valid Hermes server URL."
        case .unauthorized: return "Your session expired. Sign in again."
        case .server(let message): return message
        case .transport(let message): return message
        case .decoding: return "Hermes returned an unexpected response."
        }
    }
}

final class HermesAPIClient {
    private let session: URLSession
    private(set) var baseURL: URL

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    static func defaultBaseURL() -> URL {
        let value = UserDefaults.standard.string(forKey: "hermes.api.baseURL") ?? "http://localhost:8080"
        return normalizedURL(value) ?? URL(string: "http://localhost:8080")!
    }

    static func normalizedURL(_ value: String) -> URL? {
        var raw = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }
        if !raw.lowercased().hasPrefix("http://") && !raw.lowercased().hasPrefix("https://") {
            raw = "http://" + raw
        }
        while raw.hasSuffix("/") { raw.removeLast() }
        guard let url = URL(string: raw), let scheme = url.scheme, ["http", "https"].contains(scheme.lowercased()), url.host != nil else {
            return nil
        }
        return url
    }

    func updateBaseURL(_ value: String) throws {
        guard let url = Self.normalizedURL(value) else { throw HermesAPIError.invalidBaseURL }
        baseURL = url
    }

    func login(email: String, password: String) async throws -> HermesAuthResponse {
        let body = try JSONEncoder().encode(["email": email, "password": password])
        return try await request(path: "/api/auth/login", method: "POST", body: body)
    }

    func requestPasswordReset(email: String) async throws {
        let body = try JSONEncoder().encode(["email": email])
        _ = try await requestData(path: "/api/auth/password-reset/request", method: "POST", body: body)
    }

    func fetchTodayDashboard(token: String) async throws -> HermesTodayDashboard {
        try await request(path: "/api/today/dashboard", token: token)
    }

    func fetchAnalysis(token: String, limit: Int = 30) async throws -> [HermesRun] {
        let boundedLimit = min(100, max(1, limit))
        return try await request(path: "/api/activities/analysis?limit=\(boundedLimit)", token: token)
    }

    func fetchSchedule(token: String, days: Int = 14) async throws -> [HermesScheduledWorkout] {
        let boundedDays = min(28, max(1, days))
        return try await request(path: "/api/coach/schedule?days=\(boundedDays)", token: token)
    }

    func createShoe(token: String, draft: HermesShoeDraft) async throws -> HermesShoe {
        let body = try JSONEncoder().encode(draft)
        return try await request(path: "/api/shoes", method: "POST", body: body, token: token)
    }

    func updateShoe(token: String, id: Int64, draft: HermesShoeDraft) async throws -> HermesShoe {
        let body = try JSONEncoder().encode(draft)
        return try await request(path: "/api/shoes/\(id)", method: "PUT", body: body, token: token)
    }

    func retireShoe(token: String, id: Int64) async throws {
        _ = try await requestData(path: "/api/shoes/\(id)/retire", method: "POST", token: token)
    }

    func createRace(token: String, draft: HermesRaceDraft) async throws -> HermesRace {
        let body = try JSONEncoder().encode(draft)
        return try await request(path: "/api/races", method: "POST", body: body, token: token)
    }

    func updateRace(token: String, id: Int64, draft: HermesRaceDraft) async throws -> HermesRace {
        let body = try JSONEncoder().encode(draft)
        return try await request(path: "/api/races/\(id)", method: "PUT", body: body, token: token)
    }

    func deleteRace(token: String, id: Int64) async throws {
        _ = try await requestData(path: "/api/races/\(id)", method: "DELETE", token: token)
    }

    func logout(token: String) async {
        _ = try? await requestData(path: "/api/auth/logout", method: "POST", token: token)
    }

    private func request<T: Decodable>(
        path: String,
        method: String = "GET",
        body: Data? = nil,
        token: String? = nil
    ) async throws -> T {
        let data = try await requestData(path: path, method: method, body: body, token: token)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw HermesAPIError.decoding(error.localizedDescription)
        }
    }

    private func requestData(
        path: String,
        method: String = "GET",
        body: Data? = nil,
        token: String? = nil
    ) async throws -> Data {
        guard let url = URL(string: baseURL.absoluteString + path) else {
            throw HermesAPIError.invalidBaseURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(Locale.preferredLanguages.first ?? "en-US", forHTTPHeaderField: "Accept-Language")
        if let token, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw HermesAPIError.transport("Hermes returned an invalid network response.")
            }
            if http.statusCode == 401 { throw HermesAPIError.unauthorized }
            guard (200..<300).contains(http.statusCode) else {
                let payload = try? JSONDecoder().decode(HermesErrorPayload.self, from: data)
                throw HermesAPIError.server(payload?.error ?? payload?.message ?? "Hermes request failed (\(http.statusCode)).")
            }
            return data
        } catch let error as HermesAPIError {
            throw error
        } catch {
            throw HermesAPIError.transport(error.localizedDescription)
        }
    }
}

private struct HermesErrorPayload: Decodable {
    let error: String?
    let message: String?
}
