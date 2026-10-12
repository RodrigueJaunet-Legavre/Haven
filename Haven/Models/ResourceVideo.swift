import Foundation

struct ResourceVideo: Identifiable {
    let id = UUID()
    let title: String
    let speakerRole: String
    let duration: String
    let description: String
    var youtubeID: String? = nil
    var startSeconds: Int? = nil
    var source: String? = nil

    var youtubeWatchURL: URL? {
        guard let youtubeID else { return nil }
        let timeParameter = startSeconds.map { "&t=\($0)s" } ?? ""
        return URL(string: "https://www.youtube.com/watch?v=\(youtubeID)\(timeParameter)")
    }

    var thumbnailURL: URL? {
        guard let youtubeID else { return nil }
        return URL(string: "https://img.youtube.com/vi/\(youtubeID)/mqdefault.jpg")
    }
}

let resourceVideos: [ResourceVideo] = [
    ResourceVideo(
        title: "Peut-on désactiver les addictions ?",
        speakerRole: "ARTE",
        duration: "27:37",
        description: "Un éclairage sur les mécanismes de l'addiction.",
        youtubeID: "Sexea1QaTXo",
        startSeconds: 1130,
        source: "ARTE"
    ),
    ResourceVideo(
        title: "Pour quelles raisons devient-on dépendant aux jeux d'argent ?",
        speakerRole: "Lucia Romo, psychologue clinicienne",
        duration: "4:00",
        description: "Une psychologue clinicienne explique les raisons variées de l'addiction aux jeux de hasard et d'argent, entre facteurs liés aux jeux et à l'environnement.",
        youtubeID: "dxrLCY1A1u8",
        source: "Santé publique France"
    ),
    ResourceVideo(
        title: "\"Je suis addict aux jeux d'argent\" : comment cette addiction gâche des vies",
        speakerRole: "Konbini",
        duration: "4:35",
        description: "Un reportage sur la façon dont l'addiction aux jeux d'argent abîme des vies.",
        youtubeID: "G9NY-m3ZX9g",
        source: "Konbini"
    )
]

let emergencyVideo: ResourceVideo? = resourceVideos.first { $0.youtubeID == "dxrLCY1A1u8" }
