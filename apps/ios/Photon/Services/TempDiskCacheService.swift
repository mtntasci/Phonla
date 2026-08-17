//
//  TempDiskCacheService.swift
//  Photon
//
//  Created by Metin TASCI on 17.08.2026.
//

import UIKit
import CoreImage

/// Contract for temporary disk caching of editing sessions and checkpoint states.
public protocol TempDiskCacheServiceProtocol: Sendable {
    func startNewSession() -> String
    func saveOriginalPreview(image: UIImage, sessionId: String) async -> URL?
    func saveCheckpoint(image: UIImage, index: Int, sessionId: String) async -> URL?
    func loadCheckpoint(index: Int, sessionId: String) async -> UIImage?
    func loadOriginalPreview(sessionId: String) async -> UIImage?
    func cleanupSession(sessionId: String)
    func cleanupAllStaleSessions()
}

/// Service managing disk-backed working images and checkpoints in `NSTemporaryDirectory()`
/// to prevent memory spikes and GPU context exhaustion during long editing sessions.
public final class TempDiskCacheService: TempDiskCacheServiceProtocol, @unchecked Sendable {
    public static let shared = TempDiskCacheService()
    
    private let fileManager = FileManager.default
    private let baseTempDirName = "photon_sessions"
    private let ioQueue = DispatchQueue(label: "com.photon.tempdiskcache", qos: .utility)
    
    public init() {
        cleanupAllStaleSessions()
    }
    
    // MARK: - Directory Helpers
    
    private var baseTempURL: URL {
        fileManager.temporaryDirectory.appendingPathComponent(baseTempDirName, isDirectory: true)
    }
    
    private func sessionDirectory(for sessionId: String) -> URL {
        baseTempURL.appendingPathComponent(sessionId, isDirectory: true)
    }
    
    private func checkpointsDirectory(for sessionId: String) -> URL {
        sessionDirectory(for: sessionId).appendingPathComponent("checkpoints", isDirectory: true)
    }
    
    // MARK: - Session Lifecycle
    
    public func startNewSession() -> String {
        let sessionId = UUID().uuidString
        let checkDir = checkpointsDirectory(for: sessionId)
        
        try? fileManager.createDirectory(at: checkDir, withIntermediateDirectories: true)
        return sessionId
    }
    
    // MARK: - Save & Load Original Preview
    
    public func saveOriginalPreview(image: UIImage, sessionId: String) async -> URL? {
        await withCheckedContinuation { continuation in
            ioQueue.async {
                let targetURL = self.sessionDirectory(for: sessionId).appendingPathComponent("original_preview.jpg")
                if let data = image.jpegData(compressionQuality: 0.92) {
                    try? data.write(to: targetURL, options: .atomic)
                    continuation.resume(returning: targetURL)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    public func loadOriginalPreview(sessionId: String) async -> UIImage? {
        await withCheckedContinuation { continuation in
            ioQueue.async {
                let targetURL = self.sessionDirectory(for: sessionId).appendingPathComponent("original_preview.jpg")
                guard let data = try? Data(contentsOf: targetURL), let image = UIImage(data: data) else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: image)
            }
        }
    }
    
    // MARK: - Save & Load Checkpoints
    
    public func saveCheckpoint(image: UIImage, index: Int, sessionId: String) async -> URL? {
        await withCheckedContinuation { continuation in
            ioQueue.async {
                let checkDir = self.checkpointsDirectory(for: sessionId)
                let targetURL = checkDir.appendingPathComponent("checkpoint_\(index).jpg")
                
                autoreleasepool {
                    if let data = image.jpegData(compressionQuality: 0.88) {
                        try? data.write(to: targetURL, options: .atomic)
                        continuation.resume(returning: targetURL)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }
    
    public func loadCheckpoint(index: Int, sessionId: String) async -> UIImage? {
        await withCheckedContinuation { continuation in
            ioQueue.async {
                let checkDir = self.checkpointsDirectory(for: sessionId)
                let targetURL = checkDir.appendingPathComponent("checkpoint_\(index).jpg")
                
                guard let data = try? Data(contentsOf: targetURL), let image = UIImage(data: data) else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: image)
            }
        }
    }
    
    // MARK: - Cleanup
    
    public func cleanupSession(sessionId: String) {
        ioQueue.async {
            let sessionDir = self.sessionDirectory(for: sessionId)
            try? self.fileManager.removeItem(at: sessionDir)
        }
    }
    
    public func cleanupAllStaleSessions() {
        ioQueue.async {
            let baseURL = self.baseTempURL
            guard let contents = try? self.fileManager.contentsOfDirectory(at: baseURL, includingPropertiesForKeys: nil) else {
                return
            }
            for url in contents {
                try? self.fileManager.removeItem(at: url)
            }
        }
    }
}
