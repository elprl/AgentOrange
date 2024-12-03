//
//  CodeService.swift
//  LLMJsonTestHarness
//
//  Created by Paul Leo on 03/12/2024.
//
import Foundation
import Splash

protocol CodeServiceProtocol {
    var code: String? { get set }
    var codePublisher: Published<String?>.Publisher { get }

    var paintedCode: AttributedString? { get }
    var codeRows: [AttributedString] { get }
    func parseCode()
    func getHighlighted(code: String) -> NSAttributedString
}

final class CodeService: CodeServiceProtocol, ObservableObject {
    @Published var code: String? {
        didSet { parseCode() }
    }
    @Published var paintedCode: AttributedString?
    @Published var codeRows: [AttributedString] = []
    var codePublisher: Published<String?>.Publisher { $code }

    func parseCode() {
        guard let code = self.code, !code.isEmpty else { return }
        
        let attString = getHighlighted(code: code)
        self.paintedCode = AttributedString(attString)
        
        let attStrings: [AttributedString] = self.splitAttributedStringByNewlines(input: attString)
        self.codeRows = attStrings
    }
    
    func getHighlighted(code: String) -> NSAttributedString {
        let highlighter = SyntaxHighlighter(format: AttributedStringOutputFormat(theme: .midnight(withFont: Splash.Font(size: 16))))
        let attString = highlighter.highlight(code)
        return attString
    }
    
    private func splitAttributedStringByNewlines(input: NSAttributedString) -> [AttributedString] {
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
