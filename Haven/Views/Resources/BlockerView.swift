import SwiftUI
import FamilyControls

struct BlockerView: View {
    @ObservedObject private var store = BlockerStore.shared
    @State private var showAppPicker = false
    @State private var newDomain = ""
    @State private var isRequestingAuthorization = false
    @State private var showEssentialPackConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerBlock

                        if store.isAuthorized {
                            mainToggleCard
                            appsSection
                            essentialPackButton
                            suggestedSitesSection
                            casinoSitesLinkSection
                            domainsSection
                        } else {
                            authorizationCard
                        }

                        infoNote
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Blocker")
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .familyActivityPicker(isPresented: $showAppPicker, selection: $store.selection)
        }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Coupe l'accès à la tentation")
                .font(.appHeadline)
                .foregroundStyle(Color.appTextPrimary)

            Text("Bloque les apps et les sites de paris directement sur ton téléphone.")
                .font(.system(size: 13))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var authorizationCard: some View {
        VStack(spacing: 14) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color.appAccent)

            Text("Haven a besoin de ton autorisation pour bloquer des apps et des sites, via le contrôle parental d'Apple (Temps d'écran).")
                .font(.system(size: 13))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)

            Button {
                isRequestingAuthorization = true
                Task {
                    await store.requestAuthorization()
                    isRequestingAuthorization = false
                }
            } label: {
                Text(isRequestingAuthorization ? "Demande en cours..." : "Autoriser le blocage")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isRequestingAuthorization)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20).fill(Color.appSurface)
        )
    }

    private var mainToggleCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(store.isBlockingEnabled ? Color.appAccentMuted : Color.appSurfaceElevated)
                    .frame(width: 48, height: 48)

                Image(systemName: store.isBlockingEnabled ? "lock.fill" : "lock.open.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(store.isBlockingEnabled ? Color.appAccent : Color.appTextMuted)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(store.isBlockingEnabled ? "Blocage activé" : "Blocage désactivé")
                    .font(.system(size: 15, weight: .semibold, design: .default))
                    .foregroundStyle(Color.appTextPrimary)

                Text(store.isBlockingEnabled ? "Tu as choisi de te protéger" : "Active-le pour te protéger")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer()

            if store.isBlockingEnabled {
                if let pendingDate = store.pendingDisableDate {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Désactivation à \(pendingDate.formatted(date: .omitted, time: .shortened))")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.appTextMuted)

                        Button("Annuler") {
                            store.cancelPendingDisable()
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.appAccent)
                    }
                } else {
                    Button("Désactiver") {
                        store.requestDisable()
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appDanger)
                }
            } else {
                Toggle("", isOn: $store.isBlockingEnabled)
                    .labelsHidden()
                    .tint(Color.appAccent)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20).fill(Color.appSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20).stroke(store.isBlockingEnabled ? Color.appAccent.opacity(0.4) : Color.appBorder, lineWidth: 1)
        )
    }

    private var appsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Applications à bloquer")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.appTextSecondary)

            Button {
                showAppPicker = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "apps.iphone")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.appAccent)

                    Text(appsSummary)
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundStyle(Color.appTextPrimary)

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
        }
    }

    private var appsSummary: String {
        let appCount = store.selection.applicationTokens.count
        let categoryCount = store.selection.categoryTokens.count
        if appCount == 0 && categoryCount == 0 {
            return "Choisir les apps à bloquer"
        }
        var parts: [String] = []
        if appCount > 0 { parts.append("\(appCount) app\(appCount > 1 ? "s" : "")") }
        if categoryCount > 0 { parts.append("\(categoryCount) catégorie\(categoryCount > 1 ? "s" : "")") }
        return parts.joined(separator: ", ")
    }

    private var essentialPackButton: some View {
        Button {
            showEssentialPackConfirm = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.appGold)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Activer le pack essentiel")
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundStyle(Color.appTextPrimary)

                    Text("Les 50 sites les plus courants, en un tap")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appTextSecondary)
                }

                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16).fill(Color.appAccentMuted)
            )
        }
        .confirmationDialog("Remplacer ta sélection actuelle par le pack essentiel (50 sites) ?", isPresented: $showEssentialPackConfirm, titleVisibility: .visible) {
            Button("Oui, activer le pack") {
                store.applyEssentialPack()
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Ça remplace ta liste de sites bloqués actuelle. Tu pourras toujours ajuster ensuite.")
        }
    }

    private var suggestedSitesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sites de paris agréés en France")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appTextSecondary)

                Text("Sélectionne ceux que tu veux bloquer directement.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextMuted)
            }

            VStack(spacing: 8) {
                ForEach(knownGamblingSites) { site in
                    suggestedSiteRow(site)
                }
            }
        }
    }

    private var casinoSitesLinkSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Casinos en ligne")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appTextSecondary)

                Text("Tous interdits en France — plus de 200 sites recensés par l'ANJ.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextMuted)
            }

            NavigationLink {
                CasinoSitesListView()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "die.face.5.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.appAccent)

                    Text(casinoSummary)
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundStyle(Color.appTextPrimary)

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
        }
    }

    private var casinoSummary: String {
        let count = store.blockedDomains.filter { domain in knownCasinoSites.contains { $0.domain == domain } }.count
        return count == 0 ? "Parcourir la liste (\(knownCasinoSites.count) sites)" : "\(count) casino\(count > 1 ? "s" : "") sélectionné\(count > 1 ? "s" : "")"
    }

    private func suggestedSiteRow(_ site: GamblingSite) -> some View {
        let isSelected = store.blockedDomains.contains(site.domain)

        return Button {
            if isSelected {
                store.removeDomain(site.domain)
            } else {
                store.addDomain(site.domain)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundStyle(isSelected ? Color.appAccent : Color.appTextMuted)

                Text(site.name)
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundStyle(Color.appTextPrimary)

                Spacer()

                Text(site.domain)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.appTextMuted)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14).fill(Color.appSurface)
            )
        }
        .buttonStyle(.plain)
    }

    private var domainsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Autres sites à bloquer")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appTextSecondary)

                Text("Pour un site que tu utilises et qui ne figure pas encore dans les listes ci-dessus.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextMuted)
            }

            ForEach(store.blockedDomains.filter { domain in
                !knownGamblingSites.contains { $0.domain == domain } &&
                !knownCasinoSites.contains { $0.domain == domain }
            }, id: \.self) { domain in
                domainRow(domain)
            }

            HStack(spacing: 10) {
                TextField("exemple.com", text: $newDomain)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 14).fill(Color.appSurface)
                    )

                Button {
                    store.addDomain(newDomain)
                    newDomain = ""
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.appAccent)
                }
                .disabled(newDomain.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func domainRow(_ domain: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "network")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.appTextSecondary)
                .frame(width: 24)

            Text(domain)
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            Button {
                store.removeDomain(domain)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.appTextMuted)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16).fill(Color.appSurface)
        )
    }

    private var infoNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.appTextMuted)

            Text("Le blocage s'applique aux apps que tu sélectionnes (installées ou par catégorie) et à Safari uniquement — pas aux autres navigateurs. 50 sites maximum au total (choisis en priorité ceux que tu utilises réellement, ou active le pack essentiel ci-dessus). Désactiver le blocage prend effet 2 heures après la demande, pour éviter une décision impulsive.")
                .font(.system(size: 12))
                .foregroundStyle(Color.appTextMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14).fill(Color.appSurface)
        )
    }
}

#Preview {
    BlockerView()
}
