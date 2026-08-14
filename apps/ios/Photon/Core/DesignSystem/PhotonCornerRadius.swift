//
//  PhotonCornerRadius.swift
//  Photon
//
//  Created by Metin TASCI on 14.08.2026.
//

import SwiftUI

/// Standard corner radius scale for Photon UI elements.
public enum PhotonCornerRadius {
    /// 4 pt - Small badges, micro tags
    public static let xs: CGFloat = 4
    /// 8 pt - Tool items, secondary chips
    public static let sm: CGFloat = 8
    /// 12 pt - Standard buttons, text fields, small cards
    public static let md: CGFloat = 12
    /// 16 pt - Medium cards, action sheets, dialogs
    public static let lg: CGFloat = 16
    /// 24 pt - Large containers, modal sheets
    public static let xl: CGFloat = 24
    /// 999 pt - Fully rounded pills and circular buttons
    public static let full: CGFloat = 999
}
