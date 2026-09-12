import SwiftUI
import FamilyControls

struct BlockerView: View {
    @ObservedObject private var store = BlockerStore.shared
    @State private var showAppPicker = false
    @State private var newDomain = ""
    @State private var isRequestingAuthorization = false

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

            Toggle("", isOn: $store.isBlockingEnabled)
                .labelsHidden()
                .tint(Color.appAccent)
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

    private var domainsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sites à bloquer sur Safari")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.appTextSecondary)

            ForEach(store.blockedDomains, id: \.self) { domain in
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

            Text("Le blocage s'applique aux apps que tu sélectionnes (installées ou par catégorie) et à Safari uniquement — pas aux autres navigateurs. Ajoute ici les sites précis que tu veux bloquer (50 maximum).")
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
