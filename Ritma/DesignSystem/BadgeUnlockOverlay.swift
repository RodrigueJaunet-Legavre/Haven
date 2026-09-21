import SwiftUI

struct BadgeUnlockOverlay: View {
    let badge: Badge
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var glowPulse = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.78).ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Nouveau badge débloqué !")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appTextSecondary)

                ZStack {
                    Circle()
                        .fill(Color.appGold.opacity(glowPulse ? 0.5 : 0.25))
                        .frame(width: 200, height: 200)
                        .blur(radius: 50)

                    Circle()
                        .fill(Color.appAccentMuted)
                        .frame(width: 140, height: 140)

                    Image(systemName: badge.icon)
                        .font(.system(size: 56))
                        .foregroundStyle(Color.appGold)
                }
                .scaleEffect(scale)

                Text(badge.title)
                    .font(.appTitle)
                    .foregroundStyle(Color.appTextPrimary)

                Text("\(badge.thresholdDays) jour\(badge.thresholdDays > 1 ? "s" : "") sans jouer")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appTextSecondary)

                Button("Continuer", action: onDismiss)
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 60)
                    .padding(.top, 20)
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1
                opacity = 1
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}

#Preview {
    BadgeUnlockOverlay(badge: allBadges[2], onDismiss: {})
}
