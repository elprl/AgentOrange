//
//  CodeService.swift
//  AgentOrange
//
//  Created by Paul Leo on 03/12/2024.
//
import Foundation
import Splash

protocol CodeServiceProtocol {
    var codeVersions: [CodeVersion] { get set }
    var selectedId: String? { get set }
    var codePublisher: Published<[CodeVersion]>.Publisher { get }
    var selectorPublisher: Published<String?>.Publisher { get }
    
    @discardableResult func addCode(code: String, tag: String) -> String?
    func getHighlighted(code: String) -> NSAttributedString
    func splitAttributedStringByNewlines(input: NSAttributedString) -> [AttributedString]
}

final class CodeService: CodeServiceProtocol, ObservableObject {
    @Published var codeVersions: [CodeVersion] = []
    @Published var selectedId: String?
    var codePublisher: Published<[CodeVersion]>.Publisher { $codeVersions }
    var selectorPublisher: Published<String?>.Publisher { $selectedId }

    @discardableResult func addCode(code: String, tag: String) -> String? {
        if code.isEmpty { return nil }
        let attString = getHighlighted(code: code)        
        let attStrings: [AttributedString] = self.splitAttributedStringByNewlines(input: attString)
        let newCodeVersion = CodeVersion(code: code, rows: attStrings, tag: tag)
        self.codeVersions.append(newCodeVersion)
        return newCodeVersion.id
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
