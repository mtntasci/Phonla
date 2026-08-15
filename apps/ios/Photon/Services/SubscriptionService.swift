//
//  SubscriptionService.swift
//  Photon
//
//  Created by Metin TASCI on 15.08.2026.
//

import Foundation
import StoreKit
import Observation

/// Service errors for StoreKit 2 operations.
public enum SubscriptionError: LocalizedError, Equatable {
    case productNotFound
    case userCancelled
    case pendingVerification
    case verificationFailed
    case purchaseFailed(String)
    case restoreFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Abonelik ürünü bulunamadı. Lütfen internet bağlantınızı kontrol edip tekrar deneyin."
        case .userCancelled:
            return "Satın alma işlemi iptal edildi."
        case .pendingVerification:
            return "Satın alma işlemi onay bekliyor (Örn: Aile İzni / Onay)."
        case .verificationFailed:
            return "İşlem Apple StoreKit tarafından doğrulanamadı."
        case .purchaseFailed(let message):
            return "Satın alma başarısız: \(message)"
        case .restoreFailed(let message):
            return "Satın almaları geri yükleme başarısız: \(message)"
        }
    }
}

/// StoreKit 2 modern subscription service managing product discovery, in-app purchases,
/// real-time entitlement validation, family sharing updates, and transaction listeners.
@Observable
@MainActor
public final class SubscriptionService {
    public static let shared = SubscriptionService()
    
    // MARK: - Observable States
    public private(set) var isProUser: Bool = false
    public private(set) var proProduct: Product?
    public private(set) var isLoadingProducts: Bool = false
    public private(set) var isPurchasing: Bool = false
    public private(set) var isRestoring: Bool = false
    public var errorMessage: String?
    
    // Cache Key
    private let proCacheKey = "com.alafteknoloji.photon.isProUserCache"
    
    // Background updates task
    private var transactionListenerTask: Task<Void, Never>?
    
    public init() {
        // Load initial state from cache for instant offline UI responsiveness
        self.isProUser = UserDefaults.standard.bool(forKey: proCacheKey)
        
        // Start StoreKit 2 transaction updates listener
        startTransactionListener()
        
        // Fetch products and verify current active entitlements
        Task {
            await loadProducts()
            await checkCurrentEntitlements()
        }
    }
    
    // MARK: - Transaction Listener (StoreKit 2)
    
    private func startTransactionListener() {
        transactionListenerTask?.cancel()
        transactionListenerTask = Task.detached(priority: .background) {
            for await result in Transaction.updates {
                do {
                    let transaction = try Self.checkVerifiedTransaction(result)
                    await SubscriptionService.shared.updateCustomerProductStatus()
                    await transaction.finish()
                } catch {
                    print("[SubscriptionService] Transaction.updates verification failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Load Products
    
    public func loadProducts() async {
        guard !isLoadingProducts else { return }
        isLoadingProducts = true
        errorMessage = nil
        
        do {
            let products = try await Product.products(for: AppConfig.StoreKit.allProductIDs)
            self.proProduct = products.first(where: { $0.id == AppConfig.StoreKit.proMonthlyProductID })
        } catch {
            print("[SubscriptionService] Failed to load StoreKit products: \(error.localizedDescription)")
            self.errorMessage = "Ürün bilgileri yüklenemedi."
        }
        
        isLoadingProducts = false
    }
    
    // MARK: - Purchase Flow
    
    public func purchasePro() async throws {
        var productToPurchase = proProduct
        if productToPurchase == nil {
            let fetched = try await Product.products(for: [AppConfig.StoreKit.proMonthlyProductID])
            productToPurchase = fetched.first
        }
        
        guard let product = productToPurchase else {
            throw SubscriptionError.productNotFound
        }
        
        try await purchase(product: product)
    }
    
    public func purchase(product: Product) async throws {
        guard !isPurchasing else { return }
        isPurchasing = true
        errorMessage = nil
        
        defer {
            isPurchasing = false
        }
        
        let result: Product.PurchaseResult
        do {
            result = try await product.purchase()
        } catch {
            throw SubscriptionError.purchaseFailed(error.localizedDescription)
        }
        
        switch result {
        case .success(let verification):
            let transaction = try Self.checkVerifiedTransaction(verification)
            await updateCustomerProductStatus()
            await transaction.finish()
            
        case .userCancelled:
            throw SubscriptionError.userCancelled
            
        case .pending:
            throw SubscriptionError.pendingVerification
            
        @unknown default:
            throw SubscriptionError.purchaseFailed("Bilinmeyen satın alma sonucu.")
        }
    }
    
    // MARK: - Restore Purchases
    
    public func restorePurchases() async throws {
        guard !isRestoring else { return }
        isRestoring = true
        errorMessage = nil
        
        defer {
            isRestoring = false
        }
        
        do {
            try await AppStore.sync()
            await updateCustomerProductStatus()
        } catch {
            throw SubscriptionError.restoreFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Entitlement Verification
    
    public func checkCurrentEntitlements() async {
        await updateCustomerProductStatus()
    }
    
    public func updateCustomerProductStatus() async {
        var hasActivePro = false
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try Self.checkVerifiedTransaction(result)
                
                // Check if transaction matches pro product and is not revoked
                if transaction.productID == AppConfig.StoreKit.proMonthlyProductID {
                    if transaction.revocationDate == nil {
                        // Check expiration date if available
                        if let expirationDate = transaction.expirationDate {
                            if expirationDate > Date() {
                                hasActivePro = true
                            }
                        } else {
                            // Non-expiring lifetime / active entitlement
                            hasActivePro = true
                        }
                    }
                }
            } catch {
                print("[SubscriptionService] Entitlement verification error: \(error.localizedDescription)")
            }
        }
        
        // Update observable state and persistent cache
        setProStatus(hasActivePro)
    }
    
    private func setProStatus(_ isPro: Bool) {
        self.isProUser = isPro
        UserDefaults.standard.set(isPro, forKey: proCacheKey)
    }
    
    /// Verifies JWS cryptographic signature of a StoreKit 2 transaction.
    public nonisolated static func checkVerifiedTransaction<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
    public nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        try Self.checkVerifiedTransaction(result)
    }
    
    // MARK: - Test / Mock Helpers (For UI & Unit Testing)
    
    #if DEBUG
    public func setMockProUserForTesting(_ isPro: Bool) {
        setProStatus(isPro)
    }
    #endif
}
