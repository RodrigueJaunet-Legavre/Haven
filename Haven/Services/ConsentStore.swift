import SwiftUI
import Combine
import Supabase

struct ConsentRecord: Decodable {
    let id: UUID
    let policy_version: String
}

@MainActor
final class ConsentStore: ObservableObject {
    static let shared = ConsentStore()

    @Published private(set) var isGranted = false
    @Published private(set) var isResolved = false
    @Published private(set) var isSaving = false
    @Published var errorMessage: String?

    private let client = SupabaseService.shared.client

    private init() {}

    func reloadForCurrentUser() {
        errorMessage = nil
        isGranted = Self.hasLocalConsent()
        isResolved = isGranted

        if !isGranted, AuthService.shared.currentUserId != nil {
            Task { await resolveFromServer() }
        }
    }

    func accept() async {
        guard let userId = AuthService.shared.currentUserId else { return }
        isSaving = true
        errorMessage = nil

        _ = try? await client.auth.session

        struct NewConsent: Encodable {
            let user_id: UUID
            let policy_version: String
        }

        do {
            try await client
                .from("consents")
                .insert(NewConsent(user_id: userId, policy_version: PrivacyPolicy.version))
                .execute()
            Self.saveLocalConsent()
            isGranted = true
        } catch {
            print("Erreur insert consent: \(error)")
            errorMessage = "Ton accord n'a pas pu être enregistré. Vérifie ta connexion et réessaie."
        }

        isSaving = false
    }

    private func resolveFromServer() async {
        guard let userId = AuthService.shared.currentUserId else { return }

        _ = try? await client.auth.session

        do {
            let records: [ConsentRecord] = try await client
                .from("consents")
                .select()
                .eq("user_id", value: userId)
                .eq("policy_version", value: PrivacyPolicy.version)
                .limit(1)
                .execute()
                .value

            guard AuthService.shared.currentUserId == userId else { return }

            if !records.isEmpty {
                Self.saveLocalConsent()
                isGranted = true
            }
        } catch {
            print("Erreur fetch consent: \(error)")
        }

        guard AuthService.shared.currentUserId == userId else { return }
        isResolved = true
    }

    private static func hasLocalConsent() -> Bool {
        UserScope.defaults.string(forKey: "consentedPolicyVersion") == PrivacyPolicy.version
    }

    private static func saveLocalConsent() {
        UserScope.defaults.set(PrivacyPolicy.version, forKey: "consentedPolicyVersion")
    }
}
