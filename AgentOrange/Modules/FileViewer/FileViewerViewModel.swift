//
//  FileViewerViewModel.swift
//  LLMJsonTestHarness
//
//  Created by Paul Leo on 03/12/2024.
//

import SwiftUI
import Factory

@Observable
final class FileViewerViewModel {
    @Injected(\.codeService) @ObservationIgnored private var codeService
    var rows: [AttributedString] = []
    
    init(code: String? = nil) {
        if let code {
            parseCode(code: code)
        }
    }
    
    func parseCode(code: String) {
        codeService.parseCode(code: code)
        rows = codeService.codeRows
    }
    
}

struct DocumentPickerView: UIViewControllerRepresentable {
    let action: (String) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.plainText])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator() { fileContent in
            action(fileContent)
        }
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let action: (String) -> Void

        init(action: @escaping (String) -> Void) {
            self.action = action
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            do {
                let fileContent = try String(contentsOf: url, encoding: .utf8)
                action(fileContent)
            } catch {
                let fileContent = "Error reading file: \(error.localizedDescription)"
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // Handle cancellation if needed
        }
    }
}
