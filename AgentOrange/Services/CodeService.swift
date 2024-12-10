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

    func cacheCode(code: String)
    func getHighlighted(code: String) -> NSAttributedString
    func splitAttributedStringByNewlines(input: NSAttributedString) -> [AttributedString]
}

final class CodeService: CodeParserServiceProtocol, ObservableObject {
    @Published var cachedCode: String?
    @Published var paintedRows: [AttributedString] = []

    func cacheCode(code: String) {
        if code.isEmpty { return }
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
