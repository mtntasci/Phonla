//
//  AuthService.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseCore
import AuthenticationServices

/// Authentication providers supported by Photon.
public enum AuthProvider: String, CaseIterable, Identifiable, Sendable {
    case apple = "Apple"
    case google = "Google"
    case facebook = "Facebook"
    
    public var id: String { rawValue }
    
    public var systemIcon: String {
        switch self {
        case .apple: return "apple.logo"
        case .google: return "globe"
        case .facebook: return "f.circle"
        }
    }
}

/// Authentication error representations.
public enum AuthError: LocalizedError, Sendable {
    case providerUnavailable(String)
    case missingConfiguration(String)
    case cancelled
    case notAuthenticated
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .providerUnavailable(let provider):
            return "\(provider) ile giriş şu anda kullanılamıyor."
        case .missingConfiguration(let reason):
            return "Kimlik doğrulama yapılandırması eksik: \(reason)"
        case .cancelled:
            return "Giriş işlemi iptal edildi."
        case .notAuthenticated:
            return "Aktif bir oturum bulunamadı."
        case .unknown(let message):
            return message
        }
    }
}

/// Contract for Authentication and Session Management in Photon.
public protocol AuthServiceProtocol: Sendable {
    var currentSession: UserSession? { get }
    var isAuthenticated: Bool { get }
    var isFirebaseConfigured: Bool { get }
    
    func checkCurrentSession() async -> UserSession?
    func signIn(with provider: AuthProvider) async throws -> UserSession
    func signOut() async throws
}

/// Production authentication service backed by Firebase Auth.
/// Manages real currentUser lifecycle, persistent tokens, and secure sign-out.
@MainActor
@Observable
public final class AuthService: NSObject, AuthServiceProtocol {
    public static let shared = AuthService()
    
    public private(set) var currentSession: UserSession?
    public private(set) var isLoading: Bool = false
    public private(set) var lastError: String?
    
    private var appleSignInHandler: AppleSignInHandler?
    
    public var isAuthenticated: Bool {
        currentSession != nil
    }
    
    public var isFirebaseConfigured: Bool {
        ensureFirebaseConfigured()
        return FirebaseApp.app() != nil
    }
    
    public override init() {
        super.init()
        // Synchronize with Firebase Auth currentUser on launch
        self.syncFirebaseCurrentUser()
    }
    
    // MARK: - Safe Firebase Configuration Guard
    
    @discardableResult
    private func ensureFirebaseConfigured() -> Bool {
        if FirebaseApp.app() == nil {
            if let plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: plistPath) {
                FirebaseApp.configure(options: options)
            } else {
                FirebaseApp.configure()
            }
        }
        return FirebaseApp.app() != nil
    }
    
    // MARK: - Synchronize Session
    
    private func syncFirebaseCurrentUser() {
        guard ensureFirebaseConfigured() else {
            self.currentSession = nil
            return
        }
        
        if let firebaseUser = Auth.auth().currentUser {
            self.currentSession = UserSession(
                uid: firebaseUser.uid,
                email: firebaseUser.email,
                displayName: firebaseUser.displayName ?? (firebaseUser.email?.components(separatedBy: "@").first?.capitalized ?? "Photon Üyesi"),
                photoURL: firebaseUser.photoURL,
                isAnonymous: firebaseUser.isAnonymous
            )
        } else {
            self.currentSession = nil
        }
    }
    
    // MARK: - Session Verification
    
    public func checkCurrentSession() async -> UserSession? {
        syncFirebaseCurrentUser()
        return self.currentSession
    }
    
    // MARK: - Sign In Flows
    
    public func signIn(with provider: AuthProvider) async throws -> UserSession {
        isLoading = true
        lastError = nil
        defer { isLoading = false }
        
        guard ensureFirebaseConfigured() else {
            throw AuthError.missingConfiguration("Firebase yapılandırılmamış.")
        }
        
        do {
            let authResult: AuthDataResult
            
            switch provider {
            case .apple:
                // Native Apple Sign In flow with cryptographic nonce & Apple ID Provider
                let handler = AppleSignInHandler()
                self.appleSignInHandler = handler
                let credential = try await handler.startSignInWithAppleFlow()
                authResult = try await Auth.auth().signIn(with: credential)
                self.appleSignInHandler = nil
                
            case .google:
                // Google OAuth Provider
                let oAuthProvider = OAuthProvider(providerID: "google.com")
                oAuthProvider.scopes = ["email", "profile"]
                let credential = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AuthCredential, Error>) in
                    oAuthProvider.getCredentialWith(nil) { credential, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let credential = credential {
                            continuation.resume(returning: credential)
                        } else {
                            continuation.resume(throwing: AuthError.cancelled)
                        }
                    }
                }
                authResult = try await Auth.auth().signIn(with: credential)
                
            case .facebook:
                // Facebook OAuth Provider
                let oAuthProvider = OAuthProvider(providerID: "facebook.com")
                oAuthProvider.scopes = ["email", "public_profile"]
                let credential = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AuthCredential, Error>) in
                    oAuthProvider.getCredentialWith(nil) { credential, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let credential = credential {
                            continuation.resume(returning: credential)
                        } else {
                            continuation.resume(throwing: AuthError.cancelled)
                        }
                    }
                }
                authResult = try await Auth.auth().signIn(with: credential)
            }
            
            let user = authResult.user
            
            // Extract display name from user profile or fallback
            var resolvedDisplayName = user.displayName
            if (resolvedDisplayName == nil || resolvedDisplayName?.isEmpty == true),
               let additionalProfile = authResult.additionalUserInfo?.profile,
               let nameDict = additionalProfile["name"] as? [String: Any] {
                let firstName = nameDict["firstName"] as? String ?? ""
                let lastName = nameDict["lastName"] as? String ?? ""
                let full = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                if !full.isEmpty {
                    resolvedDisplayName = full
                }
            }
            
            let session = UserSession(
                uid: user.uid,
                email: user.email,
                displayName: resolvedDisplayName ?? (user.email?.components(separatedBy: "@").first?.capitalized ?? "Photon Üyesi"),
                photoURL: user.photoURL,
                isAnonymous: user.isAnonymous
            )
            
            self.currentSession = session
            return session
        } catch {
            self.lastError = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Sign Out
    
    public func signOut() async throws {
        isLoading = true
        defer { isLoading = false }
        
        guard ensureFirebaseConfigured() else {
            self.currentSession = nil
            return
        }
        
        do {
            try Auth.auth().signOut()
            self.currentSession = nil
        } catch {
            self.lastError = error.localizedDescription
            throw error
        }
    }
}
