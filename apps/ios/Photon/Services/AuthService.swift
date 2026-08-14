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
        
        let providerID: String
        var scopes: [String] = []
        
        switch provider {
        case .apple:
            providerID = "apple.com"
            scopes = ["email", "name"]
        case .google:
            providerID = "google.com"
            scopes = ["email", "profile"]
        case .facebook:
            providerID = "facebook.com"
            scopes = ["email", "public_profile"]
        }
        
        let oAuthProvider = OAuthProvider(providerID: providerID)
        oAuthProvider.scopes = scopes
        
        do {
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
            
            let authResult = try await Auth.auth().signIn(with: credential)
            let user = authResult.user
            let session = UserSession(
                uid: user.uid,
                email: user.email,
                displayName: user.displayName ?? (user.email?.components(separatedBy: "@").first?.capitalized ?? "Photon Üyesi"),
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
