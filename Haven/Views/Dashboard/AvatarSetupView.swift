import SwiftUI

struct AvatarSetupView: View {
    @ObservedObject private var store = AvatarStore.shared
    @State private var selectedCategory: Category = .femme
    @State private var selectedIndex: Int?

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    enum Category: String, CaseIterable {
        case femme = "Femme"
        case homme = "Homme"

        var indices: [Int] {
            switch self {
            case .femme: return AvatarConfig.womenIndices
            case .homme: return AvatarConfig.menIndices
            }
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Choisis ton personnage")
                                .font(.appTitle)
                                .foregroundStyle(Color.appTextPrimary)

                            Text("Il t'accompagne tout au long du parcours et évolue avec ta progression.")
                                .font(.appBody)
                                .foregroundStyle(Color.appTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 24)

                        AvatarView(
                            config: AvatarConfig(characterIndex: selectedIndex),
                            vitalityScore: 70
                        )
                        .scaleEffect(0.85)
                        .frame(height: 190)

                        Picker("Catégorie", selection: $selectedCategory) {
                            ForEach(Category.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 24)

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(selectedCategory.indices, id: \.self) { index in
                                characterThumbnail(index)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                    }
                }

                Button("Continuer") {
                    guard let selectedIndex else { return }
                    store.config.characterIndex = selectedIndex
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 28)
                .padding(.top, 12)
                .padding(.bottom, 32)
                .disabled(selectedIndex == nil)
                .opacity(selectedIndex == nil ? 0.5 : 1)
            }
        }
        .navigationBarHidden(true)
    }

    private func characterThumbnail(_ index: Int) -> some View {
        let isSelected = selectedIndex == index

        return Button {
            selectedIndex = index
        } label: {
            Image("avatar\(index)_tier3")
                .resizable()
                .scaledToFill()
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isSelected ? Color.appAccent : Color.appBorder, lineWidth: isSelected ? 3 : 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AvatarSetupView()
    }
}
