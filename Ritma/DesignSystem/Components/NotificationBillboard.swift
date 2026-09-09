import SwiftUI

struct MockNotification: Identifiable {
    let id = UUID()
    let iconSymbol: String
    let iconColor: Color
    let sender: String
    let message: String
    let amountLost: Int
}

let mockNotifications: [MockNotification] = [
    MockNotification(iconSymbol: "sportscourt.fill", iconColor: Color(hex: "FF1053"), sender: "CoteMax", message: "Cote boostée x4 sur PSG - OM, ce soir seulement", amountLost: 25),
    MockNotification(iconSymbol: "person.fill", iconColor: Color(hex: "39FF7A"), sender: "Julien", message: "On se fait un casino ce soir ? 🎰", amountLost: 50),
    MockNotification(iconSymbol: "flame.fill", iconColor: Color(hex: "FF8A00"), sender: "BetWave", message: "Ton pari gagnant d'hier, retente ta chance", amountLost: 15),
    MockNotification(iconSymbol: "person.fill", iconColor: Color(hex: "39FF7A"), sender: "Léa", message: "Table de poker chez Max samedi, tu viens ?", amountLost: 40),
    MockNotification(iconSymbol: "trophy.fill", iconColor: Color(hex: "FFD60A"), sender: "SpinPalace", message: "Bonus : 100 € offerts sur ta première mise", amountLost: 30)
]

struct NotificationBanner: View {
    let notification: MockNotification

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(notification.iconColor)
                    .frame(width: 36, height: 36)
                    .shadow(color: notification.iconColor, radius: 10)
                    .shadow(color: notification.iconColor.opacity(0.8), radius: 20)

                Image(systemName: notification.iconSymbol)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(notification.sender)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    Text("maintenant")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.appTextMuted)
                }
                Text(notification.message)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(12)
        .background(Color.appSurfaceElevated, in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(notification.iconColor, lineWidth: 1.5)
        )
        .shadow(color: notification.iconColor.opacity(0.5), radius: 16, y: 4)
        .padding(.horizontal, 20)
    }
}
