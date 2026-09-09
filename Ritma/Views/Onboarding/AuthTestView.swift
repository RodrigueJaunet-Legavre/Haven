import SwiftUI

struct AuthTestView: View {
    @StateObject private var authService = AuthService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            if authService.isAuthenticated {
                Text("Connecté")
                Text(authService.currentUserId?.uuidString ?? "")
                    .font(.caption)
                Button("Se déconnecter") {
                    Task { try? await authService.signOut() }
                }
            } else {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("Mot de passe", text: $password)

                Button("Créer un compte") {
                    Task { await signUp() }
                }
                Button("Se connecter") {
                    Task { await signIn() }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
        .padding()
        .textFieldStyle(.roundedBorder)
        .buttonStyle(.borderedProminent)
    }

    private func signUp() async {
        do {
            try await authService.signUp(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func signIn() async {
        do {
            try await authService.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    AuthTestView()
}
