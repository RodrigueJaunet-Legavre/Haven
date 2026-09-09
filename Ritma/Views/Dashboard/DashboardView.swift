import SwiftUI

struct DashboardView: View {
    @ObservedObject private var store = AvatarStore.shared
    @State private var streakDays = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        Spacer(minLength: 20)

                        AvatarView(config: store.config, vitalityScore: store.vitalityScore)

                        VStack(spacing: 6) {
                            Text("\(streakDays) jour\(streakDays > 1 ? "s" : "") sans jouer")
                                .font(.appHeadline)
                                .foregroundStyle(Color.appTextPrimary)

                            Text("Score de vitalité : \(Int(store.vitalityScore))/100")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.appTextSecondary)
                        }

                        NavigationLink {
                            AvatarCreatorView()
                        } label: {
                            Text("Personnaliser mon avatar")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.appAccent)
                        }

                        debugSection
                    }
                    .padding(.horizontal, 28)
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var debugSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Réglage de test (temporaire)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appTextMuted)

            Slider(value: $store.vitalityScore, in: 0...100)
                .tint(Color.appAccent)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurface)
        )
        .padding(.top, 20)
    }
}

#Preview {
    DashboardView()
}
