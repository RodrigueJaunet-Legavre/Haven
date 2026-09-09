import SwiftUI

struct AvatarView: View {
    let config: AvatarConfig
    let vitalityScore: Double

    private var t: CGFloat {
        CGFloat(max(0, min(100, vitalityScore))) / 100
    }

    private var skinColor: Color {
        Color(hex: AvatarConfig.skinTones[config.skinToneIndex])
    }

    private var skinShadow: Color {
        skinColor.opacity(0.8)
    }

    private var desaturatedSkin: Color {
        skinColor.blend(with: Color.appTextMuted, amount: (1 - t) * 0.35)
    }

    private var hairColor: Color {
        Color(hex: AvatarConfig.hairColors[config.hairColorIndex])
    }

    private var bodyWidth: CGFloat {
        76 + t * 34
    }

    private var underEyeOpacity: Double {
        Double(1 - t) * 0.55
    }

    private var eyebrowLift: CGFloat {
        (t - 0.5) * 4
    }

    var body: some View {
        ZStack {
            shadowEllipse
            neck
            body_
            head
            hair
            face
            if t < 0.35 {
                stressMarks
            }
        }
        .frame(width: 170, height: 220)
    }

    private var shadowEllipse: some View {
        Ellipse()
            .fill(Color.black.opacity(0.25))
            .frame(width: 90, height: 14)
            .blur(radius: 4)
            .offset(y: 104)
    }

    private var neck: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(desaturatedSkin)
            .frame(width: 22, height: 20)
            .offset(y: 28)
    }

    private var body_: some View {
        RoundedRectangle(cornerRadius: bodyWidth * 0.42)
            .fill(
                LinearGradient(
                    colors: [Color.appSurfaceElevated, Color.appSurfaceElevated.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: bodyWidth, height: 92)
            .overlay(
                RoundedRectangle(cornerRadius: bodyWidth * 0.42)
                    .stroke(Color.black.opacity(0.15), lineWidth: 1)
            )
            .offset(y: 68)
    }

    private var head: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [desaturatedSkin, skinShadow],
                    center: .init(x: 0.35, y: 0.3),
                    startRadius: 4,
                    endRadius: 50
                )
            )
            .frame(width: 84, height: 84)
            .offset(y: -6)
    }

    private var hair: some View {
        Group {
            switch AvatarConfig.hairStyles[config.hairStyleIndex] {
            case "short":
                Path { path in
                    path.addArc(center: CGPoint(x: 42, y: 42), radius: 47, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
                    path.addLine(to: CGPoint(x: 89, y: 42))
                    path.addQuadCurve(to: CGPoint(x: -5, y: 42), control: CGPoint(x: 42, y: 8))
                }
                .fill(hairColor)
                .frame(width: 90, height: 50)
                .offset(y: -34)
            case "long":
                RoundedRectangle(cornerRadius: 44)
                    .fill(hairColor)
                    .frame(width: 100, height: 78)
                    .offset(y: -36)
                Circle()
                    .fill(desaturatedSkin)
                    .frame(width: 84, height: 84)
                    .offset(y: -6)
                    .mask(Rectangle().offset(y: 30))
            case "curly":
                ZStack {
                    ForEach(0..<8, id: \.self) { i in
                        Circle()
                            .fill(hairColor)
                            .frame(width: 28, height: 28)
                            .offset(
                                x: CGFloat(cos(Double(i) * .pi / 4)) * 34,
                                y: CGFloat(sin(Double(i) * .pi / 4)) * 26 - 40
                            )
                    }
                }
            default:
                EmptyView()
            }
        }
    }

    private var face: some View {
        VStack(spacing: 5) {
            HStack(spacing: 24) {
                eyebrow
                eyebrow
            }
            .offset(y: -4)

            HStack(spacing: 22) {
                eye
                eye
            }

            mouth
        }
        .offset(y: -14)
    }

    private var eyebrow: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(hairColor.opacity(0.85))
            .frame(width: 14, height: 2.5)
            .rotationEffect(.degrees(Double(-eyebrowLift)))
    }

    private var eye: some View {
        ZStack {
            Ellipse()
                .fill(Color.black.opacity(0.8))
                .frame(width: 6, height: 7)

            Ellipse()
                .fill(Color.black.opacity(underEyeOpacity))
                .frame(width: 15, height: 6)
                .offset(y: 9)
        }
    }

    private var mouth: some View {
        let curve = (t - 0.5) * 14
        return Path { path in
            path.move(to: CGPoint(x: -10, y: 0))
            path.addQuadCurve(to: CGPoint(x: 10, y: 0), control: CGPoint(x: 0, y: curve))
        }
        .stroke(Color.black.opacity(0.65), lineWidth: 2.2)
        .frame(width: 20, height: 12)
        .offset(y: 8)
    }

    private var stressMarks: some View {
        ForEach(0..<3, id: \.self) { i in
            Image(systemName: "bolt.fill")
                .font(.system(size: 10))
                .foregroundStyle(Color.appDanger.opacity(0.8))
                .offset(x: CGFloat(i - 1) * 26, y: -76)
        }
    }
}

extension Color {
    func blend(with other: Color, amount: Double) -> Color {
        let ui1 = UIColor(self)
        let ui2 = UIColor(other)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        ui1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        ui2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let t = CGFloat(amount)
        return Color(
            red: r1 + (r2 - r1) * t,
            green: g1 + (g2 - g1) * t,
            blue: b1 + (b2 - b1) * t
        )
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        HStack(spacing: 20) {
            AvatarView(config: .default, vitalityScore: 90)
            AvatarView(config: .default, vitalityScore: 40)
            AvatarView(config: .default, vitalityScore: 10)
        }
    }
}
