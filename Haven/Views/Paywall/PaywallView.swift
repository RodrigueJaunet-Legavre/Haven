import SwiftUI

struct PaywallView: View {
    @State private var isVisible = false
    @State private var goToSignUp = false

    private let features: [(icon: String, text: String)] = [
        ("flame.fill", "Suivi des jours sans jouer, score de vitalité personnalisé et ton avatar"),
        ("lock.shield.fill", "Blocages des applications de paris sportifs et des sites de casino en ligne"),
        ("play.rectangle.fill", "Vidéos et podcasts avec des professionnels de santé"),
        ("exclamationmark.triangle.fill", "Bouton Emergency avec toutes tes raisons de ne pas rejouer en cas d'envie"),
        ("list.bullet.rectangle.fill", "Journal de suivi de tes mises, gains, pertes et stats personnalisées"),
        ("sparkles", "Activités de remplacement scientifiquement fondées")
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        Spacer(minLength: 20)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Débloque l'accompagnement complet")
                                .font(.appTitle)
                                .foregroundStyle(Color.appTextPrimary)

                            Text("Tout ce dont tu as besoin pour reprendre la main, au même endroit.")
                                .font(.appBody)
                                .foregroundStyle(Color.appTextSecondary)
                        }

                        VStack(spacing: 14) {
                            ForEach(features, id: \.text) { feature in
                                featureRow(icon: feature.icon, text: feature.text)
                            }
                        }
                    }
                    .padding(.horizontal, 28)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 12)
                }

                VStack(spacing: 12) {
                    VStack(spacing: 4) {
                        Text("7 jours d'essai gratuit")
                            .font(.appHeadline)
                            .foregroundStyle(Color.appTextPrimary)

                        Text("Puis 4,99 €/mois. Annule à tout moment depuis les réglages.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.appTextMuted)
                            .multilineTextAlignment(.center)
                    }

                    Button("Commencer l'essai gratuit") {
                        goToSignUp = true
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Text("L'essai gratuit est nécessaire pour accéder à l'app.")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.appTextMuted)
                }
                .padding(.horizontal, 28)
                .padding(.top, 16)
                .padding(.bottom, 40)
                .background(
                    Color.appBackground
                        .shadow(color: .black.opacity(0.3), radius: 20, y: -10)
                )
            }
        }
        .navigationDestination(isPresented: $goToSignUp) {
            SignUpView()
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.appSpring.delay(0.1)) {
                isVisible = true
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.appAccentMuted)
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
            }

            Text(text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        PaywallView()
    }
}
