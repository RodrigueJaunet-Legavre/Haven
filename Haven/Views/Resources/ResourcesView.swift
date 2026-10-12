import SwiftUI

struct ResourcesView: View {
    @ObservedObject private var completionStore = ActivityCompletionStore.shared
    @State private var selectedTab: ResourcesTab = .activities

    enum ResourcesTab: String, CaseIterable {
        case activities = "Activités"
        case videos = "Vidéos"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    Picker("Catégorie", selection: $selectedTab) {
                        ForEach(ResourcesTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            if selectedTab == .activities {
                                activitiesContent
                            } else {
                                videosContent
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 12)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Ressources")
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    @ViewBuilder
    private var activitiesContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Activités de remplacement")
                    .font(.appHeadline)
                    .foregroundStyle(Color.appTextPrimary)

                Spacer()

                Text("\(completionStore.completedToday.count)/\(ActivityCompletionStore.maxActivitiesPerDay) aujourd'hui")
                    .font(.system(size: 12, weight: .semibold, design: .default))
                    .foregroundStyle(Color.appTextMuted)
            }

            Text("Des alternatives qui activent le même circuit de récompense, sans le risque. \(ActivityCompletionStore.maxActivitiesPerDay) validations par jour maximum, une par activité.")
                .font(.system(size: 13))
                .foregroundStyle(Color.appTextSecondary)
        }

        VStack(spacing: 12) {
            ForEach(replacementActivities) { activity in
                activityRow(activity)
            }
        }
    }

    @ViewBuilder
    private var videosContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Vidéos")
                .font(.appHeadline)
                .foregroundStyle(Color.appTextPrimary)

            Text("Des explications et des témoignages pour comprendre l'addiction aux jeux d'argent.")
                .font(.system(size: 13))
                .foregroundStyle(Color.appTextSecondary)
        }

        VStack(spacing: 12) {
            ForEach(resourceVideos) { video in
                NavigationLink {
                    VideoDetailView(video: video)
                } label: {
                    videoRow(video)
                }
            }
        }
    }

    private func activityRow(_ activity: ReplacementActivity) -> some View {
        let isDone = completionStore.isCompleted(activity)
        let isLocked = !isDone && completionStore.hasReachedDailyLimit

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.appAccentMuted)
                    .frame(width: 44, height: 44)

                Image(systemName: activity.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
            }
            .opacity(isLocked ? 0.4 : 1)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(activity.title)
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundStyle(isLocked ? Color.appTextMuted : Color.appTextPrimary)

                    Text("+\(activity.points) pts")
                        .font(.system(size: 11, weight: .bold, design: .default))
                        .foregroundStyle(isLocked ? Color.appTextMuted : Color.appGold)
                }

                Text(isLocked ? "Limite quotidienne atteinte" : activity.explanation)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button {
                withAnimation(.appSpringSnappy) {
                    completionStore.complete(activity)
                }
            } label: {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 26))
                    .foregroundStyle(isDone ? Color.appSuccess : (isLocked ? Color.appTextMuted.opacity(0.4) : Color.appTextMuted))
            }
            .disabled(isDone || isLocked)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18).fill(Color.appSurface)
        )
        .opacity(isLocked ? 0.6 : 1)
    }

    private func videoRow(_ video: ResourceVideo) -> some View {
        HStack(spacing: 14) {
            videoThumbnail(video)

            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.leading)

                Text("\(video.speakerRole) · \(video.duration)")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18).fill(Color.appSurface)
        )
    }

    private func videoThumbnail(_ video: ResourceVideo) -> some View {
        ZStack {
            if let url = video.thumbnailURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Color.appSurfaceElevated
                    }
                }
            } else {
                Color.appSurfaceElevated
            }

            Image(systemName: "play.circle.fill")
                .font(.system(size: 26))
                .foregroundStyle(video.thumbnailURL == nil ? Color.appTextMuted : Color.white.opacity(0.92))
                .shadow(color: .black.opacity(video.thumbnailURL == nil ? 0 : 0.5), radius: 4)
        }
        .frame(width: 100, height: 64)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ResourcesView()
}
