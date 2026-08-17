//
//  EmailLoginSheet.swift
//  Photon
//
//  Created by Metin TASCI on 17.08.2026.
//

import SwiftUI

/// Minimalist, pure-white email login sheet specifically designed for review test users and email account login.
public struct EmailLoginSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var authService = AuthService.shared
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var errorMessage: String?
    @State private var resetPasswordSuccessMessage: String?
    @State private var isSendingReset: Bool = false
    
    var onLoginSuccess: () -> Void
    
    public init(onLoginSuccess: @escaping () -> Void) {
        self.onLoginSuccess = onLoginSuccess
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: PhotonSpacing.lg) {
                // Header Area
                VStack(spacing: PhotonSpacing.xxs) {
                    Text("E-posta ile Giriş")
                        .font(PhotonTypography.titleMedium)
                        .foregroundColor(PhotonColors.textPrimary)
                    
                    Text("Lütfen hesabınıza ait bilgileri giriniz.")
                        .font(PhotonTypography.bodyMedium)
                        .foregroundColor(PhotonColors.textSecondary)
                }
                .padding(.top, PhotonSpacing.md)
                
                // Form Area
                VStack(spacing: PhotonSpacing.md) {
                    // Email Input Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("E-posta")
                            .font(PhotonTypography.caption)
                            .foregroundColor(PhotonColors.textSecondary)
                        
                        HStack(spacing: PhotonSpacing.sm) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 14))
                                .foregroundColor(PhotonColors.textTertiary)
                            
                            TextField("ornek@domain.com", text: $email)
                                .font(PhotonTypography.bodyMedium)
                                .foregroundColor(PhotonColors.textPrimary)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled(true)
                            
                            if !email.isEmpty {
                                Button {
                                    email = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(PhotonColors.textTertiary)
                                }
                            }
                        }
                        .padding(.horizontal, PhotonSpacing.md)
                        .padding(.vertical, 12)
                        .background(PhotonColors.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: PhotonCornerRadius.md, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: PhotonCornerRadius.md, style: .continuous)
                                .strokeBorder(PhotonColors.border, lineWidth: 0.8)
                        )
                    }
                    
                    // Password Input Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Şifre")
                            .font(PhotonTypography.caption)
                            .foregroundColor(PhotonColors.textSecondary)
                        
                        HStack(spacing: PhotonSpacing.sm) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 14))
                                .foregroundColor(PhotonColors.textTertiary)
                            
                            if isPasswordVisible {
                                TextField("Şifreniz", text: $password)
                                    .font(PhotonTypography.bodyMedium)
                                    .foregroundColor(PhotonColors.textPrimary)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                            } else {
                                SecureField("Şifreniz", text: $password)
                                    .font(PhotonTypography.bodyMedium)
                                    .foregroundColor(PhotonColors.textPrimary)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                            }
                            
                            Button {
                                isPasswordVisible.toggle()
                            } label: {
                                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(PhotonColors.textTertiary)
                            }
                        }
                        .padding(.horizontal, PhotonSpacing.md)
                        .padding(.vertical, 12)
                        .background(PhotonColors.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: PhotonCornerRadius.md, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: PhotonCornerRadius.md, style: .continuous)
                                .strokeBorder(PhotonColors.border, lineWidth: 0.8)
                        )
                    }
                    
                    // Forgot Password Link
                    HStack {
                        Spacer()
                        Button {
                            handleForgotPassword()
                        } label: {
                            Text("Şifremi Unuttum")
                                .font(PhotonTypography.caption.weight(.medium))
                                .foregroundColor(PhotonColors.textSecondary)
                        }
                        .disabled(isSendingReset || authService.isLoading)
                    }
                }
                .padding(.horizontal, PhotonSpacing.md)
                
                // Feedback Message Banners
                if let errorMessage {
                    HStack(spacing: PhotonSpacing.xs) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundColor(PhotonColors.error)
                        
                        Text(errorMessage)
                            .font(PhotonTypography.caption)
                            .foregroundColor(PhotonColors.error)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal, PhotonSpacing.md)
                    .transition(.opacity)
                }
                
                if let resetPasswordSuccessMessage {
                    HStack(spacing: PhotonSpacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundColor(PhotonColors.success)
                        
                        Text(resetPasswordSuccessMessage)
                            .font(PhotonTypography.caption)
                            .foregroundColor(PhotonColors.success)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal, PhotonSpacing.md)
                    .transition(.opacity)
                }
                
                Spacer()
                
                // Login Action Button
                PhotonButton(
                    "Giriş Yap",
                    systemImage: "arrow.right",
                    variant: .primary,
                    size: .large,
                    isLoading: authService.isLoading
                ) {
                    performEmailSignIn()
                }
                .padding(.horizontal, PhotonSpacing.md)
                .padding(.bottom, PhotonSpacing.lg)
            }
            .photonBackground()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(PhotonColors.textTertiary)
                    }
                }
            }
        }
        .presentationDetents([.fraction(0.55), .medium])
        .presentationDragIndicator(.visible)
    }
    
    private func performEmailSignIn() {
        errorMessage = nil
        resetPasswordSuccessMessage = nil
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Lütfen e-posta adresinizi giriniz."
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Lütfen şifrenizi giriniz."
            return
        }
        
        Task {
            do {
                _ = try await authService.signInWithEmail(email: trimmedEmail, password: password)
                dismiss()
                onLoginSuccess()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func handleForgotPassword() {
        errorMessage = nil
        resetPasswordSuccessMessage = nil
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Şifre sıfırlama bağlantısı göndermek için lütfen e-posta adresinizi giriniz."
            return
        }
        
        isSendingReset = true
        Task {
            do {
                try await authService.sendPasswordReset(email: trimmedEmail)
                isSendingReset = false
                resetPasswordSuccessMessage = "Şifre sıfırlama bağlantısı e-posta adresinize gönderildi."
            } catch {
                isSendingReset = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
