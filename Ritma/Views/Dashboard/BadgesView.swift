import SwiftUI

struct BadgesView: View {
    @ObservedObject private var badgeStore = BadgeStore.shared

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(allBadges) { badge in
                        badgeTile(badge)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Badges")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func badgeTile(_ badge: Badge) -> some View {
        let isUnlocked = badgeStore.isUnlocked(badge)

        return VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.appAccentMuted : Color.appSurfaceElevated)
                    .frame(width: 72, height: 72)

                Image(systemName: isUnlocked ? badge.icon : "lock.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(isUnlocked ? Color.appGold : Color.appTextMuted)
            }

            Text(badge.title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(isUnlocked ? Color.appTextPrimary : Color.appTextMuted)
                .multilineTextAlignment(.center)

            Text("\(badge.thresholdDays)j")
                .font(.system(size: 10))
                .foregroundStyle(Color.appTextMuted)
        }
    }
}

#Preview {
    NavigationStack {
        BadgesView()
    }
}
