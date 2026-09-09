import SwiftUI

struct JournalView: View {
    @ObservedObject private var betsService = BetsService.shared
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if betsService.entries.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(betsService.entries) { entry in
                            entryRow(entry)
                                .listRowBackground(Color.appBackground)
                        }
                    }
                    .scrollContentBackground(.hidden)
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
                Task { await betsService.fetchEntries() }
            }) {
                AddBetView()
            }
            .task {
                await betsService.fetchEntries()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(Color.appTextMuted)
            Text("Aucune mise enregistrée pour l'instant")
                .font(.appBody)
                .foregroundStyle(Color.appTextSecondary)
        }
    }

    private func entryRow(_ entry: BetLogEntry) -> some View {
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
}

#Preview {
    JournalView()
}
