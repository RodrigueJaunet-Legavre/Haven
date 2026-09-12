import Foundation

struct AvatarConfig: Codable, Equatable {
    var characterIndex: Int?

    static let menIndices = [1, 2, 3, 4, 5, 6]
    static let womenIndices = [7, 8, 9, 10, 11, 12]

    static let `default` = AvatarConfig(characterIndex: nil)
}
