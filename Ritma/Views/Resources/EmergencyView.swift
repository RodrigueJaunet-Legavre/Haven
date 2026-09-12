import SwiftUI

struct EmergencyView: View {
    @ObservedObject private var store = EmergencyReasonsStore.shared
    @State private var isRevealed = false
    @State private var isPulsing = false
    @State private var newReasonText = ""
    @State private var isAddingReason = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if isRevealed {
                    reasonsPanel
                } else {
                    alarmButton
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
        }
    }

    private var alarmButton: some View {
        VStack(spacing: 24) {
            Spacer()

            Button {
                withAnimation(.appSpringBouncy) {
                    isRevealed = true
                }
            } label: {
                Image("emergency_button")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 260)
                    .shadow(color: Color.appDanger.opacity(isPulsing ? 0.7 : 0.35), radius: isPulsing ? 36 : 18)
                    .scaleEffect(isPulsing ? 1.03 : 1)
            }
            .buttonStyle(.plain)

            Spacer()
            Spacer()
        }
    }
    private var reasonsPanel: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 20)

                    VStack(spacing: 8) {
                        Text("Tes raisons de tenir bon")
                            .font(.appTitle)
                            .foregroundStyle(Color.appTextPrimary)

                        Text("Respire. Relis-les une par une.")
                            .font(.appBody)
                            .foregroundStyle(Color.appTextSecondary)
                    }

                    VStack(spacing: 10) {
                        ForEach(store.reasons) { reason in
                            reasonRow(reason)
                        }
                    }
                    .padding(.horizontal, 28)

                    VStack(spacing: 10) {
                        NavigationLink {
                            ResourcesView()
                        } label: {
                            quickLinkRow(
                                icon: "sparkles",
                                title: "Des activités à faire à la place",
                                subtitle: "6 alternatives concrètes, dès maintenant"
                            )
                        }

                        NavigationLink {
                            VideoDetailView(video: resourceVideos[0])
                        } label: {
                            quickLinkRow(
                                icon: "play.circle.fill",
                                title: "Pourquoi ne pas replonger",
                                subtitle: "Par un addictologue · 6 min"
                            )
                        }
                    }
                    .padding(.horizontal, 28)

                    if isAddingReason {
                        addReasonField
                            .padding(.horizontal, 28)
                    } else {
                        Button {
                            isAddingReason = true
                        } label: {
                            Label("Ajouter une raison", systemImage: "plus.circle.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.appAccent)
                        }
                    }
                }
            }

            Button("Ça va mieux") {
                withAnimation(.appSpring) {
                    isRevealed = false
                    isAddingReason = false
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
            .padding(.top, 12)
        }
    }

    private func reasonRow(_ reason: EmergencyReason) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.appAccent)

            Text(reason.text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16).fill(Color.appSurface)
        )
    }
    private func quickLinkRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.appAccent)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)

                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appTextMuted)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16).fill(Color.appSurface)
        )
    }

    private var addReasonField: some View {
        HStack(spacing: 10) {
            TextField("Nouvelle raison", text: $newReasonText)
                .foregroundStyle(Color.appTextPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14).fill(Color.appSurfaceElevated)
                )

            Button {
                let trimmed = newReasonText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                store.addReason(trimmed)
                newReasonText = ""
                isAddingReason = false
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.appAccent)
            }
        }
    }
}

#Preview {
    EmergencyView()
}
