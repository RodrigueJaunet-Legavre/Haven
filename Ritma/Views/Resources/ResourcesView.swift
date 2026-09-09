import SwiftUI

struct ResourcesView: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            Text("Ressources — à venir")
                .font(.appHeadline)
                .foregroundStyle(Color.appTextPrimary)
        }
    }
}

#Preview {
    ResourcesView()
}
