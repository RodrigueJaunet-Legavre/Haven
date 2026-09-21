import SwiftUI

struct EmergencyView: View {
    @ObservedObject private var store = EmergencyReasonsStore.shared
    @State private var isRevealed = false
    @State private var isPulsing = false
    @State private var showClosingScreen = false
    @State private var newReasonText = ""
    @State private var isAddingReason = false
    @State private var showResistCheck = false

    @State private var leadInCharCount = 0
    @State private var currentReasonIndex = 0
    @State private var skipTyping = false
    @State private var advanceRequested = false
    @State private var reasonOpacity: Double = 0
    @State private var bgBreathScale: CGFloat = 1
    @State private var textBreathScale: CGFloat = 1

    private let leadInText = "Rappelle-toi, tu as décidé d'arrêter les jeux d'argent pour"

    private var currentReasonText: String {
        guard store.reasons.indices.contains(currentReasonIndex) else { return "" }
        return store.reasons[currentReasonIndex].text
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if isRevealed {
                    if showClosingScreen {
                        closingScreen
                    } else {
                        readingScreen
                    }
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
            .confirmationDialog("Tu as tenu bon face à l'envie ?", isPresented: $showResistCheck, titleVisibility: .visible) {
                Button("Oui, j'ai résisté") {
                    Task { await VictoryService.shared.addEmergencyVictory() }
                    closeEverything()
                }
                Button("Non, pas cette fois", role: .cancel) {
                    Task {
                        await BetsService.shared.addEntry(typeJeu: "Rechute", montant: 0, gainPerte: nil)
                        await StreakStore.shared.refresh()
                        TrustedContactStore.shared.recordRelapse()
                    }
                    closeEverything()
                }
            }
        }
    }

    private func startReading() {
        leadInCharCount = 0
        currentReasonIndex = 0
        reasonOpacity = 0
        showClosingScreen = false
        TrustedContactStore.shared.recordEmergencyOpen()
    }

    private func closeEverything() {
        withAnimation(.appSpring) {
            isRevealed = false
            isAddingReason = false
            showClosingScreen = false
        }
    }

    private var alarmButton: some View {
        VStack(spacing: 24) {
            Spacer()

            Button {
                startReading()
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

    private var readingScreen: some View {
        ZStack {
            readingBackground

            VStack {
                Button("Passer") {
                    withAnimation(.appSpring) {
                        showClosingScreen = true
                    }
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.appTextMuted)
                .padding(.top, 20)
                .padding(.trailing, 24)
                .frame(maxWidth: .infinity, alignment: .trailing)

                Spacer()

                VStack(spacing: 18) {
                    Text(String(leadInText.prefix(leadInCharCount)))
                        .font(.system(size: 19, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)

                    if leadInCharCount >= leadInText.count, !currentReasonText.isEmpty {
                        Text(currentReasonText)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appTextPrimary)
                            .multilineTextAlignment(.center)
                            .opacity(reasonOpacity)
                    }
                }
                .padding(.horizontal, 36)
                .scaleEffect(textBreathScale)

                Spacer()

                if !store.reasons.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(store.reasons.indices, id: \.self) { index in
                            Circle()
                                .fill(index == currentReasonIndex ? Color.appAccent : Color.appBorder)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap()
        }
        .task {
            await runReadingSequence()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                bgBreathScale = 1.25
                textBreathScale = 1.03
            }
        }
    }

    private func handleTap() {
        if leadInCharCount < leadInText.count {
            skipTyping = true
        } else {
            advanceRequested = true
        }
    }

    private func runReadingSequence() async {
        leadInCharCount = 0
        skipTyping = false
        let leadChars = Array(leadInText)
        for i in 1...leadChars.count {
            if Task.isCancelled { return }
            if skipTyping {
                leadInCharCount = leadChars.count
                break
            }
            try? await Task.sleep(nanoseconds: 40_000_000)
            leadInCharCount = i
        }
        skipTyping = false
        try? await Task.sleep(nanoseconds: 400_000_000)

        if store.reasons.isEmpty {
            withAnimation(.appSpring) { showClosingScreen = true }
            return
        }

        for index in store.reasons.indices {
            if Task.isCancelled { return }
            currentReasonIndex = index
            advanceRequested = false

            withAnimation(.easeIn(duration: 0.6)) {
                reasonOpacity = 1
            }

            for _ in 0..<32 {
                if Task.isCancelled || advanceRequested { break }
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
            advanceRequested = false

            withAnimation(.easeOut(duration: 0.4)) {
                reasonOpacity = 0
            }
            try? await Task.sleep(nanoseconds: 450_000_000)
        }

        if Task.isCancelled { return }
        withAnimation(.appSpring) {
            showClosingScreen = true
        }
    }

    private var readingBackground: some View {
        ZStack {
            Color.appBackground

            Circle()
                .fill(Color.appAccent.opacity(0.18))
                .frame(width: 340, height: 340)
                .scaleEffect(bgBreathScale)
                .blur(radius: 90)
        }
        .ignoresSafeArea()
    }

    private var closingScreen: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 20)

                    VStack(spacing: 8) {
                        Text("Respire.")
                            .font(.appTitle)
                            .foregroundStyle(Color.appTextPrimary)

                        Text("L'envie passe. Elle ne dure jamais aussi longtemps qu'on le croit.")
                            .font(.appBody)
                            .foregroundStyle(Color.appTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 28)

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
                showResistCheck = true
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

            Text("pour \(reason.text)")
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
        VStack(alignment: .leading, spacing: 8) {
            Text("Je décide d'arrêter les jeux d'argent pour")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.appTextSecondary)

            HStack(spacing: 10) {
                TextField("ma fille, mes économies, ma dignité...", text: $newReasonText)
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
}

#Preview {
    EmergencyView()
}
