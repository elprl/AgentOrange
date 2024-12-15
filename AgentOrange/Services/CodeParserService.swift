//
//  CodeService.swift
//  AgentOrange
//
//  Created by Paul Leo on 03/12/2024.
//

import Foundation
import Splash

protocol CodeParserServiceProtocol {
    var cachedCode: String? { get }
    var paintedRows: [AttributedString] { get }
    var scopedCodeFiles: [CodeSnippetSendable] { get set }
    var publisher: Published<[CodeSnippetSendable]>.Publisher { get }

    func cacheCode(code: String)
    func getHighlighted(code: String) -> NSAttributedString
    func splitAttributedStringByNewlines(input: NSAttributedString) -> [AttributedString]
}

class CodeParserService: CodeParserServiceProtocol, ObservableObject {
    @Published var cachedCode: String?
    @Published var paintedRows: [AttributedString] = []
    @Published var scopedCodeFiles: [CodeSnippetSendable] = []
    var publisher: Published<[CodeSnippetSendable]>.Publisher { $scopedCodeFiles }
    
    func cacheCode(code: String) {
        if code.isEmpty { return }
        self.cachedCode = code
        let attString = getHighlighted(code: code)
        let attStrings: [AttributedString] = splitAttributedStringByNewlines(input: attString)
        self.paintedRows = attStrings
    }
    
    func getHighlighted(code: String) -> NSAttributedString {
        let highlighter = SyntaxHighlighter(format: AttributedStringOutputFormat(theme: .midnight(withFont: Splash.Font(size: 16))))
        let attString = highlighter.highlight(code)
        return attString
    }
    
    func splitAttributedStringByNewlines(input: NSAttributedString) -> [AttributedString] {
        let plainString = input.string
        let stringComponents = plainString.components(separatedBy: "\n")
        var attributedComponents: [AttributedString] = []
        var currentLocation = 0
        for component in stringComponents {
            let range = NSRange(location: currentLocation, length: component.count)
            let attributedSubstring = input.attributedSubstring(from: range)
            attributedComponents.append(AttributedString(attributedSubstring))
            currentLocation += component.count + 1 // Add 1 for the newline character
        }
        return attributedComponents
    }
}
