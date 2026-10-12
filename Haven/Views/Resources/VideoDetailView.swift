import SwiftUI

struct VideoDetailView: View {
    let video: ResourceVideo

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    player
                        .padding(.horizontal, 24)
                        .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(video.title)
                            .font(.appTitle)
                            .foregroundStyle(Color.appTextPrimary)

                        Text("\(video.speakerRole) · \(video.duration)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.appAccent)

                        Text(video.description)
                            .font(.appBody)
                            .foregroundStyle(Color.appTextSecondary)
                            .padding(.top, 6)

                        if let source = video.source {
                            Text("Source : \(source), chaîne YouTube officielle")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.appTextMuted)
                                .padding(.top, 4)
                        }

                        if let watchURL = video.youtubeWatchURL {
                            Link(destination: watchURL) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.up.right.square")
                                    Text("Voir sur YouTube")
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.appAccent)
                            }
                            .padding(.top, 6)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var player: some View {
        if let youtubeID = video.youtubeID {
            EmbeddedVideoView(youtubeID: youtubeID, startSeconds: video.startSeconds)
                .aspectRatio(16 / 9, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.appSurfaceElevated)
                    .frame(height: 220)

                VStack(spacing: 10) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.appTextMuted)

                    Text("Vidéo à venir")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.appTextMuted)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        VideoDetailView(video: resourceVideos[0])
    }
}
