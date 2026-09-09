import SwiftUI

struct PGSIResultsView: View {
    let score: Int
    let category: PGSIRiskCategory

    @State private var goToSignUp = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 16) {
                    Text("Score : \(score)/27")
                        .font(.appDisplay)
                        .foregroundStyle(Color.appTextPrimary)

                    Text(category.rawValue)
                        .font(.appHeadline)
                        .foregroundStyle(Color.appAccent)
                }

                Spacer()

                Button("Continuer") {
                    goToSignUp = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
            }
        }
        .navigationDestination(isPresented: $goToSignUp) {
            SignUpView()
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        PGSIResultsView(score: 5, category: .moderate)
    }
}
