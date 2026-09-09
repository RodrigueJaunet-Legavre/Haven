import SwiftUI

struct SignUpView: View {
    @StateObject private var authService = AuthService.shared

    @State private var isSignUpMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var goToHome = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer(minLength: 40)

                VStack(spacing: 8) {
                    Text(isSignUpMode ? "Crée ton compte" : "Content de te revoir")
                        .font(.appTitle)
                        .foregroundStyle(Color.appTextPrimary)

                    Text("Tes données restent privées et confidentielles.")
                        .font(.appBody)
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 28)

                VStack(spacing: 14) {
                    field(placeholder: "Email", text: $email, isSecure: false)
                    field(placeholder: "Mot de passe", text: $password, isSecure: true)
                }
                .padding(.horizontal, 28)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appDanger)
                        .padding(.horizontal, 28)
                        .multilineTextAlignment(.center)
                }

                Button(isLoading ? "..." : (isSignUpMode ? "Créer mon compte" : "Me connecter")) {
                    Task { await submit() }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 28)
                .disabled(isLoading || email.isEmpty || password.isEmpty)

                Button {
                    isSignUpMode.toggle()
                    errorMessage = nil
                } label: {
                    Text(isSignUpMode ? "J'ai déjà un compte" : "Créer un compte")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.appAccent)
                }

                Spacer()
            }
        }
        .navigationDestination(isPresented: $goToHome) {
            HomeTabView()
        }
        .navigationBarHidden(true)
    }

    private func field(placeholder: String, text: Binding<String>, isSecure: Bool) -> some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: text)
            } else {
                TextField(placeholder, text: text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
            }
        }
        .foregroundStyle(Color.appTextPrimary)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14).fill(Color.appSurfaceElevated)
        )
    }

    private func submit() async {
        isLoading = true
        errorMessage = nil
        do {
            if isSignUpMode {
                try await authService.signUp(email: email, password: password)
            } else {
                try await authService.signIn(email: email, password: password)
            }
            goToHome = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
}
