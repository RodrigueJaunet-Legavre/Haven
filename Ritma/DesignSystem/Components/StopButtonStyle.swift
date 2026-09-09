import SwiftUI

struct StopButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 12) {
            configuration.label
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            ZStack {
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 36, height: 36)

                Image(systemName: "arrow.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .offset(x: configuration.isPressed ? 4 : 0)
        }
        .padding(.leading, 24)
        .padding(.trailing, 8)
        .padding(.vertical, 12)
        .background(
            Capsule().fill(Color.appDanger)
        )
        .shadow(color: Color.appDanger.opacity(0.8), radius: configuration.isPressed ? 10 : 24, y: configuration.isPressed ? 2 : 6)
        .scaleEffect(configuration.isPressed ? 0.96 : 1)
        .animation(.appSpringSnappy, value: configuration.isPressed)
    }
}
