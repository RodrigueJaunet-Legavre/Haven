import SwiftUI

struct AvatarView: View {
    let config: AvatarConfig
    let vitalityScore: Double

    private var tier: Int {
        AvatarStore.tier(for: vitalityScore)
    }

    var body: some View {
        Group {
            if let characterIndex = config.characterIndex {
                Image("avatar\(characterIndex)_tier\(tier)")
                    .resizable()
                    .scaledToFit()
            } else {
                placeholder
            }
        }
        .frame(width: 170, height: 220)
    }

    private var placeholder: some View {
        VStack(spacing: 10) {
            Circle()
                .strokeBorder(Color.appBorder, style: StrokeStyle(lineWidth: 2, dash: [6]))
                .frame(width: 90, height: 90)
                .overlay(
                    Image(systemName: "person.fill.questionmark")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.appTextMuted)
                )

            Text("Personnalise ton avatar")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.appTextMuted)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        HStack(spacing: 12) {
            AvatarView(config: .default, vitalityScore: 50)
            AvatarView(config: AvatarConfig(characterIndex: 2), vitalityScore: 68)
        }
    }
}
