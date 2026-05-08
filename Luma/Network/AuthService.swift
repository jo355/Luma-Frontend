//
//  AuthService.swift
//  Luma
//
//  Created by Jiaoyang Liu on 19/1/2026.
//


import Foundation

final class AuthService {
    func login(username: String, password: String) async throws {
        let tokens = try await AuthAPI.login(username: username, password: password)
        TokenStore.shared.save(access: tokens.access, refresh: tokens.refresh)
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
