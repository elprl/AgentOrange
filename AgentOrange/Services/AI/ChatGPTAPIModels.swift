//
//  ChatGPTAPIModels.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 03/03/23.
//

import Foundation

enum GPTRole: String, Codable {
    case user
    case system
    case assistant
}

struct GPTMessage: Codable, Identifiable {
    var id: String = UUID().uuidString
    let role: String
    var content: String
    
    private enum CodingKeys: CodingKey {
        case role
        case content
    }
}

enum GPTModel {
    case gpt4(model: String, tokens: Int)
    case gpt3(model: String, tokens: Int)
    case custom(model: String, tokens: Int)
}
 
extension GPTModel: Hashable, Identifiable, Codable {
    static var `default`: GPTModel {
        return .gpt4(model: "gpt-4o", tokens: 128000)
    }
    
    static var allCases: [GPTModel] {
        return [
            .custom(model: "CUSTOM", tokens: 128000),
            .gpt4(model: "o1-preview", tokens: 128000),
            .gpt4(model: "o1-mini", tokens: 128000),
            .gpt4(model: "gpt-4o-2024-05-13", tokens: 128000),
            .gpt4(model: "gpt-4o", tokens: 128000),
            .gpt4(model: "gpt-4-turbo", tokens: 128000),
            .gpt4(model: "gpt-4-turbo-2024-04-09", tokens: 128000),
            .gpt4(model: "gpt-4-turbo-preview", tokens: 128000),
            .gpt4(model: "gpt-4-0125-preview", tokens: 128000),
            .gpt4(model: "gpt-4-1106-preview", tokens: 128000),
            .gpt4(model: "gpt-4", tokens: 8192),
            .gpt4(model: "gpt-4-32k", tokens: 32768),
            .gpt3(model: "gpt-3.5-turbo-1106", tokens: 16385),
            .gpt3(model: "gpt-3.5-turbo", tokens: 4096),
            .gpt3(model: "gpt-3.5-turbo-16k", tokens: 16385)
        ]
    }
    
    var id: String {
        switch self {
        case .gpt4(let model, _), .gpt3(let model, _), .custom(let model, _):
            return model
        }
    }
    
    static func fromUserDefaults(key: String = UserDefaults.Keys.openAiModel) -> GPTModel {
        // Retrieve the model string from UserDefaults
        guard let modelString = UserDefaults.standard.string(forKey: key) else {
            return GPTModel.default
        }
        
        // Iterate through all cases to find a match
        for caseItem in allCases {
            switch caseItem {
            case .gpt4(let model, _), .gpt3(let model, _), .custom(let model, _):
                if model == modelString {
                    return caseItem
                }
            }
        }
        
        // If no match is found, return a custom model with the retrieved string
        return .custom(model: modelString, tokens: 8192)
    }
    
    var maxTokens: Int {
        switch self {
        case .gpt4(_, let tokens), .gpt3(_, let tokens), .custom(_, let tokens):
            return tokens
        }
    }
}

extension Array where Element == GPTMessage {
    var contentCount: Int { reduce(0, { $0 + $1.content.count })}
}

struct Request: Codable {
    let model: String
    let temperature: Double
    let messages: [GPTMessage]
    let stream: Bool
    let responseFormat: ResponseFormat?
    
    private enum CodingKeys: String, CodingKey {
        case model
        case temperature
        case messages
        case stream
        case responseFormat = "response_format"
    }
}

struct ResponseFormat: Codable {
    let type: String
}

struct ErrorRootResponse: Decodable {
    let error: ErrorResponse
}

struct ErrorResponse: Decodable {
    let message: String
    let type: String?
}

struct StreamCompletionResponse: Decodable {
    let choices: [StreamChoice]
}

struct CompletionResponse: Decodable {
    let choices: [Choice]
    let usage: Usage?
}

struct Usage: Decodable {
    let promptTokens: Int?
    let completionTokens: Int?
    let totalTokens: Int?
}

struct Choice: Decodable {
    let message: GPTMessage
    let finishReason: String?
}

struct StreamChoice: Decodable {
    let finishReason: String?
    let delta: StreamMessage
}

struct StreamMessage: Decodable {
    let role: String?
    let content: String?
}

struct HistoryOptions: OptionSet {
    let rawValue: Int
    
    static let none = HistoryOptions(rawValue: 1 << 0)
    static let role = HistoryOptions(rawValue: 1 << 1)
    static let selection = HistoryOptions(rawValue: 1 << 2)
    static let code = HistoryOptions(rawValue: 1 << 3)
    static let messages = HistoryOptions(rawValue: 1 << 4)
    static let all: HistoryOptions = [.role, .selection, .code, .messages] // Combines all options
    
    static func modeFrom(hasRole: Bool, hasCode: Bool, hasHistory: Bool, hasSelection: Bool) -> Self {
        var scopes: HistoryOptions = []
        if hasRole {
            scopes.insert(HistoryOptions.role)
        }
        if hasCode {
            scopes.insert(HistoryOptions.code)
        }
        if hasHistory {
            scopes.insert(HistoryOptions.messages)
        }
        if hasSelection {
            scopes.insert(HistoryOptions.selection)
        }
        return scopes
    }
}
