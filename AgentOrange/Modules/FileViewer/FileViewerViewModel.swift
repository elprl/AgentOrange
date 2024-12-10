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
    @ObservationIgnored private var cancellable: AnyCancellable?
    @ObservationIgnored private var selectorCancellable: AnyCancellable?
    @ObservationIgnored private let modelContext: ModelContext

    /// pass nil for previews or unit testing
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.dataService = Container.shared.dataService(modelContext.container) // Injected PersistentDataManager(container: modelContext.container)
    }
    
    @MainActor
    func addCodeSnippet(code: String, tag: String) {
        Task { @MainActor [weak self] in
            guard let groupId = self?.selectedGroupId else { return }
            let snippet = CodeSnippetSendable(title: tag, code: code, subTitle: "Original", groupId: groupId)
            await self?.dataService.add(code: snippet)
            self?.selectTab(snippet: snippet)
        }
    }
    
    var currentRows: [AttributedString] {
        return parserService.paintedRows
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
    
    func didSelectCode(id: String?) {

    }
}

#if DEBUG

extension FileViewerViewModel {
    @MainActor static func mock() -> FileViewerViewModel {
        let vm = FileViewerViewModel(modelContext: PreviewController.codeSnippetPreviewContainer.mainContext)

        return vm
    }
}

#endif


