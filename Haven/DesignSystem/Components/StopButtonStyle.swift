import SwiftUI

struct StopButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                Capsule().fill(Color.appAccent)
            )
            .shadow(color: Color.appAccent.opacity(0.8), radius: configuration.isPressed ? 10 : 24, y: configuration.isPressed ? 2 : 6)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.appSpringSnappy, value: configuration.isPressed)
    }
}
