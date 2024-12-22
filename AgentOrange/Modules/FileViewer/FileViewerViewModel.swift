//
//  FileViewerViewModel.swift
//  AgentOrange
//
//  Created by Paul Leo on 03/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import SwiftUI
import Factory
import Combine
import SwiftData

@Observable
final class FileViewerViewModel {
    @Injected(\.parserService) @ObservationIgnored private var parserService
    /* @Injected(\.dataService) */ @ObservationIgnored private var dataService: PersistentCodeDataManagerProtocol
    var selectedGroupId: String?
    var selectedRows: [AttributedString] = []
    var selectedSnippet: CodeSnippetSendable?
    var scopedFiles: [CodeSnippetSendable] = []
    var document: TextFile?
    var defaultFilename: String?
    @ObservationIgnored private var pastedCodeCount: Int = 0
    @ObservationIgnored private var cancellable: AnyCancellable?
    @ObservationIgnored private var selectorCancellable: AnyCancellable?
    @ObservationIgnored private let modelContext: ModelContext

    /// pass nil for previews or unit testing
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.dataService = Container.shared.dataService(modelContext.container) // Injected PersistentDataManager(container: modelContext.container)
        cancellable = parserService.publisher
            .dropFirst()
            .sink { [weak self] scopedCodeFiles in
                self?.scopedFiles = scopedCodeFiles
            }
    }
    
    @MainActor
    func addPasted(code: String) {
        Task { @MainActor [weak self] in
            var formattedCode = code
            if !code.hasPrefix("```") {
                formattedCode = "```\n\(code)\n```"
            }
            guard let self = self, let groupId = self.selectedGroupId else { return }
            let tag = "Pasted Code \(self.pastedCodeCount + 1)"
            let snippet = CodeSnippetSendable(title: tag, code: formattedCode, subTitle: "Original", groupId: groupId)
            await self.dataService.add(code: snippet)
            self.selectTab(snippet: snippet)
            self.pastedCodeCount += 1
            self.addToScope(snippet: snippet)
        }
    }
    
    @MainActor
    func addCodeSnippet(url: URL) {
        Task { @MainActor [weak self] in
            let filename = url.lastPathComponent
            if let fileContent = try? String(contentsOf: url, encoding: .utf8) {
                guard let groupId = self?.selectedGroupId else { return }
                var snippetCode = fileContent
                let language = self?.language(from: filename) ?? "swift"
                if !fileContent.hasPrefix("```") {
                    snippetCode = "```\(language)\n\(fileContent)\n```"
                }
                let snippet = CodeSnippetSendable(title: filename, code: snippetCode, subTitle: "Original", groupId: groupId)
                await self?.dataService.add(code: snippet)
                self?.selectTab(snippet: snippet)
                self?.addToScope(snippet: snippet)
            }
        }
    }
    
    @MainActor
    func exportCode(snippet: CodeSnippetSendable) {
        self.document = TextFile(initialText: snippet.code)
        self.defaultFilename = snippet.title
    }
    
    // get the language from extension of the filename
    // TODO: use languages.json from Peerwalk
    private func language(from filename: String) -> String {
        let ext = URL(fileURLWithPath: filename).pathExtension
        switch ext {
        case "swift":
            return "swift"
        case "js":
            return "javascript"
        case "ts":
            return "typescript"
        case "md":
            return "markdown"
        case "kt":
            return "kotlin"
        default:
            return ext
        }
    }
    
    var currentRows: [AttributedString] {
        return parserService.paintedRows
    }
    
    var cachedCode: String {
        return parserService.cachedCode ?? ""
    }
    
    var currentTimestamp: String? {
        return selectedSnippet?.timestamp.formatted() ?? ""
    }
    
    func copyToClipboard() {
        UIPasteboard.general.string = parserService.cachedCode
    }
    
    func selectTab(snippet: CodeSnippetSendable) {
        parserService.cacheCode(code: snippet.code)
        selectedSnippet = snippet
        UserDefaults.standard.set(snippet.title, forKey: UserDefaults.Keys.selectedCodeTitle)
    }
    
    func addToScope(snippet: CodeSnippetSendable) {
        if !parserService.scopedCodeFiles.contains(snippet) {
            parserService.scopedCodeFiles.append(snippet)
        }
    }
    
    func removeFromScope(snippetId: String) {
        if let index = parserService.scopedCodeFiles.firstIndex(where: { $0.codeId == snippetId }) {
            parserService.scopedCodeFiles.remove(at: index)
        }
    }
    
    func isScoped(id: String) -> Bool {
        return scopedFiles.contains(where: { $0.codeId == id })
    }
    
    @MainActor
    func hide(snippet: CodeSnippetSendable) {
        Task { [weak self] in
            let newSnippet = CodeSnippetSendable(codeId: snippet.codeId,
                                                 timestamp: snippet.timestamp,
                                                 title: snippet.title,
                                                 code: snippet.code,
                                                 messageId: snippet.messageId,
                                                 subTitle: snippet.subTitle,
                                                 isVisible: false,
                                                 groupId: snippet.groupId)
            await self?.dataService.add(code: newSnippet)
        }
    }
    
    @MainActor
    func unhide(snippet: CodeSnippetSendable) {
        Task { [weak self] in
            let newSnippet = CodeSnippetSendable(codeId: snippet.codeId,
                                                 timestamp: snippet.timestamp,
                                                 title: snippet.title,
                                                 code: snippet.code,
                                                 messageId: snippet.messageId,
                                                 subTitle: snippet.subTitle,
                                                 isVisible: true,
                                                 groupId: snippet.groupId)
            await self?.dataService.add(code: newSnippet)
        }
    }
    
    @MainActor
    func didSelectCode(id: String?) {
        Task { [weak self] in
            guard let self, let id else { return }
            if let snippet = await self.dataService.fetchSnippet(for: id) {
                self.selectTab(snippet: snippet)
                if snippet.isVisible == false {
                    unhide(snippet: snippet)
                }
            }
        }
    }
}

#if DEBUG

extension FileViewerViewModel {
    @MainActor static func mock() -> FileViewerViewModel {
        let _ = Container.shared.parserService.register {
            let ps = CodeParserService()
            ps.cacheCode(code: "let x = 1")
            return ps
        }
        let vm = FileViewerViewModel(modelContext: PreviewController.codeSnippetPreviewContainer.mainContext)
        vm.selectedGroupId = "1"
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            
//            vm.addCodeSnippet(code: """
//        #if DEBUG
//
//        extension FileViewerViewModel {
//            @MainActor static func mock() -> FileViewerViewModel {
//                let _ = Container.shared.parserService.register {
//                    let ps = CodeParserService()
//                    ps.cacheCode(code: "let x = 1")
//                    return ps
//                }
//                let vm = FileViewerViewModel(modelContext: PreviewController.codeSnippetPreviewContainer.mainContext)                
//                return vm
//            }
//            
//            @MainActor static func emptyMock() -> FileViewerViewModel {
//                let vm = FileViewerViewModel(modelContext: PreviewController.codeSnippetPreviewContainer.mainContext)
//                return vm
//            }
//        }
//
//        #endif
//""", from: "PastedCode")
//        }
        
        return vm
    }
    
    @MainActor static func emptyMock() -> FileViewerViewModel {
        let vm = FileViewerViewModel(modelContext: PreviewController.codeSnippetPreviewContainer.mainContext)
        return vm
    }
}

#endif


