import SwiftUI
import Combine
import FamilyControls
import ManagedSettings

@MainActor
final class BlockerStore: ObservableObject {
    static let shared = BlockerStore()

    @Published var isAuthorized = false

    @Published var isBlockingEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isBlockingEnabled, forKey: "isBlockingEnabled")
            applyShielding()
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

    private init() {
        isBlockingEnabled = UserDefaults.standard.bool(forKey: "isBlockingEnabled")
        blockedDomains = UserDefaults.standard.array(forKey: "blockedDomains") as? [String] ?? []

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
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        } catch {
            isAuthorized = false
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
