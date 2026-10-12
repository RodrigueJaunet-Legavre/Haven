import SwiftUI

struct HomeTabView: View {
    @ObservedObject private var avatarStore = AvatarStore.shared
    @ObservedObject private var badgeStore = BadgeStore.shared
    @ObservedObject private var trustedContactStore = TrustedContactStore.shared

    var body: some View {
        ZStack {
            TabView {
                JourneyView()
                    .tabItem {
                        Label("Parcours", systemImage: "map.fill")
                    }

                JournalView()
                    .tabItem {
                        Label("Journal", systemImage: "list.bullet.rectangle.fill")
                    }

                ResourcesView()
                    .tabItem {
                        Label("Ressources", systemImage: "play.rectangle.fill")
                    }

                BlockerView()
                    .tabItem {
                        Label("Blocker", systemImage: "lock.shield.fill")
                    }

                EmergencyView()
                    .tabItem {
                        Label("Emergency", systemImage: "exclamationmark.triangle.fill")
                    }
            }
            .tint(Color.appAccent)
            .toolbarBackground(Color.appSurface, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)

            if let gain = avatarStore.pendingGain {
                VitalityGainOverlay(characterIndex: avatarStore.config.characterIndex, event: gain) {
                    avatarStore.pendingGain = nil
                }
                .id(gain.id)
                .transition(.opacity)
                .zIndex(1)
            } else if let unlock = badgeStore.pendingUnlocks.first {
                BadgeUnlockOverlay(badge: unlock.badge) {
                    badgeStore.dismissCurrentUnlock()
                }
                .id(unlock.id)
                .transition(.opacity)
                .zIndex(1)
            } else if trustedContactStore.pendingPrompt {
                TrustedContactPromptOverlay(store: trustedContactStore)
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
    }
}

#Preview {
    HomeTabView()
}
