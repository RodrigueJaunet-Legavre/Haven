import UIKit

enum PDFReportGenerator {
    static func generate() async -> Data {
        await BetsService.shared.fetchEntries()
        await VictoryService.shared.fetchEntries()

        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 40
        let contentWidth = pageWidth - margin * 2

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        return renderer.pdfData { context in
            context.beginPage()
            var y: CGFloat = margin

            func draw(_ text: String, font: UIFont, color: UIColor = .black, spacingAfter: CGFloat = 8) {
                let attributed = NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
                let boundingRect = attributed.boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: .usesLineFragmentOrigin,
                    context: nil
                )
                if y + boundingRect.height > pageHeight - margin {
                    context.beginPage()
                    y = margin
                }
                attributed.draw(with: CGRect(x: margin, y: y, width: contentWidth, height: boundingRect.height), options: .usesLineFragmentOrigin, context: nil)
                y += boundingRect.height + spacingAfter
            }

            func drawDivider() {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: margin, y: y))
                path.addLine(to: CGPoint(x: pageWidth - margin, y: y))
                UIColor.lightGray.setStroke()
                path.lineWidth = 0.5
                path.stroke()
                y += 16
            }

            let titleFont = UIFont.boldSystemFont(ofSize: 22)
            let sectionFont = UIFont.boldSystemFont(ofSize: 15)
            let bodyFont = UIFont.systemFont(ofSize: 12)
            let mutedFont = UIFont.systemFont(ofSize: 10)

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.locale = Locale(identifier: "fr_FR")

            draw("Haven — Rapport personnel", font: titleFont)
            draw("Généré le \(dateFormatter.string(from: Date()))", font: mutedFont, color: .gray, spacingAfter: 20)

            draw("Résultat du test initial", font: sectionFont)
            if let pgsiScore = UserScope.defaults.object(forKey: "pgsiInitialScore") as? Int,
               let category = UserScope.defaults.string(forKey: "pgsiInitialCategory") {
                draw("Score : \(pgsiScore)/30 — \(category)", font: bodyFont)
                if let testDate = UserScope.defaults.object(forKey: "pgsiTestDate") as? Date {
                    draw("Test réalisé le \(dateFormatter.string(from: testDate))", font: mutedFont, color: .gray)
                }
            } else {
                draw("Non disponible", font: bodyFont, color: .gray)
            }
            drawDivider()

            draw("État actuel", font: sectionFont)
            draw("Score de vitalité : \(Int(AvatarStore.shared.vitalityScore))/100", font: bodyFont)
            draw("Jours sans jouer : \(StreakStore.shared.streakDays)", font: bodyFont)
            drawDivider()

            draw("Badges obtenus", font: sectionFont)
            let unlockedBadges = allBadges.filter { BadgeStore.shared.isUnlocked($0) }
            if unlockedBadges.isEmpty {
                draw("Aucun badge débloqué pour l'instant", font: bodyFont, color: .gray)
            } else {
                for badge in unlockedBadges {
                    draw("• \(badge.title) (\(badge.thresholdDays) jours)", font: bodyFont)
                }
            }
            drawDivider()

            draw("Résumé du Journal", font: sectionFont)
            let entries = BetsService.shared.entries
            let relapses = entries.filter { $0.type_jeu == "Rechute" }
            let realBets = entries.filter { $0.type_jeu != "Rechute" }
            let totalWagered = realBets.reduce(0) { $0 + $1.montant }
            draw("Mises enregistrées : \(realBets.count)", font: bodyFont)
            draw("Total misé enregistré : \(Int(totalWagered)) €", font: bodyFont)
            draw("Rechutes signalées : \(relapses.count)", font: bodyFont)
            draw("Victoires enregistrées : \(VictoryService.shared.entries.count)", font: bodyFont)
            drawDivider()

            draw("Historique récent", font: sectionFont)
            let recentEntries = entries.prefix(20)
            if recentEntries.isEmpty {
                draw("Aucune entrée pour l'instant", font: bodyFont, color: .gray)
            } else {
                let entryDateFormatter = DateFormatter()
                entryDateFormatter.dateStyle = .short
                entryDateFormatter.locale = Locale(identifier: "fr_FR")
                for entry in recentEntries {
                    draw("\(entryDateFormatter.string(from: entry.date)) — \(entry.type_jeu) — \(Int(entry.montant)) €", font: bodyFont)
                }
            }
        }
    }
}
