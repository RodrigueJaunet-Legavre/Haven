import SwiftUI
import Combine
import FamilyControls
import ManagedSettings

@MainActor
final class BlockerStore: ObservableObject {
    static let shared = BlockerStore()

    static let disableDelay: TimeInterval = 60 * 60 * 2

    @Published var isAuthorized = false

    @Published var isBlockingEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isBlockingEnabled, forKey: "isBlockingEnabled")
            applyShielding()
        }
    }

    @Published var pendingDisableDate: Date? {
        didSet {
            if let date = pendingDisableDate {
                UserDefaults.standard.set(date, forKey: "pendingDisableDate")
            } else {
                UserDefaults.standard.removeObject(forKey: "pendingDisableDate")
            }
        }
    }

    @Published var selection: FamilyActivitySelection {
        didSet {
            saveSelection()
            applyShielding()
        }
    }

    @Published var blockedDomains: [String] {
        didSet {
            UserDefaults.standard.set(blockedDomains, forKey: "blockedDomains")
            applyShielding()
        }
    }

    private let store = ManagedSettingsStore()
    private var pendingDisableTimer: Timer?

    private init() {
        isBlockingEnabled = UserDefaults.standard.bool(forKey: "isBlockingEnabled")
        blockedDomains = UserDefaults.standard.array(forKey: "blockedDomains") as? [String] ?? []
        pendingDisableDate = UserDefaults.standard.object(forKey: "pendingDisableDate") as? Date

        if let data = UserDefaults.standard.data(forKey: "familyActivitySelection"),
           let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            selection = decoded
        } else {
            selection = FamilyActivitySelection()
        }

        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved

        if isBlockingEnabled {
            applyShielding()
        }

        if let pendingDisableDate {
            scheduleDisable(at: pendingDisableDate)
        }
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        } catch {
            isAuthorized = false
        }
    }

    func requestDisable() {
        guard pendingDisableDate == nil else { return }
        let target = Date().addingTimeInterval(Self.disableDelay)
        pendingDisableDate = target
        scheduleDisable(at: target)
    }

    func cancelPendingDisable() {
        pendingDisableTimer?.invalidate()
        pendingDisableTimer = nil
        pendingDisableDate = nil
    }

    func applyEssentialPack() {
        let legalDomains = Set(knownGamblingSites.map { $0.domain })
        blockedDomains = Array(legalDomains.union(essentialCasinoDomains)).sorted()
    }

    private func scheduleDisable(at date: Date) {
        pendingDisableTimer?.invalidate()
        let interval = max(date.timeIntervalSinceNow, 0)
        pendingDisableTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.isBlockingEnabled = false
                self?.pendingDisableDate = nil
            }
        }
    }

    func addDomain(_ domain: String) {
        let trimmed = domain.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty, !blockedDomains.contains(trimmed) else { return }
        blockedDomains.append(trimmed)
    }

    func removeDomain(_ domain: String) {
        blockedDomains.removeAll { $0 == domain }
    }

    private func saveSelection() {
        if let data = try? JSONEncoder().encode(selection) {
            UserDefaults.standard.set(data, forKey: "familyActivitySelection")
        }
    }

    private func applyShielding() {
        guard isBlockingEnabled, isAuthorized else {
            store.shield.applications = nil
            store.shield.applicationCategories = nil
            store.webContent.blockedByFilter = nil
            return
        }

        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)

        if blockedDomains.isEmpty {
            store.webContent.blockedByFilter = nil
        } else {
            let domains = Set(blockedDomains.map { WebDomain(domain: $0) })
            store.webContent.blockedByFilter = .specific(domains)
        }
    }
}
