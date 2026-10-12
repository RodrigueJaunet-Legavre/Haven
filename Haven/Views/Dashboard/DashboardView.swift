import SwiftUI

struct DashboardView: View {
    @ObservedObject private var store = AvatarStore.shared
    @ObservedObject private var streakStore = StreakStore.shared
    @ObservedObject private var completionStore = ActivityCompletionStore.shared
    @ObservedObject private var checkInService = CheckInService.shared
    @ObservedObject private var victoryService = VictoryService.shared
    @ObservedObject private var badgeStore = BadgeStore.shared
    @Environment(\.dismiss) private var dismiss

    @State private var showSettings = false
    @State private var showRelapseConfirm = false
    @State private var glowPulse = false

    private var tier: Int { AvatarStore.tier(for: store.vitalityScore) }

    private var tierColor: Color {
        switch tier {
        case 1: return Color.appDanger
        case 2: return Color.appWarning
        case 3: return Color.appGold
        case 4: return Color.appAccent
        default: return Color.appSuccess
        }
    }

    private var tierLabel: String {
        switch tier {
        case 1: return "Fragile"
        case 2: return "En reconstruction"
        case 3: return "Stable"
        case 4: return "En forme"
        default: return "Au sommet"
        }
    }

    private var dateHeader: String {
        Date().formatted(.dateTime.weekday(.wide).day().month(.wide).locale(Locale(identifier: "fr_FR"))).uppercased()
    }

    private var dailyBaselineLoss: Double {
        UserScope.defaults.double(forKey: "estimatedAnnualLoss") / 365
    }

    private var savedAmount: Double {
        dailyBaselineLoss * Double(streakStore.streakDays)
    }

    private var nextBadge: Badge? {
        allBadges.first { $0.thresholdDays > streakStore.streakDays }
    }

    private var previousThreshold: Int {
        allBadges.last { $0.thresholdDays <= streakStore.streakDays }?.thresholdDays ?? 0
    }

    private var milestoneProgress: Double {
        guard let next = nextBadge else { return 1 }
        let span = Double(next.thresholdDays - previousThreshold)
        guard span > 0 else { return 1 }
        return min(1, max(0, Double(streakStore.streakDays - previousThreshold) / span))
    }

    private var weekData: [(label: String, intensity: Int?)] {
        (0..<7).reversed().map { offset in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
            let entry = checkInService.entries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
            let label = String(date.formatted(.dateTime.weekday(.abbreviated).locale(Locale(identifier: "fr_FR"))).prefix(1)).uppercased()
            return (label: label, intensity: entry?.intensity)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        header

                        heroCard

                        if !checkInService.hasCheckedInToday {
                            checkInCard
                        }

                        milestoneCard

                        statsGrid

                        weekCard

                        shortcutsRow

                        Button {
                            showRelapseConfirm = true
                        } label: {
                            Text("J'ai rechuté")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.appDanger)
                        }
                        .padding(.top, 6)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundStyle(Color.appTextSecondary)
                }

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
            .confirmationDialog("Tu as recommencé à jouer ?", isPresented: $showRelapseConfirm, titleVisibility: .visible) {
                Button("Oui, enregistrer", role: .destructive) {
                    Task {
                        await BetsService.shared.addEntry(typeJeu: "Rechute", montant: 0, gainPerte: nil)
                        await streakStore.refresh()
                        TrustedContactStore.shared.recordRelapse()
                    }
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Ça reste entre toi et l'app. Ton score de vitalité et ta série de jours vont être mis à jour en conséquence.")
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                    glowPulse = true
                }
            }
            .task {
                await streakStore.refresh()
                await checkInService.fetchEntries()
                await victoryService.fetchEntries()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(dateHeader)
                .font(.system(size: 11, weight: .semibold))
                .tracking(1)
                .foregroundStyle(Color.appTextMuted)

            Text("Mon tableau de bord")
                .font(.system(size: 24, weight: .bold))
                .tracking(-0.4)
                .foregroundStyle(Color.appTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }

    private var heroCard: some View {
        HStack(spacing: 6) {
            NavigationLink {
                AvatarCreatorView()
            } label: {
                ZStack {
                    Circle()
                        .fill(tierColor.opacity(glowPulse ? 0.45 : 0.22))
                        .frame(width: 110, height: 110)
                        .blur(radius: 30)

                    AvatarView(config: store.config, vitalityScore: store.vitalityScore)
                        .scaleEffect(0.78)
                }
                .frame(width: 140, height: 180)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(streakStore.streakDays)")
                        .font(.system(size: 60, weight: .heavy))
                        .foregroundStyle(Color.appTextPrimary)

                    Text("jour\(streakStore.streakDays > 1 ? "s" : "") sans jouer")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.appTextSecondary)
                }

                HStack(spacing: 6) {
                    Circle()
                        .fill(tierColor)
                        .frame(width: 7, height: 7)

                    Text(tierLabel)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(tierColor)
                }

                VStack(alignment: .leading, spacing: 5) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.appSurfaceElevated)
                            Capsule()
                                .fill(tierColor)
                                .frame(width: geo.size.width * CGFloat(store.vitalityScore / 100))
                        }
                    }
                    .frame(height: 8)

                    Text("Vitalité \(Int(store.vitalityScore))/100")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.appTextMuted)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [tierColor.opacity(0.22), Color.appSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(tierColor.opacity(0.35), lineWidth: 1)
        )
    }

    private var checkInCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Comment te sens-tu aujourd'hui ?")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)

            HStack(spacing: 6) {
                ForEach(CheckInLevel.allCases) { level in
                    Button {
                        Task { await checkInService.addEntry(intensity: level.rawValue) }
                    } label: {
                        VStack(spacing: 4) {
                            Text(level.emoji)
                                .font(.system(size: 26))
                            Text(level.label)
                                .font(.system(size: 9))
                                .foregroundStyle(Color.appTextMuted)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20).fill(Color.appSurface)
        )
    }

    private var milestoneCard: some View {
        NavigationLink {
            BadgesView()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.appGold.opacity(0.16))
                        .frame(width: 48, height: 48)

                    Image(systemName: nextBadge?.icon ?? "trophy.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.appGold)
                }

                VStack(alignment: .leading, spacing: 7) {
                    if let next = nextBadge {
                        Text("Prochain badge : \(next.title)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.appTextPrimary)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.appSurfaceElevated)
                                Capsule()
                                    .fill(Color.appGold)
                                    .frame(width: geo.size.width * CGFloat(milestoneProgress))
                            }
                        }
                        .frame(height: 6)

                        let remaining = next.thresholdDays - streakStore.streakDays
                        Text("Encore \(remaining) jour\(remaining > 1 ? "s" : "")")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.appTextSecondary)
                    } else {
                        Text("Tous les badges sont débloqués")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.appTextPrimary)

                        Text("Bravo, tu es allé au bout du parcours.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.appTextMuted)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20).fill(Color.appSurface)
            )
        }
        .buttonStyle(.plain)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            if dailyBaselineLoss > 0 {
                statTile(
                    icon: "banknote.fill",
                    value: formattedMoney(savedAmount),
                    label: "économisés (estimé)",
                    tint: Color.appSuccess
                )
            } else {
                statTile(
                    icon: "checkmark.circle.fill",
                    value: "\(checkInService.entries.count)",
                    label: "check-ins",
                    tint: Color.appSuccess
                )
            }

            statTile(
                icon: "star.fill",
                value: "\(victoryService.entries.count)",
                label: "envies résistées",
                tint: Color.appGold
            )

            statTile(
                icon: "medal.fill",
                value: "\(badgeStore.unlockedBadgeIDs.count)/\(allBadges.count)",
                label: "badges",
                tint: Color.appAccent
            )

            statTile(
                icon: "sparkles",
                value: "\(completionStore.completedToday.count)/\(ActivityCompletionStore.maxActivitiesPerDay)",
                label: "activités aujourd'hui",
                tint: Color.appWarning
            )
        }
    }

    private func statTile(icon: String, value: String, label: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.18))
                    .frame(width: 34, height: 34)

                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(tint)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(label)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20).fill(Color.appSurface)
        )
    }

    private var weekCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Tes envies cette semaine")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)

                Text(checkInService.entries.isEmpty
                     ? "Fais ton premier check-in pour voir ta semaine apparaître ici."
                     : "Plus la barre est haute, plus l'envie était forte.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextMuted)
            }

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(weekData.enumerated()), id: \.offset) { item in
                    weekBar(item.element)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20).fill(Color.appSurface)
        )
    }

    private func weekBar(_ day: (label: String, intensity: Int?)) -> some View {
        VStack(spacing: 6) {
            ZStack(alignment: .bottom) {
                Color.clear.frame(height: 64)

                RoundedRectangle(cornerRadius: 6)
                    .fill(barColor(day.intensity))
                    .frame(height: barHeight(day.intensity))
            }

            Text(day.label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.appTextMuted)
        }
        .frame(maxWidth: .infinity)
    }

    private func barHeight(_ intensity: Int?) -> CGFloat {
        guard let intensity else { return 6 }
        return CGFloat(12 + intensity * 10)
    }

    private func barColor(_ intensity: Int?) -> Color {
        guard let intensity else { return Color.appSurfaceElevated }
        switch intensity {
        case 1: return Color.appSuccess
        case 2: return Color.appAccent
        case 3: return Color.appGold
        case 4: return Color.appWarning
        default: return Color.appDanger
        }
    }

    private var shortcutsRow: some View {
        HStack(spacing: 12) {
            NavigationLink {
                AvatarCreatorView()
            } label: {
                shortcutTile(icon: "person.crop.circle.fill", title: "Mon avatar")
            }
            .buttonStyle(.plain)

            NavigationLink {
                BadgesView()
            } label: {
                shortcutTile(icon: "medal.fill", title: "Mes badges")
            }
            .buttonStyle(.plain)
        }
    }

    private func shortcutTile(icon: String, title: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.appAccent)

            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16).fill(Color.appSurface)
        )
    }

    private func formattedMoney(_ value: Double) -> String {
        Int(value).formatted(.number.locale(Locale(identifier: "fr_FR"))) + " €"
    }
}

#Preview {
    DashboardView()
}
