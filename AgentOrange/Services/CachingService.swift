//
//  FileCachingService.swift
//  AgentOrange
//
//  Created by Paul Leo on 30/09/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.
//

import Foundation
import DiskCache

protocol CachingServiceProtocol {
    func clearCache(for key: String)
    func clearAllCache()
}

protocol SelectionCachingServiceProtocol: CachingServiceProtocol {
    func getSelectionContent(for key: String) async -> Set<Int>?
    func saveSelectionContent(with key: String, rows: Set<Int>)
}

protocol FileCachingServiceProtocol: SelectionCachingServiceProtocol {
    func getFileContent(with key: String) async -> (fileContent: String, byteSize: Int)?
    func saveFileContent(for key: String, fileContent: String)
}

protocol ScrollCachingServiceProtocol: CachingServiceProtocol {
    func getScrollPosition(for key: String) async -> CGFloat?
    func saveScrollPosition(with key: String, position: CGFloat)
}

struct CachingService {
    var cache: DiskCache?
    
    init(folderName: String = Bundle.main.bundleIdentifier ?? "com.tapdigital.agentorange") {
        if let _ = cachePath(folderName: folderName) {
            self.cache = try? DiskCache(storageType: .temporary(nil))
        }
    }
}

extension CachingService: FileCachingServiceProtocol {
    func getFileContent(with key: String) async -> (fileContent: String, byteSize: Int)? {
        if let data = try? await cache?.data(key) {
            if let fileContent = String(data: data, encoding: .utf8) {
                Log.itr.debug("Retrieving cached file content for key: \(key)")
                return (fileContent, data.count)
            } else {
                Log.itr.error("Failed to decode String from data")
                return nil
            }
        }
        Log.itr.debug("No cached file content for key: \(key)")
        return nil
    }
    
    func saveFileContent(for key: String, fileContent: String) {
        Task {
            if let data = fileContent.data(using: .utf8) {
                try? await cache?.cache(data, key: key)
                Log.itr.debug("Saved cached file content for key: \(key)")
            } else {
                Log.itr.error("Error encoding String for caching")
            }
        }
    }
    
    func clearCache(for key: String) {
        Task {
            try? await cache?.delete(key)
            Log.itr.debug("Cleared cached file content for key: \(key)")
        }
    }
    
    func clearAllCache() {
        Task {
            Log.itr.debug("Cleared file content cache")
            try? await cache?.deleteAll()
        }
    }
    
    private func cachePath(folderName: String) -> String? {
        let fileManager = FileManager.default
        guard let cacheDirectoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        let folderURL = cacheDirectoryURL.appendingPathComponent(folderName).appendingPathComponent("default")
        return folderURL.path()
    }
}

extension CachingService: ScrollCachingServiceProtocol {
    func getScrollPosition(for key: String) async -> CGFloat? {
        if let data = try? await cache?.data(key) {
            if let restoredValue = data.withUnsafeBytes({ (pointer: UnsafeRawBufferPointer) -> CGFloat? in
                pointer.bindMemory(to: CGFloat.self).baseAddress?.pointee
            }) {
                return restoredValue
            }
        }
        Log.itr.debug("No cached scroll position for key: \(key)")
        return nil
    }
    
    func saveScrollPosition(with key: String, position: CGFloat) {
        Task {
            let data = withUnsafeBytes(of: position) { Data($0) }
            try? await cache?.cache(data, key: key)
            Log.itr.debug("Saved cached scroll position for key: \(key)")
        }
    }
}

extension CachingService: SelectionCachingServiceProtocol {
    func getSelectionContent(for key: String) async -> Set<Int>? {
        if let data = try? await cache?.data(key) {
            if let codeRowSelections = try? JSONDecoder().decode(Set<Int>.self, from: data) {
                Log.itr.debug("Retrieving cached highlighted rows for key: \(key)")
                return codeRowSelections
            } else {
                Log.itr.error("Failed to decode rows json from data")
                return nil
            }
        }
        Log.itr.debug("No cached highlighted rows for key: \(key)")
        return nil
    }
    
    func saveSelectionContent(with key: String, rows: Set<Int>) {
        Task {
            if let data = try? JSONEncoder().encode(rows) {
                try? await cache?.cache(data, key: key)
                Log.itr.debug("Saved highlighted rows content for key: \(key)")
            } else {
                Log.itr.error("Error encoding String for caching")
            }
        }
    }
}
