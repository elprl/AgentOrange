//
//  FileViewerViewModel.swift
//  LLMJsonTestHarness
//
//  Created by Paul Leo on 03/12/2024.
//

import SwiftUI
import Factory
import Combine

struct CodeVersions: Identifiable, Hashable {
    let version: Int
    let code: String
    let rows: [AttributedString]
    var id: Int { version }
    
    var versionString: String {
        if version == 0 {
            return "Original"
        }
        return "Version \(version)"
    }
}


@Observable
final class FileViewerViewModel {
    @Injected(\.codeService) @ObservationIgnored private var codeService
    var rows: [AttributedString] = []
    var versions: [CodeVersions] = []
    var selectedVersion: Int = 0
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
                guard let self = self else { return }
                if let code {
                    let rows = self.codeService.codeRows
                    let newVersion = self.versions.count
                    self.versions.append(CodeVersions(version: newVersion, code: code, rows: rows))
                }
            })
    }
    
    func displayCode(code: String) {
        codeService.code = code
    }
    
    var currentRows: [AttributedString] {
        guard let version = versions.first(where: { $0.version == selectedVersion }) else { return [] }
        return version.rows
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
