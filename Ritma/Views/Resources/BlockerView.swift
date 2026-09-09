import SwiftUI

struct BlockerView: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            Text("Blocage des apps — à venir")
                .font(.appHeadline)
                .foregroundStyle(Color.appTextPrimary)
        }
    }
}

#Preview {
    BlockerView()
}
