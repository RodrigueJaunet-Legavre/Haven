import SwiftUI
import WebKit

struct EmbeddedVideoView: UIViewRepresentable {
    let youtubeID: String
    var startSeconds: Int? = nil

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false

        let startParameter = startSeconds.map { "&start=\($0)" } ?? ""

        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
        html, body { margin: 0; padding: 0; background: #000; height: 100%; }
        iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: 0; }
        </style>
        </head>
        <body>
        <iframe src="https://www.youtube.com/embed/\(youtubeID)?playsinline=1&rel=0\(startParameter)"
                allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                allowfullscreen></iframe>
        </body>
        </html>
        """

        let bundleID = Bundle.main.bundleIdentifier ?? "haven.virogue"
        webView.loadHTMLString(html, baseURL: URL(string: "https://\(bundleID)"))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
