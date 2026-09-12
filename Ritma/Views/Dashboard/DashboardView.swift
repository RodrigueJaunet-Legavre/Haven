import SwiftUI

struct DashboardView: View {
    @ObservedObject private var store = AvatarStore.shared
    @ObservedObject private var streakStore = StreakStore.shared
    @ObservedObject private var completionStore = ActivityCompletionStore.shared
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        Spacer(minLength: 20)

                        AvatarView(config: store.config, vitalityScore: store.vitalityScore)

                        VStack(spacing: 6) {
                            Text("\(streakStore.streakDays) jour\(streakStore.streakDays > 1 ? "s" : "") sans jouer")
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .task {
                await streakStore.refresh()
            }
        }
    }

    private var debugSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Réglage de test (temporaire)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appTextMuted)

            Slider(value: $store.vitalityScore, in: 0...100)
                .tint(Color.appAccent)

            Button("Réinitialiser les activités du jour") {
                completionStore.resetToday()
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.appDanger)
            .padding(.top, 4)
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
