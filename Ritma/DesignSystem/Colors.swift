import SwiftUI

extension Color {
    static let appBackground = Color(hex: "0B1220")
    static let appSurface = Color(hex: "141E2E")
    static let appSurfaceElevated = Color(hex: "1D2B3F")

    static let appTextPrimary = Color(hex: "F3F6FA")
    static let appTextSecondary = Color(hex: "9FB0C3")
    static let appTextMuted = Color(hex: "5E6E82")

    static let appAccent = Color(hex: "2FB8C6")
    static let appAccentMuted = Color(hex: "12363B")

    static let appGold = Color(hex: "E8B94D")

    static let appWarning = Color(hex: "E8A33D")
    static let appDanger = Color(hex: "E8483D")
    static let appSuccess = Color(hex: "4ADE94")

    static let appBorder = Color.white.opacity(0.1)
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue >> 16) & 0xFF) / 255
        let g = Double((rgbValue >> 8) & 0xFF) / 255
        let b = Double(rgbValue & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}
