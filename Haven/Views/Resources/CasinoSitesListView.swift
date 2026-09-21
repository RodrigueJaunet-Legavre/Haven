import SwiftUI

struct CasinoSitesListView: View {
    @ObservedObject private var store = BlockerStore.shared
    @State private var searchText = ""

    private var filteredSites: [GamblingSite] {
        if searchText.isEmpty {
            return knownCasinoSites
        }
        return knownCasinoSites.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.domain.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 8) {
                    Text("\(store.blockedDomains.filter { domain in knownCasinoSites.contains { $0.domain == domain } }.count) sélectionné(s) sur \(knownCasinoSites.count)")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appTextMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)

                    ForEach(filteredSites) { site in
                        siteRow(site)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Casinos en ligne")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Rechercher un site")
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func siteRow(_ site: GamblingSite) -> some View {
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
}

#Preview {
    NavigationStack {
        CasinoSitesListView()
    }
}
