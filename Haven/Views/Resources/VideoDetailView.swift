import SwiftUI

struct VideoDetailView: View {
    let video: ResourceVideo

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 20) {
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
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        VideoDetailView(video: resourceVideos[0])
    }
}
