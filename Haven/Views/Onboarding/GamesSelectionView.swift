import SwiftUI

struct GamesSelectionView: View {
    @State private var isVisible = false
    @State private var casinoSelected = false
    @State private var sportsSelected = false
    @State private var haloPulse = false
    @State private var goToDetails = false

    private var hasSelection: Bool {
        casinoSelected || sportsSelected
    }

    private var selectedGames: [GameType] {
        var games: [GameType] = []
        if casinoSelected { games.append(.casino) }
        if sportsSelected { games.append(.sportsBetting) }
        return games
    }

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 60)

                headerBlock
                    .padding(.horizontal, 28)

                Spacer(minLength: 40)

                VStack(spacing: 14) {
                    selectionCard(
                        title: "Casino",
                        subtitle: "Machines à sous, roulette, poker en ligne...",
                        iconSymbol: "die.face.5.fill",
                        isSelected: $casinoSelected
                    )

                    selectionCard(
                        title: "Paris sportifs",
                        subtitle: "Football, tennis, cotes boostées...",
                        iconSymbol: "sportscourt.fill",
                        isSelected: $sportsSelected
                    )
                }
                .padding(.horizontal, 28)

                Spacer()

                Button("Continuer") {
                    goToDetails = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
                .opacity(hasSelection ? 1 : 0.4)
                .disabled(!hasSelection)
            }
        }
        .navigationDestination(isPresented: $goToDetails) {
            PracticeDetailsView(selectedGames: selectedGames)
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.appSpring.delay(0.1)) {
                isVisible = true
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                haloPulse = true
            }
        }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quels jeux pratiques-tu ?")
                .font(.appTitle)
                .foregroundStyle(Color.appTextPrimary)

            Text("Sélectionne une ou plusieurs réponses, on adapte le reste en fonction.")
                .font(.appBody)
                .foregroundStyle(Color.appTextSecondary)
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 12)
    }

    private func selectionCard(title: String, subtitle: String, iconSymbol: String, isSelected: Binding<Bool>) -> some View {
        Button {
            withAnimation(.appSpringSnappy) {
                isSelected.wrappedValue.toggle()
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isSelected.wrappedValue ? Color.appAccent : Color.appSurfaceElevated)
                        .frame(width: 48, height: 48)

                    Image(systemName: iconSymbol)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(isSelected.wrappedValue ? Color.appBackground : Color.appTextSecondary)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.appHeadline)
                        .foregroundStyle(Color.appTextPrimary)

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appTextMuted)
                }

                Spacer()

                Image(systemName: isSelected.wrappedValue ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected.wrappedValue ? Color.appAccent : Color.appTextMuted)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.appSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected.wrappedValue ? Color.appAccent : Color.appBorder, lineWidth: isSelected.wrappedValue ? 2 : 1)
            )
            .shadow(color: isSelected.wrappedValue ? Color.appAccent.opacity(0.35) : .clear, radius: 16)
        }
        .buttonStyle(.plain)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 16)
    }

    private var backgroundLayer: some View {
        ZStack {
            Color.appBackground

            Circle()
                .fill(Color.appAccent.opacity(haloPulse ? 0.3 : 0.18))
                .frame(width: 260, height: 260)
                .blur(radius: 110)
                .offset(x: -120, y: -260)

            Circle()
                .fill(Color.appGold.opacity(haloPulse ? 0.2 : 0.1))
                .frame(width: 220, height: 220)
                .blur(radius: 100)
                .offset(x: 140, y: 300)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        GamesSelectionView()
    }
}
