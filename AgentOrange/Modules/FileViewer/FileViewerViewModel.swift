//
//  FileViewerViewModel.swift
//  LLMJsonTestHarness
//
//  Created by Paul Leo on 03/12/2024.
//

import SwiftUI
import Factory
import Combine

@Observable
final class FileViewerViewModel {
    @Injected(\.codeService) @ObservationIgnored private var codeService
    var rows: [AttributedString] = []
    @ObservationIgnored private var cancellable: AnyCancellable?
    
    init(rows: [AttributedString] = []) {
        self.rows = rows
        cancellable = codeService.codePublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
                print("codePublisher receiveCompletion")
            }, receiveValue: { [weak self] code in
                print("codePublisher receiveValue \(code ?? "")")
                if code != nil {
                    self?.rows = self?.codeService.codeRows ?? []
                }
            })
    }
    
    func displayCode(code: String) {
        codeService.code = code
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
                print(fileContent)
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // Handle cancellation if needed
        }
    }
}
