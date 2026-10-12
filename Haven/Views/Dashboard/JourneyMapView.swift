import SwiftUI

struct JourneyGeometry {
    static let spacing: CGFloat = 118
    static let topPadding: CGFloat = 130
    static let bottomPadding: CGFloat = 150
    static let nodeCount = 30

    let width: CGFloat

    static var totalHeight: CGFloat {
        topPadding + CGFloat(nodeCount + 1) * spacing + bottomPadding
    }

    func xFraction(_ node: Int) -> CGFloat {
        0.5 + 0.29 * CGFloat(sin(Double(node) * 0.95))
    }

    func center(_ node: Int) -> CGPoint {
        let x = width * xFraction(node)
        let y = Self.topPadding + CGFloat(Self.nodeCount - node) * Self.spacing + Self.spacing / 2
        return CGPoint(x: x, y: y)
    }

    func pointOnSegment(_ index: Int, t: CGFloat) -> CGPoint {
        let p0 = center(index)
        let p1 = center(index + 1)
        let midY = (p0.y + p1.y) / 2
        let c1 = CGPoint(x: p0.x, y: midY)
        let c2 = CGPoint(x: p1.x, y: midY)
        let u = 1 - t
        let a = u * u * u
        let b = 3 * u * u * t
        let c = 3 * u * t * t
        let d = t * t * t
        let x = a * p0.x + b * c1.x + c * c2.x + d * p1.x
        let y = a * p0.y + b * c1.y + c * c2.y + d * p1.y
        return CGPoint(x: x, y: y)
    }

    func point(at progress: Double) -> CGPoint {
        let clamped = min(max(progress, 0), Double(Self.nodeCount))
        let index = min(Int(floor(clamped)), Self.nodeCount - 1)
        let t = CGFloat(clamped - Double(index))
        return pointOnSegment(index, t: t)
    }

    func segmentLength(_ index: Int) -> CGFloat {
        var length: CGFloat = 0
        var previous = pointOnSegment(index, t: 0)
        for step in 1...12 {
            let next = pointOnSegment(index, t: CGFloat(step) / 12)
            length += hypot(next.x - previous.x, next.y - previous.y)
            previous = next
        }
        return length
    }

    func trimFraction(at progress: Double) -> CGFloat {
        let clamped = min(max(progress, 0), Double(Self.nodeCount))
        let lengths = (0..<Self.nodeCount).map { segmentLength($0) }
        let total = lengths.reduce(0, +)
        guard total > 0 else { return 0 }
        let index = min(Int(floor(clamped)), Self.nodeCount - 1)
        let partial = CGFloat(clamped - Double(index))
        let done = lengths.prefix(index).reduce(0, +) + lengths[index] * partial
        return min(1, done / total)
    }
}

struct JourneyTrailShape: Shape {
    func path(in rect: CGRect) -> Path {
        let geometry = JourneyGeometry(width: rect.width)
        var path = Path()
        path.move(to: geometry.center(0))
        for node in 1...JourneyGeometry.nodeCount {
            let p0 = geometry.center(node - 1)
            let p1 = geometry.center(node)
            let midY = (p0.y + p1.y) / 2
            path.addCurve(
                to: p1,
                control1: CGPoint(x: p0.x, y: midY),
                control2: CGPoint(x: p1.x, y: midY)
            )
        }
        return path
    }
}

struct JourneyProgressTrail: View, Animatable {
    var progress: Double
    let width: CGFloat

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        let fraction = JourneyGeometry(width: width).trimFraction(at: progress)
        JourneyTrailShape()
            .trim(from: 0, to: fraction)
            .stroke(
                LinearGradient(colors: [Color.appSuccess, Color.appAccent], startPoint: .bottom, endPoint: .top),
                style: StrokeStyle(lineWidth: 7, lineCap: .round)
            )
    }
}

struct JourneyAvatarWalker: View, Animatable {
    var progress: Double
    let width: CGFloat
    let avatar: AvatarView

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        let geometry = JourneyGeometry(width: width)
        let point = geometry.point(at: progress)
        let fraction = progress - floor(progress)
        let lift = CGFloat(-sin(fraction * .pi) * 34)

        ZStack {
            Ellipse()
                .fill(Color.black.opacity(0.35))
                .frame(width: 34 - abs(lift) * 0.3, height: 9)
                .blur(radius: 2)
                .position(x: point.x, y: point.y + 6)

            avatar
                .scaleEffect(0.34)
                .frame(width: 58, height: 75)
                .position(x: point.x, y: point.y - 44 + lift)
        }
    }
}

struct JourneySparkleBurst: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.appGold, lineWidth: 4)
                .frame(width: 60, height: 60)
                .scaleEffect(animate ? 2.4 : 0.4)
                .opacity(animate ? 0 : 1)

            ForEach(0..<8, id: \.self) { index in
                let angle = Double(index) / 8 * 2 * Double.pi
                Image(systemName: "sparkle")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appGold)
                    .scaleEffect(animate ? 1.2 : 0.3)
                    .opacity(animate ? 0 : 1)
                    .offset(
                        x: animate ? CGFloat(cos(angle)) * 74 : 0,
                        y: animate ? CGFloat(sin(angle)) * 74 : 0
                    )
            }
        }
        .frame(width: 60, height: 60)
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) {
                animate = true
            }
        }
    }
}

struct JourneyNodeView: View {
    enum Status {
        case start, completed, actionable, waiting, locked
    }

    let status: Status
    let day: JourneyDay?
    let isFinal: Bool

    @State private var pulse = false

    private var isMilestone: Bool { day?.isMilestone ?? false }

    private var size: CGFloat {
        if status == .start { return 46 }
        return isMilestone ? 72 : 58
    }

    private var ringColor: Color {
        status == .actionable ? Color.appGold : Color.appGold.opacity(0.6)
    }

    var body: some View {
        ZStack {
            if status == .actionable || status == .waiting {
                Circle()
                    .stroke(ringColor, lineWidth: 3)
                    .frame(width: size + 18, height: size + 18)
                    .scaleEffect(pulse ? 1.15 : 0.95)
                    .opacity(pulse ? 0.15 : 0.8)
            }

            circle

            centerIcon

            if isMilestone {
                Image(systemName: "star.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appGold)
                    .offset(x: size / 2 - 4, y: -size / 2 + 4)
            }
        }
        .frame(width: size + 30, height: size + 30)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    @ViewBuilder
    private var circle: some View {
        switch status {
        case .completed:
            Circle()
                .fill(LinearGradient(colors: [Color.appSuccess, Color.appAccent], startPoint: .top, endPoint: .bottom))
                .frame(width: size, height: size)
                .shadow(color: Color.appSuccess.opacity(0.4), radius: 8)
        case .actionable:
            Circle()
                .fill(LinearGradient(colors: [Color.appGold, Color.appWarning], startPoint: .top, endPoint: .bottom))
                .frame(width: size, height: size)
                .shadow(color: Color.appGold.opacity(0.55), radius: 14)
        case .waiting:
            Circle()
                .fill(Color.appSurfaceElevated)
                .frame(width: size, height: size)
                .overlay(
                    Circle().stroke(Color.appGold.opacity(0.6), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                )
        case .start:
            Circle()
                .fill(Color.appAccent.opacity(0.25))
                .frame(width: size, height: size)
                .overlay(Circle().stroke(Color.appAccent, lineWidth: 2))
        case .locked:
            Circle()
                .fill(Color.appSurface)
                .frame(width: size, height: size)
                .overlay(Circle().stroke(Color.appBorder, lineWidth: 2))
        }
    }

    @ViewBuilder
    private var centerIcon: some View {
        switch status {
        case .completed:
            Image(systemName: "checkmark")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
        case .actionable:
            Image(systemName: day?.icon ?? "star.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.appBackground)
        case .waiting:
            Image(systemName: "lock.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color.appGold)
        case .start:
            Image(systemName: "flag.fill")
                .font(.system(size: 18))
                .foregroundStyle(Color.appAccent)
        case .locked:
            if isFinal {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.appTextMuted)
            } else {
                Text("?")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.appTextMuted)
            }
        }
    }
}

struct JourneyMapView: View {
    @ObservedObject private var store = JourneyStore.shared
    @ObservedObject private var avatarStore = AvatarStore.shared

    let onSelect: (Int) -> Void

    @State private var displayedProgress: Double = -1
    @State private var burstNode: Int?
    @State private var burstID = UUID()
    @State private var bob = false
    @State private var isVisible = false

    private struct SequenceKey: Equatable {
        let target: Int
        let visible: Bool
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let geometry = JourneyGeometry(width: width)

            ScrollViewReader { scroll in
                ScrollView(showsIndicators: false) {
                    ZStack(alignment: .topLeading) {
                        LinearGradient(
                            colors: [Color.appGold.opacity(0.10), Color.appBackground, Color.appAccent.opacity(0.06)],
                            startPoint: .top,
                            endPoint: .bottom
                        )

                        JourneyTrailShape()
                            .stroke(Color.appBorder, style: StrokeStyle(lineWidth: 6, lineCap: .round, dash: [1, 14]))
                            .allowsHitTesting(false)

                        JourneyProgressTrail(progress: max(displayedProgress, 0), width: width)
                            .allowsHitTesting(false)

                        rowsView(geometry: geometry, width: width)

                        ForEach([1, 8, 15, 22], id: \.self) { first in
                            banner(first, geometry: geometry)
                        }

                        if let node = burstNode {
                            JourneySparkleBurst()
                                .id(burstID)
                                .position(geometry.center(node))
                                .allowsHitTesting(false)
                        }

                        if displayedProgress >= 0 {
                            JourneyAvatarWalker(
                                progress: displayedProgress,
                                width: width,
                                avatar: AvatarView(config: avatarStore.config, vitalityScore: avatarStore.vitalityScore)
                            )
                            .offset(y: bob ? -3 : 0)
                            .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: bob)
                            .allowsHitTesting(false)
                        }
                    }
                    .frame(width: width, height: JourneyGeometry.totalHeight)
                }
                .onAppear {
                    isVisible = true
                    bob = true
                }
                .onDisappear {
                    isVisible = false
                }
                .task(id: SequenceKey(target: store.avatarTargetNode, visible: isVisible)) {
                    await runSequence(scroll: scroll)
                }
            }
        }
    }

    private func rowsView(geometry: JourneyGeometry, width: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach((0...JourneyGeometry.nodeCount).reversed(), id: \.self) { node in
                nodeRow(node, geometry: geometry, width: width)
            }
        }
        .padding(.top, JourneyGeometry.topPadding)
        .padding(.bottom, JourneyGeometry.bottomPadding)
        .frame(width: width)
    }

    private func nodeStatus(_ node: Int) -> JourneyNodeView.Status {
        if node == 0 { return .start }
        guard store.hasStarted else { return .locked }
        if node <= store.completedCount { return .completed }
        if node == store.completedCount + 1 {
            return store.isUnlocked(journeyDays[node - 1]) ? .actionable : .waiting
        }
        return .locked
    }

    private func nodeRow(_ node: Int, geometry: JourneyGeometry, width: CGFloat) -> some View {
        let center = geometry.center(node)
        let status = nodeStatus(node)
        let day: JourneyDay? = node == 0 ? nil : journeyDays[node - 1]
        let tappable = status == .completed || status == .actionable
        let side: CGFloat = center.x < width / 2 ? 1 : -1
        let labelX = center.x + side * ((day?.isMilestone ?? false) ? 112 : 104)

        return ZStack {
            Button {
                onSelect(node)
            } label: {
                JourneyNodeView(status: status, day: day, isFinal: node == JourneyGeometry.nodeCount)
            }
            .buttonStyle(.plain)
            .disabled(!tappable)
            .position(x: center.x, y: JourneyGeometry.spacing / 2)

            if status != .locked {
                labelView(node: node, status: status, alignsLeading: side > 0)
                    .frame(width: 116, alignment: side > 0 ? .leading : .trailing)
                    .position(x: labelX, y: JourneyGeometry.spacing / 2)
                    .allowsHitTesting(false)
            }
        }
        .frame(width: width, height: JourneyGeometry.spacing)
        .id("row-\(node)")
    }

    @ViewBuilder
    private func labelView(node: Int, status: JourneyNodeView.Status, alignsLeading: Bool) -> some View {
        let alignment: TextAlignment = alignsLeading ? .leading : .trailing

        switch status {
        case .start:
            Text("Départ")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appTextMuted)
                .multilineTextAlignment(alignment)
        case .completed:
            Text(journeyDays[node - 1].title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(alignment)
        case .actionable:
            VStack(alignment: alignsLeading ? .leading : .trailing, spacing: 3) {
                Text(journeyDays[node - 1].title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(alignment)

                Text("Touche pour commencer")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.appGold)
            }
        case .waiting:
            Text(waitingText)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appGold)
                .multilineTextAlignment(alignment)
        case .locked:
            EmptyView()
        }
    }

    private var waitingText: String {
        guard let day = store.currentDay, let date = store.unlockDate(for: day) else { return "Bientôt" }
        if Calendar.current.isDateInTomorrow(date) { return "Disponible demain" }
        let text = date.formatted(.dateTime.weekday(.wide).day().month(.abbreviated).locale(Locale(identifier: "fr_FR")))
        return "Disponible " + text
    }

    private func banner(_ first: Int, geometry: JourneyGeometry) -> some View {
        let week = journeyWeekNumber(for: first)
        let revealed = store.hasStarted
            && first <= store.completedCount + 1
            && (first <= store.completedCount || store.isUnlocked(journeyDays[first - 1]))
        let y = (geometry.center(first - 1).y + geometry.center(first).y) / 2
        let text = revealed ? "SEMAINE \(week) · \(journeyWeekTitle(week).uppercased())" : "SEMAINE \(week) · ???"

        return Text(text)
            .font(.system(size: 10, weight: .bold))
            .tracking(0.8)
            .foregroundStyle(revealed ? Color.appGold : Color.appTextMuted)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.appSurface))
            .overlay(Capsule().stroke(revealed ? Color.appGold.opacity(0.5) : Color.appBorder, lineWidth: 1))
            .position(x: geometry.width / 2, y: y)
            .allowsHitTesting(false)
    }

    private func runSequence(scroll: ScrollViewProxy) async {
        guard isVisible else { return }

        while avatarStore.pendingGain != nil {
            try? await Task.sleep(nanoseconds: 200_000_000)
            if Task.isCancelled { return }
        }

        let target = store.avatarTargetNode

        if displayedProgress < 0 {
            let start = min(store.lastSeenNode, target)
            displayedProgress = Double(start)
            scroll.scrollTo("row-\(start)", anchor: .center)
            try? await Task.sleep(nanoseconds: 350_000_000)
            if Task.isCancelled { return }
        }

        if let node = store.consumeCelebration() {
            burstID = UUID()
            burstNode = node
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            burstNode = nil
            if Task.isCancelled { return }
        }

        var current = Int(displayedProgress)
        if current > target {
            displayedProgress = Double(target)
            current = target
            scroll.scrollTo("row-\(target)", anchor: .center)
        }

        while current < target {
            if Task.isCancelled { return }
            current += 1
            withAnimation(.easeInOut(duration: 0.9)) {
                displayedProgress = Double(current)
                scroll.scrollTo("row-\(current)", anchor: .center)
            }
            try? await Task.sleep(nanoseconds: 950_000_000)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }

        store.setLastSeenNode(target)
    }
}
