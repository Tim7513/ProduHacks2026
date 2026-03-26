import CryptoKit
import Foundation

struct RemoteChildSettings {
    let childId: String
    let readingLevel: Int
    let readingComprehension: Double
    let dailyGoal: Int
    let requiredTestScore: Double
    let readingMinutes: Int
    let readingRequirementMinutes: Int
    let dailyScreenTimeLimitMinutes: Int
    let unlockDurationMinutes: Int
    let selectedGenres: [String]
}

struct RemoteHouseholdChild {
    let id: String
    let name: String
    let age: Int
    let readingLevel: Int
    let readingComprehension: Double
    let dailyGoal: Int
    let requiredTestScore: Double
    let readingMinutes: Int
    let readingRequirementMinutes: Int
    let selectedGenres: [String]
}

struct ParentAppSettings {
    let dailyGoal: Int
    let readingLevel: Int
    let requiredTestScore: Double
    let readingMinutes: Int
    let readingRequirementMinutes: Int
    let dailyScreenTimeLimitMinutes: Int
    let unlockDurationMinutes: Int
    let selectedGenres: [String]
}

enum SupabaseAuthMode {
    case signUp
    case signIn
}

final class SupabaseService {
    static let shared = SupabaseService()

    private let session = URLSession.shared

    private init() {}

    private var baseURL: String? {
        (Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String)?.sanitizedConfigurationValue
    }

    private var apiKey: String? {
        (Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String)?.sanitizedConfigurationValue
        ?? (Bundle.main.object(forInfoDictionaryKey: "SUPABASE_PUBLISHABLE_KEY") as? String)?.sanitizedConfigurationValue
    }

    func authenticateGuardian(
        username: String,
        password: String,
        name: String?,
        mode: SupabaseAuthMode
    ) async throws -> String {
        let normalizedUsername = normalizeUsername(username)
        try validateUsername(normalizedUsername)
        try validatePassword(password)

        switch mode {
        case .signUp:
            if try await householdAccountExists(username: normalizedUsername) {
                throw SupabaseServiceError.accountExists
            }

            let guardianId = UUID().uuidString.lowercased()
            let accountBody = HouseholdAccountUpsertBody(
                id: guardianId,
                username: normalizedUsername,
                passwordHash: hashPassword(password, username: normalizedUsername),
                guardianName: name?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? normalizedUsername
            )

            _ = try await requestTable(
                path: "/rest/v1/household_accounts",
                method: "POST",
                body: [accountBody]
            ) as EmptySupabaseResponse

            try await upsertProfile(
                id: guardianId,
                role: "guardian",
                name: name?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? normalizedUsername,
                email: nil,
                username: normalizedUsername
            )
            return guardianId

        case .signIn:
            guard let account = try await fetchHouseholdAccount(username: normalizedUsername) else {
                throw SupabaseServiceError.invalidCredentials
            }

            guard account.passwordHash == hashPassword(password, username: normalizedUsername) else {
                throw SupabaseServiceError.invalidCredentials
            }

            try await upsertProfile(
                id: account.id,
                role: "guardian",
                name: account.guardianName,
                email: nil,
                username: normalizedUsername
            )
            return account.id
        }
    }

    func verifyHouseholdPassword(username: String, password: String) async throws -> Bool {
        let normalizedUsername = normalizeUsername(username)
        try validateUsername(normalizedUsername)
        try validatePassword(password)

        guard let account = try await fetchHouseholdAccount(username: normalizedUsername) else {
            return false
        }

        return account.passwordHash == hashPassword(password, username: normalizedUsername)
    }

    func bootstrapChildren(_ children: [ChildProfile], guardianId: String) async throws {
        for child in children {
            let childBody = ChildUpsertBody(
                id: child.id,
                guardianId: guardianId,
                name: child.name,
                age: child.age,
                readingLevel: child.readingLevel,
                readingComprehension: child.readingComprehension,
                dailyGoal: child.dailyGoal,
                requiredTestScore: child.requiredTestScore,
                readingMinutes: child.readingMinutes,
                readingRequirementMinutes: child.readingMinutes
            )

            _ = try await requestTable(
                path: "/rest/v1/children",
                method: "POST",
                queryItems: [URLQueryItem(name: "on_conflict", value: "id")],
                body: [childBody],
                extraHeaders: ["Prefer": "resolution=ignore-duplicates"]
            ) as EmptySupabaseResponse

            let settingsBody = ChildSettingsUpsertBody(
                childId: child.id,
                unlockDurationMinutes: 60,
                dailyScreenTimeLimitMinutes: 120,
                selectedGenres: defaultGenres(for: child),
                blockedApps: []
            )

            _ = try await requestTable(
                path: "/rest/v1/child_settings",
                method: "POST",
                queryItems: [URLQueryItem(name: "on_conflict", value: "child_id")],
                body: [settingsBody],
                extraHeaders: ["Prefer": "resolution=ignore-duplicates"]
            ) as EmptySupabaseResponse
        }
    }

    func saveParentSettings(
        child: ChildProfile,
        guardianId: String,
        settings: ParentAppSettings
    ) async throws {
        let childBody = ChildUpsertBody(
            id: child.id,
            guardianId: guardianId,
            name: child.name,
            age: child.age,
            readingLevel: settings.readingLevel,
            readingComprehension: child.readingComprehension,
            dailyGoal: settings.dailyGoal,
            requiredTestScore: settings.requiredTestScore,
            readingMinutes: settings.readingMinutes,
            readingRequirementMinutes: settings.readingRequirementMinutes
        )

        _ = try await requestTable(
            path: "/rest/v1/children",
            method: "POST",
            queryItems: [URLQueryItem(name: "on_conflict", value: "id")],
            body: [childBody],
            extraHeaders: ["Prefer": "resolution=merge-duplicates"]
        ) as EmptySupabaseResponse

        let settingsBody = ChildSettingsUpsertBody(
            childId: child.id,
            unlockDurationMinutes: settings.unlockDurationMinutes,
            dailyScreenTimeLimitMinutes: settings.dailyScreenTimeLimitMinutes,
            selectedGenres: settings.selectedGenres,
            blockedApps: []
        )

        _ = try await requestTable(
            path: "/rest/v1/child_settings",
            method: "POST",
            queryItems: [URLQueryItem(name: "on_conflict", value: "child_id")],
            body: [settingsBody],
            extraHeaders: ["Prefer": "resolution=merge-duplicates"]
        ) as EmptySupabaseResponse
    }

    func fetchRemoteSettings(for childId: String) async throws -> RemoteChildSettings? {
        let children: [RemoteChildRow] = try await requestTable(
            path: "/rest/v1/children",
            method: "GET",
            queryItems: [
                URLQueryItem(name: "id", value: "eq.\(childId)"),
                URLQueryItem(name: "select", value: "id,reading_level,reading_comprehension,daily_goal,required_test_score,reading_minutes,reading_requirement_minutes")
            ],
            body: Optional<String>.none
        )

        guard let child = children.first else { return nil }

        let childSettingsRows: [RemoteChildSettingsRow] = try await requestTable(
            path: "/rest/v1/child_settings",
            method: "GET",
            queryItems: [
                URLQueryItem(name: "child_id", value: "eq.\(childId)"),
                URLQueryItem(name: "select", value: "child_id,daily_screen_time_limit_minutes,unlock_duration_minutes,selected_genres")
            ],
            body: Optional<String>.none
        )

        let settings = childSettingsRows.first

        return RemoteChildSettings(
            childId: child.id,
            readingLevel: child.readingLevel,
            readingComprehension: child.readingComprehension,
            dailyGoal: child.dailyGoal,
            requiredTestScore: child.requiredTestScore,
            readingMinutes: child.readingMinutes,
            readingRequirementMinutes: child.readingRequirementMinutes,
            dailyScreenTimeLimitMinutes: settings?.dailyScreenTimeLimitMinutes ?? 120,
            unlockDurationMinutes: settings?.unlockDurationMinutes ?? 60,
            selectedGenres: settings?.selectedGenres ?? []
        )
    }

    func fetchGuardianChildren(guardianId: String) async throws -> [RemoteHouseholdChild] {
        let children: [RemoteChildProfileRow] = try await requestTable(
            path: "/rest/v1/children",
            method: "GET",
            queryItems: [
                URLQueryItem(name: "guardian_id", value: "eq.\(guardianId)"),
                URLQueryItem(name: "select", value: "id,name,age,reading_level,reading_comprehension,daily_goal,required_test_score,reading_minutes,reading_requirement_minutes")
            ],
            body: Optional<String>.none
        )

        var result: [RemoteHouseholdChild] = []
        for child in children {
            let settingsRows: [RemoteChildSettingsRow] = try await requestTable(
                path: "/rest/v1/child_settings",
                method: "GET",
                queryItems: [
                    URLQueryItem(name: "child_id", value: "eq.\(child.id)"),
                    URLQueryItem(name: "select", value: "child_id,daily_screen_time_limit_minutes,unlock_duration_minutes,selected_genres")
                ],
                body: Optional<String>.none
            )

            result.append(
                RemoteHouseholdChild(
                    id: child.id,
                    name: child.name,
                    age: child.age,
                    readingLevel: child.readingLevel,
                    readingComprehension: child.readingComprehension,
                    dailyGoal: child.dailyGoal,
                    requiredTestScore: child.requiredTestScore,
                    readingMinutes: child.readingMinutes,
                    readingRequirementMinutes: child.readingRequirementMinutes,
                    selectedGenres: settingsRows.first?.selectedGenres ?? []
                )
            )
        }

        return result
    }

    func createChildProfile(
        name: String,
        age: Int,
        readingLevel: Int,
        guardianId: String,
        selectedGenres: [String]
    ) async throws -> RemoteHouseholdChild {
        let childId = UUID().uuidString.lowercased()
        let readingComprehension = Double(age * 100)

        let childBody = ChildUpsertBody(
            id: childId,
            guardianId: guardianId,
            name: name,
            age: age,
            readingLevel: readingLevel,
            readingComprehension: readingComprehension,
            dailyGoal: 1,
            requiredTestScore: 0.8,
            readingMinutes: 1,
            readingRequirementMinutes: 1
        )

        _ = try await requestTable(
            path: "/rest/v1/children",
            method: "POST",
            body: [childBody]
        ) as EmptySupabaseResponse

        let settingsBody = ChildSettingsUpsertBody(
            childId: childId,
            unlockDurationMinutes: 60,
            dailyScreenTimeLimitMinutes: 120,
            selectedGenres: selectedGenres,
            blockedApps: []
        )

        _ = try await requestTable(
            path: "/rest/v1/child_settings",
            method: "POST",
            body: [settingsBody]
        ) as EmptySupabaseResponse

        return RemoteHouseholdChild(
            id: childId,
            name: name,
            age: age,
            readingLevel: readingLevel,
            readingComprehension: readingComprehension,
            dailyGoal: 1,
            requiredTestScore: 0.8,
            readingMinutes: 1,
            readingRequirementMinutes: 1,
            selectedGenres: selectedGenres
        )
    }

    private func upsertProfile(id: String, role: String, name: String, email: String?, username: String) async throws {
        let body = ProfileUpsertBody(id: id, role: role, name: name, email: email, username: username)
        _ = try await requestTable(
            path: "/rest/v1/profiles",
            method: "POST",
            queryItems: [URLQueryItem(name: "on_conflict", value: "id")],
            body: [body],
            extraHeaders: ["Prefer": "resolution=merge-duplicates"]
        ) as EmptySupabaseResponse
    }

    private func householdAccountExists(username: String) async throws -> Bool {
        let rows: [HouseholdAccountLookupRow] = try await requestTable(
            path: "/rest/v1/household_accounts",
            method: "GET",
            queryItems: [
                URLQueryItem(name: "username", value: "eq.\(username)"),
                URLQueryItem(name: "select", value: "id")
            ],
            body: Optional<String>.none
        )

        return !rows.isEmpty
    }

    private func fetchHouseholdAccount(username: String) async throws -> HouseholdAccountLookupRow? {
        let rows: [HouseholdAccountLookupRow] = try await requestTable(
            path: "/rest/v1/household_accounts",
            method: "GET",
            queryItems: [
                URLQueryItem(name: "username", value: "eq.\(username)"),
                URLQueryItem(name: "select", value: "id,username,password_hash,guardian_name")
            ],
            body: Optional<String>.none
        )

        return rows.first
    }

    private func requestTable<T: Decodable, Body: Encodable>(
        path: String,
        method: String,
        queryItems: [URLQueryItem] = [],
        body: Body?,
        extraHeaders: [String: String] = [:]
    ) async throws -> T {
        try await performRequest(
            path: path,
            method: method,
            queryItems: queryItems,
            body: body,
            extraHeaders: extraHeaders,
            responseType: T.self
        )
    }

    private func performRequest<T: Decodable, Body: Encodable>(
        path: String,
        method: String,
        queryItems: [URLQueryItem] = [],
        body: Body?,
        extraHeaders: [String: String],
        responseType: T.Type
    ) async throws -> T {
        guard let baseURL, let apiKey else {
            throw SupabaseServiceError.missingConfiguration
        }

        var components = URLComponents(string: baseURL + path)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }

        guard let url = components?.url else {
            throw SupabaseServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        for (header, value) in extraHeaders {
            request.setValue(value, forHTTPHeaderField: header)
        }

        if let body {
            request.httpBody = try JSONEncoder.snakeCase.encode(body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseServiceError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let apiError = try? JSONDecoder().decode(SupabaseAPIError.self, from: data)
            throw SupabaseServiceError.serverError(
                code: httpResponse.statusCode,
                message: apiError?.messageText ?? String(data: data, encoding: .utf8) ?? "Unknown Supabase error"
            )
        }

        if T.self == EmptySupabaseResponse.self {
            return EmptySupabaseResponse() as! T
        }

        return try JSONDecoder.snakeCase.decode(T.self, from: data)
    }

    private func defaultGenres(for child: ChildProfile) -> [String] {
        Array(Set(child.library.map(\.category))).sorted()
    }

    private func normalizeUsername(_ username: String) -> String {
        username
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private func validateUsername(_ username: String) throws {
        guard !username.isEmpty else {
            throw SupabaseServiceError.invalidUsername("Username is required.")
        }

        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789._-")
        guard username.rangeOfCharacter(from: allowed.inverted) == nil else {
            throw SupabaseServiceError.invalidUsername("Usernames can only use letters, numbers, periods, hyphens, and underscores.")
        }

        guard username.count >= 3 else {
            throw SupabaseServiceError.invalidUsername("Username must be at least 3 characters long.")
        }
    }

    private func validatePassword(_ password: String) throws {
        guard password.count >= 6 else {
            throw SupabaseServiceError.invalidPassword("Password must be at least 6 characters long.")
        }
    }

    private func hashPassword(_ password: String, username: String) -> String {
        let material = "\(username):\(password)"
        let digest = SHA256.hash(data: Data(material.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

private enum SupabaseServiceError: Error {
    case missingConfiguration
    case invalidURL
    case invalidResponse
    case invalidUsername(String)
    case invalidPassword(String)
    case accountExists
    case invalidCredentials
    case serverError(code: Int, message: String)
}

extension SupabaseServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingConfiguration:
            return "Supabase configuration is missing from Info.plist."
        case .invalidURL:
            return "The Supabase URL is invalid."
        case .invalidResponse:
            return "Supabase returned an invalid response."
        case let .invalidUsername(message):
            return message
        case let .invalidPassword(message):
            return message
        case .accountExists:
            return "That username is already taken."
        case .invalidCredentials:
            return "Invalid username or password."
        case let .serverError(_, message):
            return message
        }
    }
}

private struct SupabaseAPIError: Decodable {
    let msg: String?
    let message: String?

    var messageText: String? {
        message ?? msg
    }
}

private struct EmptySupabaseResponse: Decodable {}

private struct HouseholdAccountUpsertBody: Encodable {
    let id: String
    let username: String
    let passwordHash: String
    let guardianName: String
}

private struct HouseholdAccountLookupRow: Decodable {
    let id: String
    let username: String?
    let passwordHash: String
    let guardianName: String
}

private struct ProfileUpsertBody: Encodable {
    let id: String
    let role: String
    let name: String
    let email: String?
    let username: String
}

private struct ChildUpsertBody: Encodable {
    let id: String
    let guardianId: String
    let name: String
    let age: Int
    let readingLevel: Int
    let readingComprehension: Double
    let dailyGoal: Int
    let requiredTestScore: Double
    let readingMinutes: Int
    let readingRequirementMinutes: Int
}

private struct ChildSettingsUpsertBody: Encodable {
    let childId: String
    let unlockDurationMinutes: Int
    let dailyScreenTimeLimitMinutes: Int
    let selectedGenres: [String]
    let blockedApps: [String]
}

private struct RemoteChildRow: Decodable {
    let id: String
    let readingLevel: Int
    let readingComprehension: Double
    let dailyGoal: Int
    let requiredTestScore: Double
    let readingMinutes: Int
    let readingRequirementMinutes: Int
}

private struct RemoteChildProfileRow: Decodable {
    let id: String
    let name: String
    let age: Int
    let readingLevel: Int
    let readingComprehension: Double
    let dailyGoal: Int
    let requiredTestScore: Double
    let readingMinutes: Int
    let readingRequirementMinutes: Int
}

private struct RemoteChildSettingsRow: Decodable {
    let childId: String
    let dailyScreenTimeLimitMinutes: Int
    let unlockDurationMinutes: Int
    let selectedGenres: [String]
}

private extension JSONEncoder {
    static var snakeCase: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}

private extension JSONDecoder {
    static var snakeCase: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }

    var sanitizedConfigurationValue: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard !(trimmed.hasPrefix("$(") && trimmed.hasSuffix(")")) else { return nil }
        return trimmed
    }
}
