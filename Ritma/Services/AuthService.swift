import Foundation
import Combine
import Supabase

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var currentUserId: UUID?
    @Published var isAuthenticated = false

    private let client = SupabaseService.shared.client

    private init() {
        Task { await restoreSession() }
    }

    func signUp(email: String, password: String) async throws {
        let response = try await client.auth.signUp(email: email, password: password)
        currentUserId = response.user.id
        isAuthenticated = true
    }

    func signIn(email: String, password: String) async throws {
        let session = try await client.auth.signIn(email: email, password: password)
        currentUserId = session.user.id
        isAuthenticated = true
    }

    func signOut() async throws {
        try await client.auth.signOut()
        currentUserId = nil
        isAuthenticated = false
    }

    private func restoreSession() async {
        if let session = try? await client.auth.session {
            currentUserId = session.user.id
            isAuthenticated = true
        }
    }
}
