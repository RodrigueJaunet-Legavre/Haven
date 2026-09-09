import SwiftUI

struct EmergencyView: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            Text("Emergency — à venir")
                .font(.appHeadline)
                .foregroundStyle(Color.appTextPrimary)
        }
    }
}

#Preview {
    EmergencyView()
}
