import SwiftUI

struct ResourcesView: View {
    @ObservedObject private var completionStore = ActivityCompletionStore.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
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

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Vidéos")
                                .font(.appHeadline)
                                .foregroundStyle(Color.appTextPrimary)

                            Text("Avec des professionnels de santé, addictologues et psychologues.")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .padding(.top, 8)

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
                    .padding(.horizontal, 28)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Ressources")
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
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
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appSurfaceElevated)
                    .frame(width: 64, height: 64)

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.appTextMuted)
            }

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
}

#Preview {
    ResourcesView()
}
