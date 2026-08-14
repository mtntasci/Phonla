//
//  MembershipView.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Membership selection and tier presentation view for Free and upcoming Pro tiers.
public struct MembershipView: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PhotonSpacing.xl) {
                    // Header Description
                    VStack(spacing: PhotonSpacing.xs) {
                        Text("Photon Üyelikleri")
                            .font(PhotonTypography.titleLarge)
                            .foregroundColor(PhotonColors.textPrimary)
                        
                        Text("Fotoğraf düzenleme deneyiminizi bir üst seviyeye taşıyın.")
                            .font(PhotonTypography.bodyMedium)
                            .foregroundColor(PhotonColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, PhotonSpacing.md)
                    
                    // MARK: - Free Tier Card
                    VStack(alignment: .leading, spacing: PhotonSpacing.md) {
                        HStack {
                            VStack(alignment: .leading, spacing: PhotonSpacing.xxs) {
                                Text("Photon Standart")
                                    .font(PhotonTypography.titleMedium)
                                    .foregroundColor(PhotonColors.textPrimary)
                                
                                Text("Ücretsiz")
                                    .font(PhotonTypography.caption)
                                    .foregroundColor(PhotonColors.textSecondary)
                            }
                            
                            Spacer()
                            
                            Text("Mevcut Plan")
                                .font(PhotonTypography.caption.weight(.semibold))
                                .foregroundColor(PhotonColors.textPrimary)
                                .padding(.horizontal, PhotonSpacing.sm)
                                .padding(.vertical, 4)
                                .background(PhotonColors.surfaceSecondary)
                                .clipShape(Capsule())
                        }
                        
                        Divider().foregroundColor(PhotonColors.divider)
                        
                        VStack(alignment: .leading, spacing: PhotonSpacing.sm) {
                            featureRow(text: "Işık & Renk ayarları (Pozlama, Sıcaklık vb.)", isIncluded: true)
                            featureRow(text: "Sinematik Görünüm & Film önayarları", isIncluded: true)
                            featureRow(text: "Profesyonel Monochrome tonlama motoru", isIncluded: true)
                            featureRow(text: "Tam çözünürlüklü kayıpsız dışa aktarma", isIncluded: true)
                            featureRow(text: "Donanım hızlandırmalı on-device gizlilik", isIncluded: true)
                        }
                    }
                    .padding(PhotonSpacing.lg)
                    .photonCard()
                    
                    // MARK: - Pro Tier Card (Upcoming)
                    VStack(alignment: .leading, spacing: PhotonSpacing.md) {
                        HStack {
                            VStack(alignment: .leading, spacing: PhotonSpacing.xxs) {
                                HStack(spacing: PhotonSpacing.xs) {
                                    Text("Photon Pro")
                                        .font(PhotonTypography.titleMedium)
                                        .foregroundColor(PhotonColors.textInverted)
                                    
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.yellow)
                                }
                                
                                Text("Yakında")
                                    .font(PhotonTypography.caption)
                                    .foregroundColor(PhotonColors.textInverted.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            Text("Geliştiriliyor")
                                .font(PhotonTypography.caption.weight(.semibold))
                                .foregroundColor(Color.black)
                                .padding(.horizontal, PhotonSpacing.sm)
                                .padding(.vertical, 4)
                                .background(Color.yellow)
                                .clipShape(Capsule())
                        }
                        
                        Divider().foregroundColor(Color.white.opacity(0.2))
                        
                        Text("Yakında: AI Otomatik Düzenleme ve gelişmiş özellikler")
                            .font(PhotonTypography.bodyMedium.weight(.medium))
                            .foregroundColor(PhotonColors.textInverted)
                        
                        VStack(alignment: .leading, spacing: PhotonSpacing.sm) {
                            featureRow(text: "Yapay Zeka ile Otomatik Renk & Işık İyileştirme", isIncluded: true, isInverted: true)
                            featureRow(text: "Özel 3D LUT ve Film Emülasyonu Desteği", isIncluded: true, isInverted: true)
                            featureRow(text: "Gelişmiş Renk Eğrileri (RGB Tone Curves)", isIncluded: true, isInverted: true)
                            featureRow(text: "Gelişmiş Bölgesel Maskeleme & Seçici Düzenleme", isIncluded: true, isInverted: true)
                        }
                    }
                    .padding(PhotonSpacing.lg)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: PhotonCornerRadius.lg, style: .continuous))
                    .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
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
        }
    }
    
    private func featureRow(text: String, isIncluded: Bool, isInverted: Bool = false) -> some View {
        HStack(spacing: PhotonSpacing.sm) {
            Image(systemName: isIncluded ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14))
                .foregroundColor(isInverted ? (isIncluded ? Color.green : Color.white.opacity(0.4)) : (isIncluded ? PhotonColors.textPrimary : PhotonColors.textTertiary))
            
            Text(text)
                .font(PhotonTypography.caption)
                .foregroundColor(isInverted ? PhotonColors.textInverted.opacity(0.9) : PhotonColors.textSecondary)
        }
    }
}

#Preview {
    MembershipView()
}
