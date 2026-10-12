import SwiftUI

struct JourneyView: View {
    @ObservedObject private var store = JourneyStore.shared
    @ObservedObject private var streakStore = StreakStore.shared
    @ObservedObject private var avatarStore = AvatarStore.shared
    @ObservedObject private var checkInService = CheckInService.shared

    @State private var selectedDay: Int?
    @State private var showStats = false
    @State private var showSettings = false
    @State private var showRestartConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                JourneyMapView { node in
                    selectedDay = node
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                topHUD
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomPanel
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedDay) { number in
                if let day = journeyDays.first(where: { $0.number == number }) {
                    JourneyDayView(day: day)
                }
            }
            .sheet(isPresented: $showStats) {
                DashboardView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .confirmationDialog("Recommencer le parcours ?", isPresented: $showRestartConfirm, titleVisibility: .visible) {
                Button("Oui, tout recommencer", role: .destructive) {
                    store.restart()
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Ta progression et tes réponses dans le parcours seront effacées. Tes jours sans jouer et tes badges ne sont pas concernés.")
            }
            .task {
                await streakStore.refresh()
                await checkInService.fetchEntries()
            }
        }
    }

    private var topHUD: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                chip(icon: "flame.fill", text: "\(streakStore.streakDays)", tint: Color.appWarning)
                chip(icon: "heart.fill", text: "\(Int(avatarStore.vitalityScore))", tint: Color.appAccent)
                chip(icon: "map.fill", text: "\(store.completedCount)/\(journeyDays.count)", tint: Color.appGold)

                Spacer()

                Button {
                    showStats = true
                } label: {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color.appSurface))
                }

                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color.appSurface))
                }

                if store.hasStarted {
                    Menu {
                        #if DEBUG
                        Button("Avancer d'un jour (test)") {
                            store.advanceOneDayForTesting()
                        }
                        #endif

                        Button("Recommencer le parcours", role: .destructive) {
                            showRestartConfirm = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.appTextSecondary)
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(Color.appSurface))
                    }
                }
            }

            if !checkInService.hasCheckedInToday {
                compactCheckIn
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(Color.appBackground.opacity(0.94))
    }

    private func chip(icon: String, text: String, tint: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(tint)

            Text(text)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Capsule().fill(Color.appSurface))
    }

    private var compactCheckIn: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Comment te sens-tu aujourd'hui ?")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appTextSecondary)

            HStack(spacing: 4) {
                ForEach(CheckInLevel.allCases) { level in
                    Button {
                        Task { await checkInService.addEntry(intensity: level.rawValue) }
                    } label: {
                        Text(level.emoji)
                            .font(.system(size: 24))
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16).fill(Color.appSurface)
        )
    }

    private var bottomPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !store.hasStarted {
                Text("Ton parcours de rémission")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)

                Text("30 jours, une étape par jour. Ton avatar avance à chaque défi relevé, jusqu'au trophée.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button("Commencer mon parcours") {
                    store.start()
                }
                .buttonStyle(PrimaryButtonStyle())
            } else if store.isFinished {
                Text("Parcours terminé")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)

                Text("Tu es allé au bout des 30 étapes. Bravo.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appTextSecondary)
            } else if let day = store.nextDayToDo {
                Text("JOUR \(day.number) · \(day.minutes) MIN")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.8)
                    .foregroundStyle(Color.appGold)

                Text(day.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)

                Button("Relever le défi") {
                    selectedDay = day.number
                }
                .buttonStyle(PrimaryButtonStyle())
            } else {
                HStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.appGold)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Prochaine étape bientôt disponible")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.appTextPrimary)

                        Text("Reviens \(whenText) : ton avatar t'attend au prochain palier.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24).fill(Color.appSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.appGold.opacity(store.nextDayToDo != nil ? 0.4 : 0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 16, y: -4)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    private var whenText: String {
        guard let day = store.currentDay, let date = store.unlockDate(for: day) else { return "bientôt" }
        if Calendar.current.isDateInTomorrow(date) { return "demain" }
        return "le " + date.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(Locale(identifier: "fr_FR")))
    }
}

#Preview {
    JourneyView()
}
