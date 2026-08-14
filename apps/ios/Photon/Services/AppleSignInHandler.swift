//
//  AppleSignInHandler.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import Foundation
import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth

/// Native Apple Sign In Handler implementing cryptographically secure nonce generation,
/// SHA256 validation, and conversion to Firebase Apple credentials.
@MainActor
public final class AppleSignInHandler: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private var currentNonce: String?
    private var continuation: CheckedContinuation<AuthCredential, Error>?
    
    // MARK: - Public Flow
    
    public func startSignInWithAppleFlow() async throws -> AuthCredential {
        let rawNonce = Self.randomNonceString()
        self.currentNonce = rawNonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(rawNonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            authorizationController.performRequests()
        }
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first else {
            return UIWindow()
        }
        return window
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: AuthError.unknown("Geçersiz Apple kimlik bilgisi."))
            continuation = nil
            return
        }
        
        guard let nonce = currentNonce else {
            continuation?.resume(throwing: AuthError.unknown("Oturum güvenliği hatası (Nonce eksik)."))
            continuation = nil
            return
        }
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            continuation?.resume(throwing: AuthError.unknown("Apple Identity Token alınamadı."))
            continuation = nil
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            continuation?.resume(throwing: AuthError.unknown("Token dizesi ayrıştırılamadı."))
            continuation = nil
            return
        }
        
        // Generate native Firebase Apple Credential
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )
        
        continuation?.resume(returning: credential)
        continuation = nil
    }
    
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        let nsError = error as NSError
        if nsError.domain == ASAuthorizationError.errorDomain &&
            nsError.code == ASAuthorizationError.canceled.rawValue {
            continuation?.resume(throwing: AuthError.cancelled)
        } else {
            continuation?.resume(throwing: error)
        }
        continuation = nil
    }
    
    // MARK: - Nonce & Cryptographic Helpers
    
    private static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Nonce oluşturulamadı. Hata kodu: \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }
    
    private static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
}
