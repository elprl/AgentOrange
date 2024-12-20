//
//  FileWatcherService.swift
//  AgentOrange
//
//  Created by Paul Leo on 01/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.
// 

import SwiftUI
import Combine

@available(*, deprecated, message: "Removed due to file system events not always firing")
final class FileWatcherService: ObservableObject {
    @Published var fileContent: String = ""
    
    private var fileHandle: FileHandle?
    private var source: DispatchSourceFileSystemObject?
    private var fileURL: URL
    
    init(fileURL: URL) {
        self.fileURL = fileURL
        startMonitoring()
        loadFileContent()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // Load the content of the file
    private func loadFileContent() {
        do {
            fileContent = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            fileContent = "Error reading FileWatcherService file: \(error.localizedDescription)"
        }
    }
    
    // Start monitoring the file for changes
    private func startMonitoring() {
        do {
            self.fileHandle = try FileHandle(forReadingFrom: fileURL)
            guard let fileDescriptor = fileHandle?.fileDescriptor else { return }
            source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .all, queue: DispatchQueue.main)
            
            source?.setEventHandler { [weak self] in
                if let event = self?.source?.data {
                    Log.itr.debug("FileWatcherService Event: \(event.rawValue)")
                }

                self?.loadFileContent()
            }
            
            source?.setCancelHandler { [weak self] in
                Log.itr.debug("FileWatcherService cancelled")
                try? self?.fileHandle?.close()
            }
            
            source?.activate()
        } catch {
            Log.itr.error("Error monitor FileWatcherService file: \(error.localizedDescription)")
        }
    }
    
    // Stop monitoring the file for changes
    private func stopMonitoring() {
        source?.cancel()
        source = nil
    }
}
