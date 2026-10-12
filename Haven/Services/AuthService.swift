import Foundation
import Combine
import AuthenticationServices
import Supabase

enum AuthFlowError: LocalizedError {
    case emailAlreadyUsed
    case confirmationRequired
    case appleConfirmationCancelled
    case appleAccountMismatch
    case appleRevocationFailed

    var errorDescription: String? {
        switch self {
        case .emailAlreadyUsed:
            return "Cette adresse est déjà utilisée. Connecte-toi avec ton mot de passe, ou avec Apple ou Google si tu t'es inscrit ainsi."
        case .confirmationRequired:
            return "Ton compte est créé. Confirme ton adresse avec le mail que tu viens de recevoir, puis connecte-toi."
        case .appleConfirmationCancelled:
            return "Suppression annulée. Pour supprimer un compte créé avec Apple, confirme avec ton identifiant Apple."
        case .appleAccountMismatch:
            return "Ce n'est pas l'identifiant Apple utilisé pour ce compte. Choisis le bon identifiant pour confirmer la suppression."
        case .appleRevocationFailed:
            return "La confirmation Apple a échoué. Rien n'a été supprimé : réessaie dans un instant."
        }
    }
}

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var currentUserId: UUID?
    @Published var currentUserEmail: String?
    @Published var isAuthenticated = false
    @Published var hasCheckedSession = false
    @Published var accountDeleted = false

    private let client = SupabaseService.shared.client

    private init() {
        Task { await restoreSession() }
    }

    func signUp(email: String, password: String) async throws {
        let response = try await client.auth.signUp(email: email, password: password)

        guard response.session != nil else {
            if response.user.identities?.isEmpty == true {
                throw AuthFlowError.emailAlreadyUsed
            }
            throw AuthFlowError.confirmationRequired
        }

        currentUserId = response.user.id
        currentUserEmail = response.user.email
        isAuthenticated = true
        notifyUserChanged()
    }

    func signIn(email: String, password: String) async throws {
        let session = try await client.auth.signIn(email: email, password: password)
        currentUserId = session.user.id
        currentUserEmail = session.user.email
        isAuthenticated = true
        notifyUserChanged()
    }

    func signInWithGoogle() async throws {
        let session = try await client.auth.signInWithOAuth(
            provider: .google,
            redirectTo: URL(string: "haven://login-callback")
        ) { webSession in
            webSession.prefersEphemeralWebBrowserSession = true
        }
        currentUserId = session.user.id
        currentUserEmail = session.user.email
        isAuthenticated = true
        notifyUserChanged()
    }

    func signInWithApple(idToken: String, nonce: String) async throws {
        let session = try await client.auth.signInWithIdToken(
            credentials: OpenIDConnectCredentials(provider: .apple, idToken: idToken, nonce: nonce)
        )
        currentUserId = session.user.id
        currentUserEmail = session.user.email
        isAuthenticated = true
        notifyUserChanged()
    }

    func signOut() async throws {
        try await client.auth.signOut()
        currentUserId = nil
        currentUserEmail = nil
        isAuthenticated = false
        notifyUserChanged()
    }

    func deleteAccount() async throws {
        let deletedUserId = currentUserId

        if try await hasAppleIdentity() {
            let code: String
            do {
                code = try await AppleReauthenticator().authorizationCode()
            } catch let error as ASAuthorizationError where error.code == .canceled {
                throw AuthFlowError.appleConfirmationCancelled
            }
            try await revokeAppleAccess(code: code)
        }

        try await client.rpc("delete_my_account").execute()
        try? await client.auth.signOut(scope: .local)

        BlockerStore.shared.resetAll()

        if let deletedUserId {
            UserDefaults.standard.removePersistentDomain(forName: UserScope.suiteName(for: deletedUserId.uuidString))
        }
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }

        currentUserId = nil
        currentUserEmail = nil
        isAuthenticated = false
        accountDeleted = true
        notifyUserChanged()
    }

    private func hasAppleIdentity() async throws -> Bool {
        let user = try await client.auth.user()
        return user.identities?.contains { $0.provider == "apple" } == true
    }

    private func revokeAppleAccess(code: String) async throws {
        struct Payload: Encodable {
            let authorizationCode: String
        }

        do {
            try await client.functions.invoke(
                "revoke-apple",
                options: FunctionInvokeOptions(body: Payload(authorizationCode: code))
            )
        } catch FunctionsError.httpError(let statusCode, _) where statusCode == 409 {
            throw AuthFlowError.appleAccountMismatch
        } catch {
            throw AuthFlowError.appleRevocationFailed
        }
    }

    private func restoreSession() async {
        if let session = try? await client.auth.session {
            currentUserId = session.user.id
            currentUserEmail = session.user.email
            isAuthenticated = true
        }
        hasCheckedSession = true
        notifyUserChanged()
    }

    private func notifyUserChanged() {
        UserScope.adoptOnboardingData()
        OnboardingStatus.shared.reloadForCurrentUser()

        AvatarStore.shared.reloadForCurrentUser()
        StreakStore.shared.reloadForCurrentUser()
        BadgeStore.shared.reloadForCurrentUser()
        JourneyStore.shared.reloadForCurrentUser()
        TrustedContactStore.shared.reloadForCurrentUser()
        ActivityCompletionStore.shared.reloadForCurrentUser()
        EmergencyReasonsStore.shared.reloadForCurrentUser()
        BetsService.shared.reloadForCurrentUser()
        VictoryService.shared.reloadForCurrentUser()
        CheckInService.shared.reloadForCurrentUser()
        ConsentStore.shared.reloadForCurrentUser()
    }
}
