//
//  DocumentPickerView.swift
//  AgentOrange
//
//  Created by Paul Leo on 04/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import SwiftUI

struct DocumentPickerView: UIViewControllerRepresentable {
    let action: (String, String) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.plainText])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator() { filename, content in
            action(filename, content)
        }
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let action: (String, String) -> Void

        init(action: @escaping (String, String) -> Void) {
            self.action = action
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            do {
                let filename = url.lastPathComponent
                let fileContent = try String(contentsOf: url, encoding: .utf8)
                action(filename, fileContent)
            } catch {
                let fileContent = "Error reading file: \(error.localizedDescription)"
                print(fileContent)
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // Handle cancellation if needed
        }
    }
}
