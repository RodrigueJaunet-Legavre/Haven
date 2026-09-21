import Foundation

struct Badge: Identifiable {
    let id: String
    let title: String
    let thresholdDays: Int
    let icon: String
}

let allBadges: [Badge] = [
    Badge(id: "day1", title: "Premier jour", thresholdDays: 1, icon: "sunrise.fill"),
    Badge(id: "day3", title: "3 jours", thresholdDays: 3, icon: "leaf.fill"),
    Badge(id: "day7", title: "1 semaine", thresholdDays: 7, icon: "star.fill"),
    Badge(id: "day14", title: "2 semaines", thresholdDays: 14, icon: "star.circle.fill"),
    Badge(id: "day30", title: "1 mois", thresholdDays: 30, icon: "moon.stars.fill"),
    Badge(id: "day60", title: "2 mois", thresholdDays: 60, icon: "flame.fill"),
    Badge(id: "day90", title: "3 mois", thresholdDays: 90, icon: "crown.fill"),
    Badge(id: "day180", title: "6 mois", thresholdDays: 180, icon: "medal.fill"),
    Badge(id: "day365", title: "1 an", thresholdDays: 365, icon: "trophy.fill")
]
