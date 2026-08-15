//
//  MembershipView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI
import StoreKit

/// Membership selection and tier presentation view for Free (Standart) and Pro tiers.
/// Powered by StoreKit 2 with real-time entitlement validation and localized pricing.
public struct MembershipView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var subscriptionService = SubscriptionService.shared
    
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PhotonSpacing.xl) {
                    // Header Description
                    VStack(spacing: PhotonSpacing.xs) {
                        Text("Photonla Üyelikleri")
                            .font(PhotonTypography.titleLarge)
                            .foregroundColor(PhotonColors.textPrimary)
                        
                        Text("Fotoğraf düzenleme deneyiminizi reklamsız ve kesintisiz yaşayın.")
                            .font(PhotonTypography.bodyMedium)
                            .foregroundColor(PhotonColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, PhotonSpacing.md)
                    
                    // MARK: - Free (Standart) Tier Card
                    VStack(alignment: .leading, spacing: PhotonSpacing.md) {
                        HStack {
                            VStack(alignment: .leading, spacing: PhotonSpacing.xxs) {
                                Text("Photonla Standart")
                                    .font(PhotonTypography.titleMedium)
                                    .foregroundColor(PhotonColors.textPrimary)
                                
                                Text("Ücretsiz")
                                    .font(PhotonTypography.caption)
                                    .foregroundColor(PhotonColors.textSecondary)
                            }
                            
                            Spacer()
                            
                            if !subscriptionService.isProUser {
                                Text("Mevcut Plan")
                                    .font(PhotonTypography.caption.weight(.semibold))
                                    .foregroundColor(PhotonColors.textPrimary)
                                    .padding(.horizontal, PhotonSpacing.sm)
                                    .padding(.vertical, 4)
                                    .background(PhotonColors.surfaceSecondary)
                                    .clipShape(Capsule())
                            }
                        }
                        
                        Divider().foregroundColor(PhotonColors.divider)
                        
                        VStack(alignment: .leading, spacing: PhotonSpacing.sm) {
                            featureRow(text: "Tüm Işık, Renk ve Cilt pürüzsüzleştirme araçları", isIncluded: true)
                            featureRow(text: "Sinematik & Siyah/Beyaz tonlama önayarları", isIncluded: true)
                            featureRow(text: "Tam çözünürlüklü kayıpsız dışa aktarma", isIncluded: true)
                            featureRow(text: "Export öncesi 1 kısa reklam gösterimi", isIncluded: true, highlightWarning: true)
                            featureRow(text: "On-device donanım hızlandırmalı gizlilik", isIncluded: true)
                        }
                    }
                    .padding(PhotonSpacing.lg)
                    .photonCard()
                    
                    // MARK: - Pro Tier Card
                    VStack(alignment: .leading, spacing: PhotonSpacing.md) {
                        HStack {
                            VStack(alignment: .leading, spacing: PhotonSpacing.xxs) {
                                HStack(spacing: PhotonSpacing.xs) {
                                    Text("Photonla Pro")
                                        .font(PhotonTypography.titleMedium)
                                        .foregroundColor(PhotonColors.textInverted)
                                    
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.yellow)
                                }
                                
                                if let proProduct = subscriptionService.proProduct {
                                    Text("\(proProduct.displayPrice) / Ay")
                                        .font(PhotonTypography.caption.weight(.medium))
                                        .foregroundColor(PhotonColors.textInverted.opacity(0.85))
                                } else {
                                    Text("Aylık Plan")
                                        .font(PhotonTypography.caption)
                                        .foregroundColor(PhotonColors.textInverted.opacity(0.85))
                                }
                            }
                            
                            Spacer()
                            
                            if subscriptionService.isProUser {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 11))
                                    Text("Aktif")
                                        .font(PhotonTypography.caption.weight(.semibold))
                                }
                                .foregroundColor(Color.black)
                                .padding(.horizontal, PhotonSpacing.sm)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .clipShape(Capsule())
                            }
                        }
                        
                        Divider().foregroundColor(Color.white.opacity(0.2))
                        
                        VStack(alignment: .leading, spacing: PhotonSpacing.sm) {
                            featureRow(text: "Tamamen Reklamsız ve anında dışa aktarma", isIncluded: true, isInverted: true)
                            featureRow(text: "Kesintisiz ve sınırsız fotoğraf düzenleme", isIncluded: true, isInverted: true)
                            featureRow(text: "Gelecek tüm gelişmiş Pro özellikleri & Yapay Zeka araçları", isIncluded: true, isInverted: true)
                            featureRow(text: "Özel LUT ve Film emülasyonu desteği", isIncluded: true, isInverted: true)
                        }
                        
                        // Purchase Button
                        VStack(spacing: PhotonSpacing.xs) {
                            if subscriptionService.isProUser {
                                HStack {
                                    Spacer()
                                    Label("Photonla Pro Aktif", systemImage: "checkmark.circle.fill")
                                        .font(PhotonTypography.bodyMedium.weight(.semibold))
                                        .foregroundColor(Color.black)
                                    Spacer()
                                }
                                .padding(.vertical, PhotonSpacing.md)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: PhotonCornerRadius.md, style: .continuous))
                            } else {
                                Button {
                                    handlePurchase()
                                } label: {
                                    HStack {
                                        Spacer()
                                        if subscriptionService.isPurchasing {
                                            ProgressView()
                                                .tint(Color.black)
                                                .padding(.trailing, PhotonSpacing.xs)
                                            Text("Satın Alınıyor...")
                                                .font(PhotonTypography.bodyMedium.weight(.semibold))
                                                .foregroundColor(Color.black)
                                        } else {
                                            let priceText = subscriptionService.proProduct?.displayPrice ?? ""
                                            Text(priceText.isEmpty ? "Photonla Pro'ya Geç" : "Pro'ya Geç • \(priceText) / Ay")
                                                .font(PhotonTypography.bodyMedium.weight(.semibold))
                                                .foregroundColor(Color.black)
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, PhotonSpacing.md)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: PhotonCornerRadius.md, style: .continuous))
                                }
                                .disabled(subscriptionService.isPurchasing)
                            }
                        }
                        .padding(.top, PhotonSpacing.xs)
                    }
                    .padding(PhotonSpacing.lg)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: PhotonCornerRadius.lg, style: .continuous))
                    .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
                    
                    // MARK: - Restore Purchases Button
                    Button {
                        handleRestore()
                    } label: {
                        HStack(spacing: PhotonSpacing.xs) {
                            if subscriptionService.isRestoring {
                                ProgressView()
                                    .tint(PhotonColors.textPrimary)
                            }
                            Text("Satın Almaları Geri Yükle")
                                .font(PhotonTypography.caption.weight(.medium))
                                .foregroundColor(PhotonColors.textSecondary)
                        }
                        .padding(.vertical, PhotonSpacing.xs)
                    }
                    .disabled(subscriptionService.isRestoring)
                    
                    // Legal Info
                    Text("Abonelik Apple kimliğiniz üzerinden yenilenir. İstediğiniz zaman App Store hesap ayarlarından iptal edebilirsiniz.")
                        .font(.system(size: 11))
                        .foregroundColor(PhotonColors.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, PhotonSpacing.md)
                }
                .padding(.horizontal, PhotonSpacing.lg)
                .padding(.bottom, PhotonSpacing.xxl)
            }
            .photonBackground()
            .navigationTitle("Üyelikler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(PhotonColors.textPrimary)
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .task {
                await subscriptionService.loadProducts()
                await subscriptionService.checkCurrentEntitlements()
            }
        }
    }
    
    // MARK: - Purchase Actions
    
    private func handlePurchase() {
        Task {
            do {
                try await subscriptionService.purchasePro()
                alertTitle = "Tebrikler!"
                alertMessage = "Phonla Pro üyeliğiniz aktif edildi. Tüm reklamsız ve premium özelliklerin tadını çıkarın."
                showAlert = true
            } catch {
                if let subError = error as? SubscriptionError, subError == .userCancelled {
                    // Do not display alert on deliberate user cancellation
                    return
                }
                alertTitle = "Satın Alma Hatası"
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
    
    private func handleRestore() {
        Task {
            do {
                try await subscriptionService.restorePurchases()
                if subscriptionService.isProUser {
                    alertTitle = "Geri Yüklendi"
                    alertMessage = "Phonla Pro aboneliğiniz başarıyla geri yüklendi."
                } else {
                    alertTitle = "Aktif Abonelik Bulunamadı"
                    alertMessage = "Apple hesabınıza bağlı geçerli bir Phonla Pro aboneliği bulunamadı."
                }
                showAlert = true
            } catch {
                alertTitle = "Geri Yükleme Hatası"
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
    
    // MARK: - Helpers
    
    private func featureRow(text: String, isIncluded: Bool, isInverted: Bool = false, highlightWarning: Bool = false) -> some View {
        HStack(spacing: PhotonSpacing.sm) {
            Image(systemName: isIncluded ? (highlightWarning ? "play.rectangle.fill" : "checkmark.circle.fill") : "circle")
                .font(.system(size: 14))
                .foregroundColor(
                    isInverted ? (isIncluded ? Color.green : Color.white.opacity(0.4)) :
                        (highlightWarning ? PhotonColors.accent : (isIncluded ? PhotonColors.textPrimary : PhotonColors.textTertiary))
                )
            
            Text(text)
                .font(PhotonTypography.caption)
                .foregroundColor(isInverted ? PhotonColors.textInverted.opacity(0.9) : PhotonColors.textSecondary)
        }
    }
}

#Preview {
    MembershipView()
}
