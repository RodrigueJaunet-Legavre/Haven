import SwiftUI

extension Animation {
    static let appSpring = Animation.spring(response: 0.45, dampingFraction: 0.75)
    static let appSpringBouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let appSpringSnappy = Animation.spring(response: 0.3, dampingFraction: 0.85)
    static let appEase = Animation.easeInOut(duration: 0.25)
}
