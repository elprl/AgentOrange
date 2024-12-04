//
//  FileViewerViewModel.swift
//  AgentOrange
//
//  Created by Paul Leo on 03/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import SwiftUI
import Factory
import Combine

@Observable
final class FileViewerViewModel {
    @Injected(\.codeService) @ObservationIgnored private var codeService
    var versions: [CodeVersion] = []
    var selectedId: String?
    @ObservationIgnored private var cancellable: AnyCancellable?
    @ObservationIgnored private var selectorCancellable: AnyCancellable?
    
    init() {
        cancellable = codeService.codePublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
                print("codePublisher receiveCompletion")
            }, receiveValue: { [weak self] code in
                print("codePublisher receiveValue \(code.count)")
                guard let self = self else { return }
                self.selectedId = code.last?.id
                self.versions = code
            })
        
        selectorCancellable = codeService.selectorPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
                print("selectorPublisher receiveCompletion")
            }, receiveValue: { [weak self] selectedId in
                print("selectorPublisher receiveValue \(selectedId ?? "")")
                guard let self = self else { return }
                self.selectedId = selectedId
            })
    }
    
    func addCode(code: String, tag: String) {
        codeService.addCode(code: code, tag: tag)
    }
    
    var currentRows: [AttributedString] {
        guard let version = versions.first(where: { $0.id == selectedId }) else { return [] }
        return version.rows
    }
}
