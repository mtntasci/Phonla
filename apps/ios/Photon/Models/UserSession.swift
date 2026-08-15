//
//  UserSession.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import Foundation

/// Represents the active user authentication state and profile metadata.
public struct UserSession: Equatable, Codable, Sendable {
    public let uid: String
    public let email: String?
    public let displayName: String?
    public let photoURL: URL?
    public let providerId: String?
    public let isAnonymous: Bool
    
    public init(
        uid: String,
        email: String? = nil,
        displayName: String? = nil,
        photoURL: URL? = nil,
        providerId: String? = nil,
        isAnonymous: Bool = false
    ) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.providerId = providerId
        self.isAnonymous = isAnonymous
    }
}

