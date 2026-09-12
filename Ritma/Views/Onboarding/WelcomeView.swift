import SwiftUI

struct WelcomeView: View {
    @State private var isVisible = false
    @State private var totalLost = 0
    @State private var currentNotification: MockNotification?
    @State private var notificationOffset: CGFloat = -160
    @State private var notificationIndex = 0
    @State private var amountIndex = 0
    @State private var neonAmount: Int?
    @State private var neonScale: CGFloat = 0.6
    @State private var neonOpacity: Double = 0
    @State private var neonFlicker: Double = 1
    @State private var haloPulse = false
    @State private var goToGamesSelection = false

    private let crescendoAmounts = [25, 40, 55, 70, 85, 100]

    var body: some View {
        ZStack(alignment: .top) {
            backgroundLayer

            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 90)

                neonLossZone

                Spacer()

                totalLostPill
                    .padding(.horizontal, 28)

                headlineBlock
                    .padding(.horizontal, 28)
                    .padding(.top, 20)

                Spacer()

                actionRow
                    .padding(.horizontal, 28)
                    .padding(.bottom, 48)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 16)
            }

            if let notification = currentNotification {
                NotificationBanner(notification: notification)
                    .offset(y: notificationOffset)
                    .padding(.top, 12)
            }
        }
        .navigationDestination(isPresented: $goToGamesSelection) {
            GamesSelectionView()
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.appSpring.delay(0.1)) {
                isVisible = true
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                haloPulse = true
            }
        }
        .task {
            while true {
                await showNextNotification()
                try? await Task.sleep(nanoseconds: 600_000_000)
            }
        }
    }

    private func showNextNotification() async {
        let notification = mockNotifications[notificationIndex % mockNotifications.count]
        notificationIndex += 1
        currentNotification = notification

        let amount = crescendoAmounts[amountIndex % crescendoAmounts.count]
        amountIndex += 1

        withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
            notificationOffset = 0
        }

        try? await Task.sleep(nanoseconds: 700_000_000)

        await flashNeonLoss(amount: amount)

        try? await Task.sleep(nanoseconds: 300_000_000)

        withAnimation(.easeIn(duration: 0.35)) {
            notificationOffset = -160
        }

        try? await Task.sleep(nanoseconds: 350_000_000)
        currentNotification = nil

        if totalLost >= 5000 {
            totalLost = 0
        }
    }

    private func flashNeonLoss(amount: Int) async {
        neonAmount = amount
        neonScale = 0.6
        neonOpacity = 0

        withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) {
            neonScale = 1.08
            neonOpacity = 1
        }

        neonFlicker = 0.3
        try? await Task.sleep(nanoseconds: 40_000_000)
        neonFlicker = 1
        try? await Task.sleep(nanoseconds: 30_000_000)
        neonFlicker = 0.4
        try? await Task.sleep(nanoseconds: 40_000_000)
        neonFlicker = 1

        withAnimation(.appSpringSnappy) {
            neonScale = 1
        }

        withAnimation(.easeOut(duration: 0.4)) {
            totalLost += amount
        }

        try? await Task.sleep(nanoseconds: 750_000_000)

        withAnimation(.easeIn(duration: 0.3)) {
            neonOpacity = 0
            neonScale = 0.85
        }
        try? await Task.sleep(nanoseconds: 300_000_000)
        neonAmount = nil
    }

    private func neonFontSize(for amount: Int) -> CGFloat {
        let minAmount: CGFloat = 25
        let maxAmount: CGFloat = 100
        let minSize: CGFloat = 58
        let maxSize: CGFloat = 106

        let clamped = min(max(CGFloat(amount), minAmount), maxAmount)
        let ratio = (clamped - minAmount) / (maxAmount - minAmount)
        return minSize + ratio * (maxSize - minSize)
    }

    private func neonGlowRadius(for amount: Int) -> CGFloat {
        let minAmount: CGFloat = 25
        let maxAmount: CGFloat = 100
        let minRadius: CGFloat = 24
        let maxRadius: CGFloat = 54

        let clamped = min(max(CGFloat(amount), minAmount), maxAmount)
        let ratio = (clamped - minAmount) / (maxAmount - minAmount)
        return minRadius + ratio * (maxRadius - minRadius)
    }

    private var neonLossZone: some View {
        ZStack {
            if let amount = neonAmount {
                Text("-\(amount) €")
                    .font(.system(size: neonFontSize(for: amount), weight: .heavy, design: .default))
                    .foregroundStyle(.white)
                    .shadow(color: .white, radius: 4)
                    .shadow(color: Color.appDanger, radius: neonGlowRadius(for: amount) * 0.5)
                    .shadow(color: Color.appDanger.opacity(0.9), radius: neonGlowRadius(for: amount))
                    .scaleEffect(neonScale)
                    .opacity(neonOpacity * neonFlicker)
            }
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
    }

    private var totalLostPill: some View {
        HStack(spacing: 6) {
            Text("perdu depuis l'ouverture")
                .font(.system(size: 12))
                .foregroundStyle(Color.appTextMuted)

            Text(totalLost.formatted(.number.locale(Locale(identifier: "fr_FR"))) + " €")
                .font(.system(size: 13, weight: .bold, design: .default))
                .monospacedDigit()
                .foregroundStyle(Color.appGold)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule().fill(Color.appSurface)
        )
        .overlay(
            Capsule().stroke(Color.appBorder, lineWidth: 1)
        )
        .opacity(isVisible ? 1 : 0)
    }

    private var headlineBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reprends la main.")
                .font(.appDisplay)
                .tracking(-1)
                .foregroundStyle(Color.appTextPrimary)
                .shadow(color: Color.appAccent.opacity(0.6), radius: 12)

            Text("Haven t'accompagne pour sortir des jeux d'argent, à ton rythme.")
                .font(.appBody)
                .foregroundStyle(Color.appTextSecondary)
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 16)
    }

    private var actionRow: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                ghostAction(title: "Retirer")
                ghostAction(title: "Déposer")
            }

            Button {
                goToGamesSelection = true
            } label: {
                HStack {
                    Text("Arrêter")
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                }
            }
            .buttonStyle(StopButtonStyle())

            Text("Fais le test en 2 minutes pour évaluer ta situation")
                .font(.appCaption)
                .foregroundStyle(Color.appTextMuted)
        }
    }

    private func ghostAction(title: String) -> some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold, design: .default))
            .foregroundStyle(Color.appTextMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                Capsule().fill(Color.appSurface)
            )
            .overlay(
                Capsule().stroke(Color.appBorder, lineWidth: 1)
            )
            .opacity(0.5)
    }

    private var backgroundLayer: some View {
        ZStack {
            Color.appBackground

            Circle()
                .fill(Color.appAccent.opacity(haloPulse ? 0.3 : 0.15))
                .frame(width: 280, height: 280)
                .blur(radius: 100)
                .offset(x: -130, y: -260)

            Circle()
                .fill(Color.appGold.opacity(haloPulse ? 0.2 : 0.1))
                .frame(width: 220, height: 220)
                .blur(radius: 90)
                .offset(x: 140, y: 80)

            Circle()
                .fill(Color.appDanger.opacity(haloPulse ? 0.15 : 0.06))
                .frame(width: 200, height: 200)
                .blur(radius: 100)
                .offset(x: -60, y: 300)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
    }
}
