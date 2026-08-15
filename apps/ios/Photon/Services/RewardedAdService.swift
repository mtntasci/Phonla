//
//  RewardedAdService.swift
//  Photon
//
//  Created by Metin TASCI on 15.08.2026.
//

import UIKit
import GoogleMobileAds
import Observation

/// The outcome of a rewarded ad presentation attempt.
public enum RewardedAdResult: Sendable, Equatable {
    /// The user watched the ad and earned the reward -> proceed to export.
    case rewardEarned
    /// The ad could not be loaded, presented, or failed -> fail-open to export.
    case failedOpen(String?)
    /// The user dismissed the ad before earning the reward -> do not export.
    case dismissedWithoutReward
}

/// Service managing Google AdMob Rewarded Ads for Free users before photo export.
/// Built with fail-open resilience, non-blocking background preloading, and strict privacy guarantees.
@Observable
@MainActor
public final class RewardedAdService: NSObject {
    public static let shared = RewardedAdService()
    
    // MARK: - State
    public private(set) var isAdLoaded: Bool = false
    public private(set) var isLoadingAd: Bool = false
    
    private var rewardedAd: GADRewardedAd?
    private var isAdMobInitialized: Bool = false
    
    // Active presentation continuation
    private var adContinuation: CheckedContinuation<RewardedAdResult, Never>?
    private var didEarnReward: Bool = false
    
    private override init() {
        super.init()
    }
    
    // MARK: - Initialization
    
    /// Initializes Google Mobile Ads SDK at app launch.
    public func initialize() {
        guard !isAdMobInitialized else { return }
        isAdMobInitialized = true
        
        // Configure child-directed treatment & conservative privacy settings
        if AppConfig.AdMob.isConservativePrivacyEnabled {
            GADMobileAds.sharedInstance().requestConfiguration.tagForChildDirectedTreatment = true
            GADMobileAds.sharedInstance().requestConfiguration.tagForUnderAgeOfConsent = true
        }
        
        GADMobileAds.sharedInstance().start { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.preloadAd()
            }
        }
    }
    
    // MARK: - Preloading (Background & Non-blocking)
    
    /// Preloads a rewarded ad in the background without blocking the UI.
    public func preloadAd() {
        guard rewardedAd == nil, !isLoadingAd else { return }
        isLoadingAd = true
        
        let request = GADRequest()
        
        GADRewardedAd.load(
            withAdUnitID: AppConfig.AdMob.rewardedExportAdUnitID,
            request: request
        ) { [weak self] ad, error in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.isLoadingAd = false
                
                if let error = error {
                    print("[RewardedAdService] Failed to load rewarded ad: \(error.localizedDescription)")
                    self.rewardedAd = nil
                    self.isAdLoaded = false
                    return
                }
                
                self.rewardedAd = ad
                self.rewardedAd?.fullScreenContentDelegate = self
                self.isAdLoaded = true
                print("[RewardedAdService] Rewarded ad preloaded successfully.")
            }
        }
    }
    
    // MARK: - Presentation Flow
    
    /// Presents the rewarded ad before export.
    /// Returns `RewardedAdResult` indicating whether reward was earned, ad failed (fail-open), or was dismissed early.
    public func presentRewardedAd() async -> RewardedAdResult {
        // Fail-open policy: If no ad is available, allow export immediately
        guard let ad = rewardedAd else {
            print("[RewardedAdService] No ad ready -> Fail-open: allowing export.")
            preloadAd()
            return .failedOpen("Reklam yüklenemedi.")
        }
        
        guard let rootVC = topViewController() else {
            print("[RewardedAdService] Root view controller not found -> Fail-open: allowing export.")
            return .failedOpen("Görünüm denetleyicisi bulunamadı.")
        }
        
        self.didEarnReward = false
        self.rewardedAd = nil
        self.isAdLoaded = false
        
        return await withCheckedContinuation { continuation in
            self.adContinuation = continuation
            
            ad.present(fromRootViewController: rootVC) { [weak self] in
                guard let self = self else { return }
                self.didEarnReward = true
                print("[RewardedAdService] User earned reward.")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let baseController: UIViewController?
        if let base = base {
            baseController = base
        } else {
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            let keyWindow = scenes.flatMap { $0.windows }.first { $0.isKeyWindow }
            baseController = keyWindow?.rootViewController
        }
        
        if let nav = baseController as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = baseController as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = baseController?.presentedViewController {
            return topViewController(base: presented)
        }
        return baseController
    }
}

// MARK: - GADFullScreenContentDelegate

extension RewardedAdService: GADFullScreenContentDelegate {
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("[RewardedAdService] Ad dismissed. Reward earned: \(didEarnReward)")
        
        let result: RewardedAdResult = didEarnReward ? .rewardEarned : .dismissedWithoutReward
        adContinuation?.resume(returning: result)
        adContinuation = nil
        
        // Preload next ad for subsequent exports
        preloadAd()
    }
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("[RewardedAdService] Failed to present ad: \(error.localizedDescription) -> Fail-open.")
        
        adContinuation?.resume(returning: .failedOpen(error.localizedDescription))
        adContinuation = nil
        
        // Preload next ad
        preloadAd()
    }
}
