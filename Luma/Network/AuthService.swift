//
//  AuthService.swift
//  Luma
//
//  Created by Jiaoyang Liu on 19/1/2026.
//


import Foundation

final class AuthService {
    func login(username: String, password: String) async throws {
        guard let supabaseURL = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let supabaseAnonKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String,
              !supabaseURL.isEmpty,
              !supabaseAnonKey.isEmpty else {
            throw AuthServiceError.missingSupabaseConfiguration
        }

        let trimmedBaseURL = supabaseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: "\(trimmedBaseURL)/auth/v1/token?grant_type=password") else {
            throw AuthServiceError.invalidSupabaseURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")

        let body = SupabasePasswordLoginRequest(email: username, password: password)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthServiceError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown Supabase login error"
            throw AuthServiceError.loginFailed(statusCode: httpResponse.statusCode, message: message)
        }

        let tokens = try JSONDecoder().decode(SupabaseTokenResponse.self, from: data)
        TokenStore.shared.save(access: tokens.accessToken, refresh: tokens.refreshToken)
    }

    func me() async throws -> MeResponse {
        try await APIClient.shared.request(
            path: "/api/me", 
            method: "GET",
            body: Optional<Int>.none,
            requiresAuth: true
        )
    }
    
    @MainActor
    static func logout() {
        Keychain.delete("luma.jwt.access")
        Keychain.delete("luma.jwt.refresh")
        UserDefaults.standard.removeObject(forKey: "cached_user")
        AppSession.shared.isLoggedIn = false
    }
}

private struct SupabasePasswordLoginRequest: Encodable {
    let email: String
    let password: String
}

private struct SupabaseTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

private enum AuthServiceError: LocalizedError {
    case missingSupabaseConfiguration
    case invalidSupabaseURL
    case invalidResponse
    case loginFailed(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .missingSupabaseConfiguration:
            return "Missing SUPABASE_URL or SUPABASE_ANON_KEY in app configuration."
        case .invalidSupabaseURL:
            return "Invalid Supabase URL."
        case .invalidResponse:
            return "Invalid authentication response."
        case .loginFailed(let statusCode, let message):
            return "Supabase login failed with status \(statusCode): \(message)"
        }
    }
}
