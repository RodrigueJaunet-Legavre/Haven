import Foundation

struct AvatarConfig: Codable, Equatable {
    var skinToneIndex: Int
    var hairStyleIndex: Int
    var hairColorIndex: Int

    static let skinTones: [String] = ["F5D0B0", "E8B48C", "C68863", "8D5A3B", "5C3A21"]
    static let hairColors: [String] = ["2B1B12", "6B4226", "B8860B", "1C1C1C", "D8C4A0"]
    static let hairStyles: [String] = ["short", "long", "curly", "bald"]

    static let `default` = AvatarConfig(skinToneIndex: 0, hairStyleIndex: 0, hairColorIndex: 0)
}
