import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var store = SubscriptionManager.shared
    @State private var isPurchasing = false

    private let benefits: [(String, String)] = [
        ("person.crop.circle.fill", "Ton avatar de vitalité, qui évolue avec tes progrès"),
        ("book.closed.fill", "Journal de suivi de tes mises, gains et pertes"),
        ("exclamationmark.triangle.fill", "Bouton Emergency pour tenir bon dans les moments difficiles"),
        ("play.rectangle.fill", "Vidéos avec des psychologues et addictologues"),
        ("sparkles", "Activités de remplacement pour canaliser l'envie de jouer"),
        ("lock.shield.fill", "Blocage technique des apps de paris et casino")
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    VStack(spacing: 10) {
                        Text("Reprends le contrôle avec Haven")
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)

                        Text("Voici comment Haven peut t'aider au quotidien.")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)

                    VStack(alignment: .leading, spacing: 18) {
                        ForEach(benefits, id: \.1) { icon, text in
                            HStack(spacing: 14) {
                                Image(systemName: icon)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.appAccent)
                                    .frame(width: 28)
                                Text(text)
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.9))
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    if let product = store.products.first {
                        VStack(spacing: 12) {
                            Button {
                                Task { await purchase(product) }
                            } label: {
                                Text(isPurchasing ? "..." : "Démarrer mon essai gratuit de 3 jours")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.appAccent)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .disabled(isPurchasing)
                            .padding(.horizontal, 24)

                            Text("3 jours gratuits, puis \(product.displayPrice)/mois sauf annulation. Résiliable à tout moment.")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    } else {
                        ProgressView().tint(.white)
                    }

                    Button("Restaurer mes achats") {
                        Task { await store.restorePurchases() }
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 20)
                }
            }
        }
    }

    private func purchase(_ product: Product) async {
        isPurchasing = true
        defer { isPurchasing = false }
        try? await store.purchase(product)
    }
}
