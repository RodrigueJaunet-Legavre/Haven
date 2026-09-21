import SwiftUI
import UIKit

struct VitalityGainOverlay: View {
    let characterIndex: Int?
    let event: VitalityGainEvent
    let onDismiss: () -> Void

    @State private var displayedScore: Double
    @State private var currentTier: Int
    @State private var avatarScale: CGFloat = 0.6
    @State private var avatarOpacity: Double = 0
    @State private var showFlash = false
    @State private var showEvolutionLabel = false
    @State private var showContinueButton = false
    @State private var sparkles: [Sparkle] = []

    private var newTier: Int { AvatarStore.tier(for: event.newScore) }
    private var isEvolution: Bool { AvatarStore.tier(for: event.oldScore) != newTier }

    init(characterIndex: Int?, event: VitalityGainEvent, onDismiss: @escaping () -> Void) {
        self.characterIndex = characterIndex
        self.event = event
        self.onDismiss = onDismiss
        _displayedScore = State(initialValue: event.oldScore)
        _currentTier = State(initialValue: AvatarStore.tier(for: event.oldScore))
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.78).ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                avatarZone

                if showEvolutionLabel {
                    Text("Nouveau palier !")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appGold)
                        .transition(.scale.combined(with: .opacity))
                }

                progressZone
                    .padding(.horizontal, 44)

                Spacer()

                Button("Continuer", action: onDismiss)
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 60)
                    .padding(.bottom, 40)
                    .opacity(showContinueButton ? 1 : 0)
                    .disabled(!showContinueButton)
            }
        }
        .onAppear { runSequence() }
    }

    private var avatarZone: some View {
        ZStack {
            Circle()
                .fill(Color.appAccent.opacity(showFlash ? 0.55 : 0.22))
                .frame(width: 260, height: 260)
                .blur(radius: 60)

            ForEach(sparkles) { sparkle in
                Image(systemName: "sparkle")
                    .font(.system(size: sparkle.size))
                    .foregroundStyle(Color.appGold)
                    .offset(sparkle.offset)
                    .opacity(sparkle.opacity)
            }

            if let characterIndex {
                Image("avatar\(characterIndex)_tier\(currentTier)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170, height: 220)
                    .scaleEffect(avatarScale)
                    .opacity(avatarOpacity)
            }
        }
        .frame(height: 260)
    }

    private var progressZone: some View {
        VStack(spacing: 10) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.appSurfaceElevated)
                        .frame(height: 18)

                    Capsule()
                        .fill(
                            LinearGradient(colors: [Color.appAccent, Color.appGold], startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: geo.size.width * CGFloat(displayedScore / 100), height: 18)
                        .shadow(color: Color.appAccent.opacity(0.6), radius: 8)
                }
            }
            .frame(height: 18)

            Text("+\(Int(event.amount)) vitalité")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
        }
    }

    private func runSequence() {
        Task {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                avatarOpacity = 1
                avatarScale = 1
            }

            try? await Task.sleep(nanoseconds: 400_000_000)

            withAnimation(.easeOut(duration: 1.1)) {
                displayedScore = event.newScore
            }

            try? await Task.sleep(nanoseconds: 1_100_000_000)

            if isEvolution {
                UINotificationFeedbackGenerator().notificationOccurred(.success)

                withAnimation(.easeOut(duration: 0.15)) {
                    showFlash = true
                }
                withAnimation(.spring(response: 0.35, dampingFraction: 0.4)) {
                    avatarScale = 1.25
                }

                spawnSparkles()

                try? await Task.sleep(nanoseconds: 250_000_000)

                currentTier = newTier

                withAnimation(.spring(response: 0.5, dampingFraction: 0.55)) {
                    avatarScale = 1
                }
                withAnimation(.easeIn(duration: 0.4)) {
                    showFlash = false
                }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showEvolutionLabel = true
                }

                try? await Task.sleep(nanoseconds: 500_000_000)
            }

            withAnimation(.easeIn(duration: 0.3)) {
                showContinueButton = true
            }
        }
    }

    private func spawnSparkles() {
        sparkles = (0..<10).map { _ in
            Sparkle(
                offset: CGSize(width: .random(in: -110...110), height: .random(in: -110...110)),
                size: .random(in: 12...22),
                opacity: 1
            )
        }
        withAnimation(.easeOut(duration: 0.9)) {
            for index in sparkles.indices {
                sparkles[index].opacity = 0
            }
        }
    }
}

private struct Sparkle: Identifiable {
    let id = UUID()
    var offset: CGSize
    var size: CGFloat
    var opacity: Double
}

#Preview {
    VitalityGainOverlay(
        characterIndex: 2,
        event: VitalityGainEvent(oldScore: 58, newScore: 63, amount: 5),
        onDismiss: {}
    )
}
