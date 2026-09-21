import SwiftUI

struct AvatarCreatorView: View {
    @ObservedObject private var store = AvatarStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: Category

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

    init() {
        let current = AvatarStore.shared.config.characterIndex
        if let current, AvatarConfig.menIndices.contains(current) {
            _selectedCategory = State(initialValue: .homme)
        } else {
            _selectedCategory = State(initialValue: .femme)
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 28) {
                AvatarView(config: store.config, vitalityScore: store.vitalityScore)
                    .padding(.top, 20)

                Text("Choisis ton personnage")
                    .font(.appHeadline)
                    .foregroundStyle(Color.appTextPrimary)

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

                Spacer()

                Button("Valider") {
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 28)
                .padding(.bottom, 24)
                .disabled(store.config.characterIndex == nil)
                .opacity(store.config.characterIndex == nil ? 0.5 : 1)
            }
        }
        .navigationTitle("Ton avatar")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    private func characterThumbnail(_ index: Int) -> some View {
        let isSelected = store.config.characterIndex == index

        return Button {
            store.config.characterIndex = index
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
        AvatarCreatorView()
    }
}
