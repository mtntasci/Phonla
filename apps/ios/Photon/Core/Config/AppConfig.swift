//
//  AppConfig.swift
//  Photon
//
//  Created by Metin TASCI on 15.08.2026.
//

import Foundation

/// Centralized configuration constants for Phonla iOS.
/// Manage all StoreKit 2 In-App Purchase IDs and Google AdMob IDs from this single point.
public enum AppConfig {
    
    // MARK: - StoreKit 2 In-App Purchases & Subscriptions
    public enum StoreKit {
        /// Product identifier for the monthly auto-renewable Phonla Pro subscription.
        /// TODO: CONFIG_REQUIRED - Set your App Store Connect Product ID here before App Store submission.
        public static let proMonthlyProductID: String = "com.alafteknoloji.photon.pro.monthly"
        
        /// Subscription Group Identifier configured in App Store Connect.
        /// TODO: CONFIG_REQUIRED - Set your App Store Connect Subscription Group ID here.
        public static let subscriptionGroupID: String = "21689452"
        
        /// All product identifiers offered by Phonla.
        public static let allProductIDs: Set<String> = [
            proMonthlyProductID
        ]
    }
    
    // MARK: - Google AdMob
    public enum AdMob {
        /// AdMob Application ID configured in Google AdMob Console.
        /// Defaults to Google's official iOS Test App ID.
        /// TODO: CONFIG_REQUIRED - Replace with your production AdMob Application ID (e.g. ca-app-pub-XXXXXXXX~YYYYYYYY) in Release builds.
        #if DEBUG
        public static let appID: String = "ca-app-pub-3940256099942544~1458002511"
        #else
        public static let appID: String = "ca-app-pub-3940256099942544~1458002511" // TODO: CONFIG_REQUIRED (Production App ID)
        #endif
        
        /// AdMob Rewarded Ad Unit ID shown to Free users before photo export.
        /// Defaults to Google's official iOS Rewarded Video Test Ad Unit ID.
        /// TODO: CONFIG_REQUIRED - Replace with your production Rewarded Ad Unit ID (e.g. ca-app-pub-XXXXXXXX/YYYYYYYY) in Release builds.
        #if DEBUG
        public static let rewardedExportAdUnitID: String = "ca-app-pub-3940256099942544/1712485313"
        #else
        public static let rewardedExportAdUnitID: String = "ca-app-pub-3940256099942544/1712485313" // TODO: CONFIG_REQUIRED (Production Ad Unit ID)
        #endif
        
        /// Tag for Child-Directed Treatment (COPPA) & Conservative / Non-Personalized Ad Serving.
        public static let isConservativePrivacyEnabled: Bool = true
    }
}
