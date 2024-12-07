//
//  AGIService.swift
//  TDCodeReview
//
//  Created by Paul Leo on 30/03/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Foundation
import Combine
import Factory
//import GPT3_Tokenizer
import SwiftUI

protocol TokenServiceProtocol {
    func resetAccessToken(apiKey: String?) async
    var hasSetToken: Bool { get async }
}

protocol AGIStreamingServiceProtocol {
    func sendMessageStream(text: String, needsJSONResponse: Bool) async throws -> AsyncThrowingStream<String, Error>
    func cancelStream() async
}

protocol AGIHistoryServiceProtocol {
    func setHistory(messages: [ChatMessage]) async
    func setupHistory(for fileContent: String, selectedRows: Set<Int>, scopes: HistoryOptions, messages: [ChatMessage], systemRole: String?) async
    func processSelection(for fileContent: String, selectedRows: Set<Int>) async -> GPTMessage
    func getHistory() async -> [GPTMessage]
    func addHistoryItem(message: ChatMessage) async
    func removeHistoryItem(message: ChatMessage) async
    func deleteHistoryList() async
    func appendToHistoryList(userText: String, responseText: String) async
}


//extension AGIServiceProtocol {
//    func numTokensFromMessages(messages: [ChatMessageVM]) -> Int {
//        let gpt3Tokenizer = GPT3Tokenizer()
//        var numTokens = 0
//        for message in messages {
//            numTokens += 3
//            let encoded = gpt3Tokenizer.encoder.enconde(text: message.decryptedContent ?? "")
//            numTokens += encoded.count
//        }
//        numTokens += 2
//        return numTokens
//    }
//}

enum TDAPIError: LocalizedError {
    case invalidJsonEncoding
    case invalidJsonDecoding
    case invalidResponse
    case badResponse(Int, String)
    case urlSessionError(String)
    case streamError(String)
    case invalidParams(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidJsonEncoding:
            return NSLocalizedString("Invalid JSON encoding.", comment: "")
        case .invalidJsonDecoding:
            return NSLocalizedString("Invalid JSON decoding.", comment: "")
        case .invalidResponse:
            return NSLocalizedString("Invalid response.", comment: "")
        case .badResponse(_, let message):
            return message
        case .urlSessionError(let description):
            return description
        case .streamError(let description):
            return description
        case .invalidParams(let description):
            return description
        }
    }
}

struct AGIServiceConstants {
    static let agiRole = "Play the role of a mentoring Senior Software Engineer who regularly performs Peer Code Reviews or Software Inspections."
    static let agiReviewQ = "Question: perform a detailed code review of the above code. A Peer Code Review should focus on what should be improved in the following categories: architecture, code, design, error handling, maintainability, performance, scalability, readability, security, testability (but not exclusively). Avoid a Static Analysis type of review. "
    static let agiOutput = "Your output must be in a JSON form ONLY with the following structure: "
    static let agiReflectionQ = "Did your answer meet the requirements of my question?"
    static let agiAbuseQ = "Determine whether the following chat message is abusive. Your output should ONLY be 'true' or 'false' and nothing else. "
    static let agiUnitTests = "Give me the unit tests for the previously given code."
    static let agiComments = "Provide professional code comments for the above code (including class headers, function descriptions and code comments)."
    static let agiRefactor = "Give me the refactored code for the previously given code."
    static let agiSummarise = "Summarise what the supplied code does."
    static let agiChainOfThought = "Answer: Let's work through the review step by step to be sure we have the right answer."
    static let jsonOutput = """
{
  "annotations": [
    {
      "tag": "Architecture/Patterns/Misuse",
      "line": "static let shared = MySingletonClass()",
      "lineNumber": 33,
      "issueDescription": "The Singleton pattern is being misused, causing unnecessary constraints on flexibility and testability. Consider refactoring the code to use dependency injection."
    },
    {
      "tag": "Architecture/ObjectOriented/Inheritance",
      "line": "final class Customer: Address {",
      "lineNumber": 42,
      "issueDescription": "Inappropriate use of inheritance. The 'Customer' class should not inherit from the 'Address' class. Instead, consider using composition to model the relationship between these two classes."
    }
  ]
}
"""
}



enum AGIServiceChoice: String {
    case openai = "0"
    case gemini = "1"
    case claude = "2"
    case customAI = "3"
    case none = "-1"
    
    var defaultModel: String {
        switch self {
        case .openai:
            return UserDefaults.standard.openAiModel ?? "gpt-3.5-turbo"
        case .gemini:
            return UserDefaults.standard.geminiModel ?? "gemini-1.5-pro"
        case .claude:
            return UserDefaults.standard.claudeModel ?? "claude-3-5-sonnet-20241022"
        case .customAI:
            return UserDefaults.standard.customAIModel ?? "Qwen2.5-Coder-32B-Instruct-GGUF"
        default:
            return "Not set"
        }
    }
    
    var name: String {
        switch self {
        case .openai:
            return "ChatGPT"
        case .claude:
            return "Claude"
        case .gemini:
            return "Gemini"
        case .customAI:
            return "Custom AI"
        default:
            return "Not set"
        }
    }
    
    var imageKey: String {
        switch self {
        case .openai:
            return "openai-logomark"
        case .claude:
            return "claudeSpark"
        case .gemini:
            return "geminiIcon"
        case .customAI:
            return "custom_ai_icon"
        default:
            return "peerwalk_logo"
        }
    }
    
    var placeholder: String {
        switch self {
        case .openai, .claude, .gemini, .customAI:
            return NSLocalizedString("Ask \(self.name) or / for commands", comment: "")
        default:
            return NSLocalizedString("<- Select AI Service", comment: "")
        }
    }
}

enum AnnotationMode: String {
    case text = "0"
    case annotations = "1"
}
