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
