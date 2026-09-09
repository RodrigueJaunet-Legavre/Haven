import SwiftUI

struct AvatarCreatorView: View {
    @ObservedObject private var store = AvatarStore.shared

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 32) {
                AvatarView(config: store.config, vitalityScore: store.vitalityScore)
                    .padding(.top, 20)

                VStack(alignment: .leading, spacing: 24) {
                    optionSection(title: "Carnation") {
                        HStack(spacing: 12) {
                            ForEach(AvatarConfig.skinTones.indices, id: \.self) { index in
                                swatch(
                                    color: Color(hex: AvatarConfig.skinTones[index]),
                                    isSelected: store.config.skinToneIndex == index
                                ) {
                                    store.config.skinToneIndex = index
                                }
                            }
                        }
                    }

                    optionSection(title: "Coiffure") {
                        HStack(spacing: 12) {
                            ForEach(AvatarConfig.hairStyles.indices, id: \.self) { index in
                                styleButton(
                                    label: AvatarConfig.hairStyles[index],
                                    isSelected: store.config.hairStyleIndex == index
                                ) {
                                    store.config.hairStyleIndex = index
                                }
                            }
                        }
                    }

                    optionSection(title: "Couleur de cheveux") {
                        HStack(spacing: 12) {
                            ForEach(AvatarConfig.hairColors.indices, id: \.self) { index in
                                swatch(
                                    color: Color(hex: AvatarConfig.hairColors[index]),
                                    isSelected: store.config.hairColorIndex == index
                                ) {
                                    store.config.hairColorIndex = index
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 28)

                Spacer()
            }
        }
        .navigationTitle("Ton avatar")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func optionSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.appTextSecondary)
            content()
        }
    }

    private func swatch(color: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle().stroke(isSelected ? Color.appAccent : .clear, lineWidth: 3)
                )
        }
        .buttonStyle(.plain)
    }

    private func styleButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(isSelected ? Color.appBackground : Color.appTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(isSelected ? Color.appAccent : Color.appSurfaceElevated)
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
