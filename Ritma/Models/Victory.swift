import Foundation

struct Victory: Codable, Identifiable {
    let id: UUID
    let user_id: UUID
    let date: Date
    let note: String?
}
