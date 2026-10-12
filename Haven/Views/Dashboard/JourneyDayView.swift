import SwiftUI

struct JourneyDayView: View {
    let day: JourneyDay

    @ObservedObject private var store = JourneyStore.shared
    @ObservedObject private var checkInService = CheckInService.shared
    @ObservedObject private var blockerStore = BlockerStore.shared
    @ObservedObject private var trustedContactStore = TrustedContactStore.shared
    @ObservedObject private var reasonsStore = EmergencyReasonsStore.shared
    @Environment(\.dismiss) private var dismiss

    @State private var newReason = ""

    private var isCompleted: Bool { store.isCompleted(day) }

    private var isActive: Bool {
        !isCompleted && day.number == store.completedCount + 1 && store.isUnlocked(day)
    }

    private var satisfiedCount: Int {
        day.requirements.filter { store.isSatisfied($0, for: day) }.count
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pourquoi cette étape")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.appTextSecondary)

                        Text(day.summary)
                            .font(.appBody)
                            .foregroundStyle(Color.appTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ton défi")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.appGold)

                        Text(day.task)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.appTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 20).fill(Color.appGold.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.appGold.opacity(0.35), lineWidth: 1)
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Objectifs · \(satisfiedCount)/\(day.requirements.count)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.appTextSecondary)

                        ForEach(Array(day.requirements.enumerated()), id: \.offset) { item in
                            requirementView(item.element)
                        }
                    }

                    action
                        .padding(.top, 6)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await checkInService.fetchEntries()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SEMAINE \(journeyWeekNumber(for: day.number)) · JOUR \(day.number)")
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(Color.appTextMuted)

            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.appAccent.opacity(0.18))
                        .frame(width: 48, height: 48)

                    Image(systemName: day.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.appAccent)
                }

                Text(day.title)
                    .font(.system(size: 24, weight: .bold))
                    .tracking(-0.4)
                    .foregroundStyle(Color.appTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text("\(day.minutes) minutes environ")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.appAccent)
        }
    }

    @ViewBuilder
    private func requirementView(_ requirement: JourneyRequirement) -> some View {
        let done = store.isSatisfied(requirement, for: day)

        VStack(alignment: .leading, spacing: 12) {
            switch requirement {
            case .writing(let fields):
                ForEach(fields) { field in
                    writingField(field)
                }
            case .choice(let id, let prompt, let options):
                choiceView(id: id, prompt: prompt, options: options)
            case .app(let check):
                appCheckView(check, done: done)
            case .breathing(let seconds):
                BreathingExerciseView(totalSeconds: seconds, isDone: done) {
                    store.setAnswer("done", day: day.number, field: "breathing")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18).fill(Color.appSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(done ? Color.appSuccess.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }

    private func binding(_ field: String) -> Binding<String> {
        Binding(
            get: { store.answer(day: day.number, field: field) },
            set: { store.setAnswer($0, day: day.number, field: field) }
        )
    }

    private func writingField(_ field: JourneyField) -> some View {
        let text = store.answer(day: day.number, field: field.id)
        let count = text.trimmingCharacters(in: .whitespacesAndNewlines).count
        let reached = count >= field.minCharacters

        return VStack(alignment: .leading, spacing: 8) {
            Text(field.label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)

            if isActive {
                TextField(field.placeholder, text: binding(field.id), axis: .vertical)
                    .lineLimit(1...5)
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12).fill(Color.appSurfaceElevated)
                    )

                HStack {
                    Spacer()

                    if reached {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.appSuccess)
                    } else {
                        Text("\(count)/\(field.minCharacters) caractères minimum")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.appTextMuted)
                    }
                }
            } else {
                Text(text.isEmpty ? "—" : text)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func choiceView(id: String, prompt: String, options: [String]) -> some View {
        let selected = store.answer(day: day.number, field: id)

        return VStack(alignment: .leading, spacing: 10) {
            Text(prompt)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)

            ForEach(options, id: \.self) { option in
                Button {
                    guard isActive else { return }
                    store.setAnswer(option, day: day.number, field: id)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: selected == option ? "largecircle.fill.circle" : "circle")
                            .foregroundStyle(selected == option ? Color.appAccent : Color.appTextMuted)

                        Text(option)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appTextPrimary)
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selected == option ? Color.appAccent.opacity(0.14) : Color.appSurfaceElevated)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func appCheckView(_ check: JourneyAppCheck, done: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 18))
                .foregroundStyle(done ? Color.appSuccess : Color.appTextMuted)

            VStack(alignment: .leading, spacing: 4) {
                Text(appCheckTitle(check))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)

                if !done {
                    Text(appCheckHint(check))
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }

        if !done && isActive {
            switch check {
            case .checkInToday:
                HStack(spacing: 4) {
                    ForEach(CheckInLevel.allCases) { level in
                        Button {
                            Task { await checkInService.addEntry(intensity: level.rawValue) }
                        } label: {
                            Text(level.emoji)
                                .font(.system(size: 26))
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            case .emergencyReasonAdded:
                VStack(alignment: .leading, spacing: 8) {
                    Text("Je décide d'arrêter les jeux d'argent pour")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appTextSecondary)

                    HStack(spacing: 10) {
                        TextField("ma fille, mes économies, ma dignité...", text: $newReason)
                            .foregroundStyle(Color.appTextPrimary)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12).fill(Color.appSurfaceElevated)
                            )

                        Button {
                            let trimmed = newReason.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            reasonsStore.addReason(trimmed)
                            newReason = ""
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(Color.appAccent)
                        }
                    }
                }
            case .trustedContact:
                VStack(spacing: 8) {
                    TextField("Nom", text: $trustedContactStore.name)
                        .foregroundStyle(Color.appTextPrimary)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12).fill(Color.appSurfaceElevated)
                        )

                    TextField("Numéro de téléphone", text: $trustedContactStore.phone)
                        .keyboardType(.phonePad)
                        .foregroundStyle(Color.appTextPrimary)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12).fill(Color.appSurfaceElevated)
                        )
                }
            case .blockerActive:
                EmptyView()
            }
        }
    }

    private func appCheckTitle(_ check: JourneyAppCheck) -> String {
        switch check {
        case .blockerActive: return "Blocage actif avec au moins 5 sites ou une application"
        case .trustedContact: return "Contact de confiance renseigné"
        case .checkInToday: return "Check-in du jour fait"
        case .emergencyReasonAdded: return "Nouvelle raison ajoutée à ta liste Emergency"
        }
    }

    private func appCheckHint(_ check: JourneyAppCheck) -> String {
        switch check {
        case .blockerActive: return "Va dans l'onglet Blocker : autorise le blocage, active le pack essentiel et/ou choisis tes applications, puis reviens ici."
        case .trustedContact: return "Renseigne le nom et le numéro de la personne ci-dessous."
        case .checkInToday: return "Touche l'émoji qui correspond à ton état du moment."
        case .emergencyReasonAdded: return "Écris ta nouvelle raison ci-dessous et ajoute-la."
        }
    }

    @ViewBuilder
    private var action: some View {
        if isCompleted {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                Text("Étape terminée")
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(Color.appSuccess)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                Capsule().fill(Color.appSuccess.opacity(0.14))
            )
        } else if isActive {
            VStack(spacing: 10) {
                Button("Valider l'étape") {
                    store.complete(day)
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!store.canComplete(day))
                .opacity(store.canComplete(day) ? 1 : 0.4)

                if !store.canComplete(day) {
                    Text("Remplis tous les objectifs ci-dessus pour valider l'étape.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appTextMuted)
                }
            }
        } else {
            Text("Cette étape n'est pas encore disponible.")
                .font(.system(size: 13))
                .foregroundStyle(Color.appTextMuted)
                .frame(maxWidth: .infinity)
        }
    }
}

struct BreathingExerciseView: View {
    let totalSeconds: Int
    let isDone: Bool
    let onFinished: () -> Void

    @State private var runID: UUID?
    @State private var remaining = 0
    @State private var phaseText = "Prêt ?"
    @State private var circleScale: CGFloat = 0.55

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.appAccent.opacity(0.16))
                    .frame(width: 170, height: 170)

                Circle()
                    .fill(Color.appAccent.opacity(0.5))
                    .frame(width: 170, height: 170)
                    .scaleEffect(isDone ? 1 : circleScale)

                Text(isDone ? "Terminé" : phaseText)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
            }
            .frame(height: 190)

            if isDone {
                Text("Exercice terminé, bien joué.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.appSuccess)
            } else if runID == nil {
                Button("Commencer (\(formatted(totalSeconds)))") {
                    remaining = totalSeconds
                    runID = UUID()
                }
                .buttonStyle(PrimaryButtonStyle())
            } else {
                Text(formatted(remaining))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)

                Button("Arrêter") {
                    runID = nil
                    phaseText = "Prêt ?"
                    circleScale = 0.55
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.appTextMuted)
            }

            #if DEBUG
            if !isDone {
                Button("Terminer maintenant (test)") {
                    runID = nil
                    onFinished()
                }
                .font(.system(size: 12))
                .foregroundStyle(Color.appTextMuted)
            }
            #endif
        }
        .frame(maxWidth: .infinity)
        .task(id: runID) {
            guard runID != nil else { return }
            await run()
        }
    }

    private func run() async {
        var second = 0
        remaining = totalSeconds

        while remaining > 0 {
            let position = second % 10
            if position == 0 {
                phaseText = "Inspire"
                withAnimation(.easeInOut(duration: 4)) { circleScale = 1.0 }
            } else if position == 4 {
                phaseText = "Expire"
                withAnimation(.easeInOut(duration: 6)) { circleScale = 0.55 }
            }

            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if Task.isCancelled { return }

            remaining -= 1
            second += 1
        }

        phaseText = "Prêt ?"
        circleScale = 0.55
        runID = nil
        onFinished()
    }

    private func formatted(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

#Preview {
    NavigationStack {
        JourneyDayView(day: journeyDays[0])
    }
}
