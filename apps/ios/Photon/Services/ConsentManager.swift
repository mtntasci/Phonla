//
//  ConsentManager.swift
//  Photon
//
//  Created by Metin TASCI on 15.08.2026.
//

import UIKit
import AppTrackingTransparency
import UserMessagingPlatform
import GoogleMobileAds
import Observation

/// Centralized manager for Google User Messaging Platform (UMP),
/// Apple App Tracking Transparency (ATT), and GDPR/Privacy Options Form presentation.
@Observable
@MainActor
public final class ConsentManager: NSObject {
    public static let shared = ConsentManager()
    
    // MARK: - Observable States
    public private(set) var isConsentGathered: Bool = false
    public private(set) var isPrivacyOptionsRequired: Bool = false
    public private(set) var canRequestAds: Bool = false
    public private(set) var trackingStatus: ATTrackingManager.AuthorizationStatus = .notDetermined
    
    private var isAdMobStarted: Bool = false
    
    private override init() {
        super.init()
        self.updateTrackingStatus()
    }
    
    // MARK: - 1. Full Consent & ATT Flow at Launch
    
    /// Starts Google UMP consent update, presents consent form if required,
    /// requests ATT if appropriate, and initializes Google Mobile Ads SDK.
    public func gatherConsentAndInitializeAds(from rootViewController: UIViewController? = nil) {
        let parameters = UMPRequestParameters()
        
        #if DEBUG
        let debugSettings = UMPDebugSettings()
        // debugSettings.geography = .EEA // Uncomment when simulating European Economic Area GDPR in simulator
        parameters.debugSettings = debugSettings
        #endif
        
        // Request an update to consent information
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) { [weak self] error in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                if let error = error {
                    print("[ConsentManager] requestConsentInfoUpdate error: \(error.localizedDescription)")
                    // Fail-safe: proceed with limited ads / fail-open initialization
                    self.finalizeConsentAndInitializeAds()
                    return
                }
                
                // Present UMP consent form if required by Google policy
                let targetVC = rootViewController ?? self.topViewController()
                
                UMPConsentForm.loadAndPresentIfRequired(from: targetVC) { [weak self] loadAndPresentError in
                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        
                        if let error = loadAndPresentError {
                            print("[ConsentManager] loadAndPresentIfRequired error: \(error.localizedDescription)")
                        }
                        
                        self.isPrivacyOptionsRequired = (UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus == .required)
                        self.canRequestAds = UMPConsentInformation.sharedInstance.canRequestAds
                        
                        // After UMP consent is handled, prompt for ATT if not yet determined
                        self.requestAppTrackingTransparencyIfAppropriate { [weak self] in
                            Task { @MainActor [weak self] in
                                self?.finalizeConsentAndInitializeAds()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 2. Apple App Tracking Transparency (ATT)
    
    /// Requests ATT permission if status is `.notDetermined`. Does not re-prompt if already answered.
    public func requestAppTrackingTransparencyIfAppropriate(completion: @escaping @Sendable () -> Void) {
        self.updateTrackingStatus()
        
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else {
            completion()
            return
        }
        
        // Request system ATT prompt
        ATTrackingManager.requestTrackingAuthorization { [weak self] status in
            Task { @MainActor [weak self] in
                self?.trackingStatus = status
                print("[ConsentManager] ATT Authorization Status: \(status.rawValue)")
                completion()
            }
        }
    }
    
    private func updateTrackingStatus() {
        self.trackingStatus = ATTrackingManager.trackingAuthorizationStatus
    }
    
    // MARK: - 3. AdMob Initialization & Preloading
    
    private func finalizeConsentAndInitializeAds() {
        self.isConsentGathered = true
        self.canRequestAds = UMPConsentInformation.sharedInstance.canRequestAds
        self.isPrivacyOptionsRequired = (UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus == .required)
        
        guard !isAdMobStarted else { return }
        isAdMobStarted = true
        
        // Configure child-directed treatment & conservative privacy settings
        if AppConfig.AdMob.isConservativePrivacyEnabled {
            GADMobileAds.sharedInstance().requestConfiguration.tagForChildDirectedTreatment = true
            GADMobileAds.sharedInstance().requestConfiguration.tagForUnderAgeOfConsent = true
        }
        
        GADMobileAds.sharedInstance().start { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                print("[ConsentManager] Google Mobile Ads SDK initialized.")
                
                // Preload rewarded ad only if user is NOT Pro and ads are allowed
                let isPro = SubscriptionService.shared.isProUser
                if !isPro && self.canRequestAds {
                    RewardedAdService.shared.preloadAd()
                }
            }
        }
    }
    
    // MARK: - 4. Privacy Options Form (Ayarlar -> Reklam Gizliliği)
    
    /// Presents Google UMP Privacy Options Form from settings, allowing users to revoke or modify their consent.
    public func presentPrivacyOptionsForm(from viewController: UIViewController? = nil, completion: (@Sendable (Error?) -> Void)? = nil) {
        let targetVC = viewController ?? topViewController()
        
        guard let targetVC = targetVC else {
            completion?(NSError(domain: "PhotonlaConsent", code: -1, userInfo: [NSLocalizedDescriptionKey: "Görünüm denetleyicisi bulunamadı."]))
            return
        }
        
        UMPConsentForm.presentPrivacyOptionsForm(from: targetVC) { [weak self] formError in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                self.isPrivacyOptionsRequired = (UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus == .required)
                self.canRequestAds = UMPConsentInformation.sharedInstance.canRequestAds
                
                if let error = formError {
                    print("[ConsentManager] presentPrivacyOptionsForm error: \(error.localizedDescription)")
                } else {
                    print("[ConsentManager] Privacy options updated. canRequestAds: \(self.canRequestAds)")
                }
                
                completion?(formError)
            }
        }
    }
    
    // MARK: - Helper to find top UIViewController
    
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
