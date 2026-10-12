import SwiftUI
import AuthenticationServices

struct SignUpView: View {
    @StateObject private var authService = AuthService.shared

    @State private var isSignUpMode: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var goToHome = false
    @State private var currentNonce: String?

    init(startInSignUpMode: Bool = true) {
        _isSignUpMode = State(initialValue: startInSignUpMode)
    }

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

                HStack {
                    Rectangle().fill(Color.appBorder).frame(height: 1)
                    Text("ou")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appTextMuted)
                    Rectangle().fill(Color.appBorder).frame(height: 1)
                }
                .padding(.horizontal, 28)

                SignInWithAppleButton(.signIn) { request in
                    let nonce = AppleSignInHelper.randomNonceString()
                    currentNonce = nonce
                    request.requestedScopes = [.email]
                    request.nonce = AppleSignInHelper.sha256(nonce)
                } onCompletion: { result in
                    Task { await handleAppleSignIn(result) }
                }
                .signInWithAppleButtonStyle(.white)
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 28)

                Button {
                    Task { await submitGoogle() }
                } label: {
                    HStack {
                        Image(systemName: "g.circle.fill")
                        Text("Continuer avec Google")
                    }
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14).fill(Color.appSurfaceElevated)
                    )
                }
                .padding(.horizontal, 28)

                Link("Politique de confidentialité", destination: PrivacyPolicy.url)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextMuted)

                Spacer()
            }
        }
        .navigationDestination(isPresented: $goToHome) {
            if isSignUpMode {
                EmergencySetupView()
            } else {
                HomeTabView()
            }
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

    private func submitGoogle() async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.signInWithGoogle()
            goToHome = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityTokenData = credential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8),
                  let nonce = currentNonce else {
                errorMessage = "Connexion Apple impossible."
                return
            }
            isLoading = true
            errorMessage = nil
            do {
                try await authService.signInWithApple(idToken: identityToken, nonce: nonce)
                goToHome = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        case .failure(let error):
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                errorMessage = "Connexion Apple impossible."
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
}
