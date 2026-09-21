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

                    if selectedTab == .mises {
                        misesContent
                    } else {
                        victoriesContent
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

    private var misesContent: some View {
        Group {
            if betsService.entries.isEmpty {
                emptyState(text: "Aucune mise enregistrée pour l'instant", icon: "tray")
            } else {
                List {
                    ForEach(betsService.entries) { entry in
                        betRow(entry)
                            .listRowBackground(Color.appBackground)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
    }

    private var victoriesContent: some View {
        Group {
            if victoryService.entries.isEmpty {
                emptyState(text: "Pas encore de victoire enregistrée — la prochaine fois que tu résistes à une envie, note-la ici", icon: "star")
            } else {
                List {
                    ForEach(victoryService.entries) { entry in
                        victoryRow(entry)
                            .listRowBackground(Color.appBackground)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
    }

    private func emptyState(text: String, icon: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(Color.appTextMuted)
            Text(text)
                .font(.appBody)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func betRow(_ entry: BetLogEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.type_jeu)
                    .font(.appHeadline)
                    .foregroundStyle(Color.appTextPrimary)
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextMuted)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(entry.montant)) € misés")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextSecondary)

                if let gainPerte = entry.gain_perte {
                    Text(gainPerte >= 0 ? "+\(Int(gainPerte)) €" : "\(Int(gainPerte)) €")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(gainPerte >= 0 ? Color.appSuccess : Color.appDanger)
                }
            }
        }
        .padding(.vertical, 6)
    }

    private func victoryRow(_ entry: Victory) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "star.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color.appGold)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextMuted)

                if let note = entry.note, !note.isEmpty {
                    Text(note)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appTextPrimary)
                } else {
                    Text("Envie résistée")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appTextSecondary)
                        .italic()
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    JournalView()
}
