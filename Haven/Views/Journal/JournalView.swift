import SwiftUI

struct JournalView: View {
    @ObservedObject private var betsService = BetsService.shared
    @ObservedObject private var victoryService = VictoryService.shared
    @State private var showAddSheet = false
    @State private var selectedTab: JournalTab = .mises

    enum JournalTab: String, CaseIterable {
        case mises = "Mises"
        case victoires = "Victoires"
    }

    private var totalWagered: Double {
        betsService.entries.reduce(0) { $0 + $1.montant }
    }

    private var netBalance: Double {
        betsService.entries.compactMap { $0.gain_perte }.reduce(0, +)
    }

    private var victoriesThisWeek: Int {
        let cutoff = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        return victoryService.entries.filter { $0.date > cutoff }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    Picker("Vue", selection: $selectedTab) {
                        ForEach(JournalTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if selectedTab == .mises {
                                misesContent
                            } else {
                                victoriesContent
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Journal")
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.appAccent)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet, onDismiss: {
                Task {
                    await betsService.fetchEntries()
                    await victoryService.fetchEntries()
                }
            }) {
                if selectedTab == .mises {
                    AddBetView()
                } else {
                    AddVictoryView()
                }
            }
            .task {
                await betsService.fetchEntries()
                await victoryService.fetchEntries()
            }
        }
    }

    @ViewBuilder
    private var misesContent: some View {
        ctaCard(
            icon: "square.and.pencil",
            tint: Color.appAccent,
            title: "Note ce que tu as joué",
            message: "Le noter, c'est déjà reprendre la main. Ici, pas de jugement : juste la vérité, pour toi.",
            button: "Ajouter une entrée"
        )

        if betsService.entries.isEmpty {
            Text("Ton journal est vide pour l'instant. Quand tu seras prêt, note ta première entrée ci-dessus.")
                .font(.system(size: 13))
                .foregroundStyle(Color.appTextMuted)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 12)
        } else {
            HStack(spacing: 10) {
                miniStat(value: "\(betsService.entries.count)", label: "entrées", tint: Color.appTextPrimary)
                miniStat(value: formattedMoney(totalWagered), label: "misés", tint: Color.appGold)
                miniStat(
                    value: formattedSignedMoney(netBalance),
                    label: "bilan net",
                    tint: netBalance >= 0 ? Color.appSuccess : Color.appDanger
                )
            }

            ForEach(betsService.entries) { entry in
                betRow(entry)
            }
        }
    }

    @ViewBuilder
    private var victoriesContent: some View {
        ctaCard(
            icon: "star.fill",
            tint: Color.appGold,
            title: "Tu as résisté à une envie ?",
            message: "Chaque envie que tu laisses passer compte. Note-la : ton avatar y gagne de la vitalité.",
            button: "Noter une victoire"
        )

        if victoryService.entries.isEmpty {
            Text("Pas encore de victoire enregistrée. La prochaine fois que tu résistes, note-la ici.")
                .font(.system(size: 13))
                .foregroundStyle(Color.appTextMuted)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 12)
        } else {
            HStack(spacing: 10) {
                miniStat(value: "\(victoryService.entries.count)", label: "victoires", tint: Color.appGold)
                miniStat(value: "\(victoriesThisWeek)", label: "cette semaine", tint: Color.appSuccess)
            }

            ForEach(victoryService.entries) { entry in
                victoryRow(entry)
            }
        }
    }

    private func ctaCard(icon: String, tint: Color, title: String, message: String, button: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(tint)
                }

                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                showAddSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text(button)
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.appBackground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Capsule().fill(tint))
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [tint.opacity(0.18), Color.appSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(tint.opacity(0.3), lineWidth: 1)
        )
    }

    private func miniStat(value: String, label: String, tint: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color.appTextMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16).fill(Color.appSurface)
        )
    }

    private func betRow(_ entry: BetLogEntry) -> some View {
        let isRelapse = entry.type_jeu == "Rechute"
        let tint = isRelapse ? Color.appDanger : Color.appAccent

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.16))
                    .frame(width: 40, height: 40)

                Image(systemName: isRelapse ? "exclamationmark.triangle.fill" : "die.face.5.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(tint)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.type_jeu)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)

                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextMuted)
            }

            Spacer()

            if !isRelapse {
                VStack(alignment: .trailing, spacing: 3) {
                    Text("\(Int(entry.montant)) € misés")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appTextSecondary)

                    if let gainPerte = entry.gain_perte {
                        Text(gainPerte >= 0 ? "+\(Int(gainPerte)) €" : "\(Int(gainPerte)) €")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(gainPerte >= 0 ? Color.appSuccess : Color.appDanger)
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18).fill(Color.appSurface)
        )
    }

    private func victoryRow(_ entry: Victory) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.appGold.opacity(0.16))
                    .frame(width: 40, height: 40)

                Image(systemName: "star.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appGold)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextMuted)

                if let note = entry.note, !note.isEmpty {
                    Text(note)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("Envie résistée")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appTextSecondary)
                        .italic()
                }
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18).fill(Color.appSurface)
        )
    }

    private func formattedMoney(_ value: Double) -> String {
        Int(value).formatted(.number.locale(Locale(identifier: "fr_FR"))) + " €"
    }

    private func formattedSignedMoney(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : "-"
        return sign + Int(abs(value)).formatted(.number.locale(Locale(identifier: "fr_FR"))) + " €"
    }
}

#Preview {
    JournalView()
}
