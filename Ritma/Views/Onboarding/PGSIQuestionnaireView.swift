import SwiftUI

struct PGSIQuestionnaireView: View {
    @State private var currentIndex = 0
    @State private var answers: [Int: Int] = [:]
    @State private var isVisible = false
    @State private var goToResults = false

    private var progress: CGFloat {
        CGFloat(currentIndex) / CGFloat(pgsiQuestions.count)
    }

    private var totalScore: Int {
        answers.values.reduce(0, +)
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                topBar
                    .padding(.horizontal, 28)
                    .padding(.top, 16)

                Spacer(minLength: 40)

                questionCard
                    .padding(.horizontal, 28)
                    .id(currentIndex)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

                Spacer()
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $goToResults) {
            PGSIResultsView(score: totalScore, category: PGSIRiskCategory.from(score: totalScore))
        }
        .onAppear {
            withAnimation(.appSpring.delay(0.1)) {
                isVisible = true
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 14) {
            Button {
                if currentIndex > 0 {
                    withAnimation(.appSpring) {
                        currentIndex -= 1
                    }
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(currentIndex > 0 ? Color.appTextPrimary : Color.appTextMuted)
            }
            .disabled(currentIndex == 0)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.appSurfaceElevated)
                        .frame(height: 6)

                    Capsule()
                        .fill(Color.appAccent)
                        .frame(width: geo.size.width * progress, height: 6)
                        .animation(.appSpring, value: progress)
                }
            }
            .frame(height: 6)

            Text("\(currentIndex + 1)/\(pgsiQuestions.count)")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.appTextMuted)
        }
    }

    private var questionCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            QuestionIllustration(imageName: pgsiQuestions[currentIndex].imageName)

            Text(pgsiQuestions[currentIndex].text)
                .font(.appTitle)
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                ForEach(pgsiAnswerOptions, id: \.label) { option in
                    answerButton(option: option)
                }
            }
        }
    }

    private func answerButton(option: (label: String, score: Int)) -> some View {
        let isSelected = answers[currentIndex] == option.score

        return Button {
            selectAnswer(score: option.score)
        } label: {
            HStack {
                Text(option.label)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(isSelected ? Color.appBackground : Color.appTextPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.appBackground)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.appAccent : Color.appSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appBorder, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func selectAnswer(score: Int) {
        withAnimation(.appSpringSnappy) {
            answers[currentIndex] = score
        }

        Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            if currentIndex < pgsiQuestions.count - 1 {
                withAnimation(.appSpring) {
                    currentIndex += 1
                }
            } else {
                goToResults = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        PGSIQuestionnaireView()
    }
}
