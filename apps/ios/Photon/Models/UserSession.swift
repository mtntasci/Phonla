//
//  UserSession.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import Foundation

/// Represents the active user authentication state and minimal profile metadata.
public struct UserSession: Equatable, Codable, Sendable {
    public let uid: String
    public let email: String?
    public let displayName: String?
    public let isAnonymous: Bool
    
    public init(
        uid: String,
        email: String? = nil,
        displayName: String? = nil,
        isAnonymous: Bool = false
    ) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.isAnonymous = isAnonymous
    }
}
