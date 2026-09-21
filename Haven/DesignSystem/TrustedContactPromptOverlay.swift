import SwiftUI
import MessageUI

struct TrustedContactPromptOverlay: View {
    @ObservedObject var store: TrustedContactStore
    @State private var showComposer = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.78).ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.appAccent)

                Text("Ça a l'air d'être une période difficile")
                    .font(.appTitle)
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)

                Text("Tu veux prévenir \(store.name) ?")
                    .font(.appBody)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)

                if MFMessageComposeViewController.canSendText() {
                    Button("Envoyer un message") {
                        showComposer = true
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 40)
                }

                Button("Pas maintenant") {
                    store.pendingPrompt = false
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.appTextMuted)
            }
            .padding(.horizontal, 28)
        }
        .sheet(isPresented: $showComposer) {
            MessageComposerView(
                recipients: [store.phone],
                body: "Salut \(store.name), je traverse un moment un peu difficile en ce moment, ça me ferait du bien qu'on se parle.",
                onFinish: {
                    showComposer = false
                    store.pendingPrompt = false
                }
            )
        }
    }
}

#Preview {
    TrustedContactPromptOverlay(store: TrustedContactStore.shared)
}
