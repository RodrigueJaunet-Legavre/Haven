import SwiftUI

struct QuestionIllustration: View {
    let imageName: String

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        QuestionIllustration(imageName: "PGSI_0")
    }
}
