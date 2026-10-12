import StoreKit
import SwiftUI
import Combine

@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    static let monthlyProductID = "haven.premium.monthly"

    @Published var isSubscribed = false
    @Published var product: Product?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasCheckedSubscription = false

    private var updatesTask: Task<Void, Never>?

    #if DEBUG
    private var debugSimulatedPurchase = false

    private var debugForcesUnsubscribed: Bool {
        ProcessInfo.processInfo.environment["HAVEN_FORCE_UNSUBSCRIBED"] == "1"
    }
    #endif

    private init() {
        updatesTask = listenForTransactionUpdates()
        Task {
            await loadProduct()
            await refreshSubscriptionStatus()
            hasCheckedSubscription = true
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [Self.monthlyProductID])
            product = products.first
            if product == nil {
                print("🔴 HAVEN DEBUG — aucun produit ne correspond à l'ID \(Self.monthlyProductID)")
            }
        } catch {
            print("🔴 HAVEN DEBUG — erreur: \(error)")
            errorMessage = "Impossible de charger l'abonnement pour le moment."
        }
    }

    func purchase() async {
        #if DEBUG
        if debugForcesUnsubscribed {
            debugSimulatedPurchase = true
            isSubscribed = true
            return
        }
        #endif

        guard let product else {
            errorMessage = "Abonnement indisponible pour le moment."
            return
        }
        isLoading = true
        errorMessage = nil

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshSubscriptionStatus()
            case .userCancelled:
                break
            case .pending:
                errorMessage = "Achat en attente de validation."
            @unknown default:
                break
            }
        } catch {
            errorMessage = "L'achat n'a pas pu aboutir."
        }
        isLoading = false
    }

    func restorePurchases() async {
        isLoading = true
        try? await AppStore.sync()
        await refreshSubscriptionStatus()
        isLoading = false
    }

    func refreshSubscriptionStatus() async {
        #if DEBUG
        if debugForcesUnsubscribed {
            isSubscribed = debugSimulatedPurchase
            return
        }
        #endif

        var hasActiveSubscription = false
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result), transaction.productID == Self.monthlyProductID {
                hasActiveSubscription = true
            }
        }
        isSubscribed = hasActiveSubscription
    }

    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { continue }
                if let transaction = try? self.checkVerified(result) {
                    await transaction.finish()
                    await self.refreshSubscriptionStatus()
                }
            }
        }
    }

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    enum StoreError: Error {
        case failedVerification
    }
}
