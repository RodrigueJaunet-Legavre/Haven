import SwiftUI

struct ContentView: View {
    @ObservedObject private var authService = AuthService.shared
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @ObservedObject private var emergencyStore = EmergencyReasonsStore.shared
    @ObservedObject private var onboardingStatus = OnboardingStatus.shared
    @ObservedObject private var consentStore = ConsentStore.shared
    @ObservedObject private var avatarStore = AvatarStore.shared

    private var isReady: Bool {
        authService.hasCheckedSession && (!authService.isAuthenticated || subscriptionManager.hasCheckedSubscription)
    }

    var body: some View {
        Group {
            if authService.accountDeleted {
                AccountDeletedView()
            } else if !isReady {
                loadingView
            } else if authService.isAuthenticated {
                if !consentStore.isResolved {
                    loadingView
                } else if !consentStore.isGranted {
                    ConsentView()
                } else if !onboardingStatus.isCompleted {
                    NavigationStack {
                        GamesSelectionView()
                    }
                } else if !subscriptionManager.isSubscribed {
                    NavigationStack {
                        PaywallView()
                    }
                } else if !emergencyStore.setupCompleted {
                    NavigationStack {
                        EmergencySetupView()
                    }
                } else if avatarStore.config.characterIndex == nil {
                    NavigationStack {
                        AvatarSetupView()
                    }
                } else {
                    HomeTabView()
                }
            } else {
                NavigationStack {
                    WelcomeView()
                }
            }
        }
    }

    private var loadingView: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ProgressView()
                .tint(Color.appAccent)
        }
    }
}

struct AccountDeletedView: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.appSuccess)

                Text("Ton compte a été supprimé")
                    .font(.appTitle)
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)

                Text("Toutes tes données ont été effacées. Ferme complètement l'application puis rouvre-la pour repartir de zéro.")
                    .font(.appBody)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 36)
        }
    }
}

#Preview {
    ContentView()
}
