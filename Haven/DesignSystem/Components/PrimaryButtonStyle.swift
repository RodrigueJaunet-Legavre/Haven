import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 12) {
            configuration.label
                .font(.appHeadline)
                .foregroundStyle(Color.appBackground)

            Spacer()

            ZStack {
                Circle()
                    .fill(Color.appBackground.opacity(0.2))
                    .frame(width: 36, height: 36)

                Image(systemName: "arrow.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appBackground)
            }
            .offset(x: configuration.isPressed ? 4 : 0)
        }
        .padding(.leading, 24)
        .padding(.trailing, 8)
        .padding(.vertical, 12)
        .background(
            Capsule().fill(Color.appAccent)
        )
        .shadow(color: Color.appAccent.opacity(0.7), radius: configuration.isPressed ? 8 : 20, y: configuration.isPressed ? 2 : 6)
        .scaleEffect(configuration.isPressed ? 0.97 : 1)
        .animation(.appSpringSnappy, value: configuration.isPressed)
    }
}
