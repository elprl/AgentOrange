//
//  ClaudeAPIModels.swift
//  TDCodeReview
//
//  Created by Paul Leo on 08/11/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Foundation
import SwiftAnthropic

enum ClaudeRole: String, Codable {
    case user, assistant
}

enum ClaudeModel {
    case claudeInstant(model: String, tokens: Int)
    case claude(model: String, tokens: Int)
    case custom(model: String, tokens: Int)
}
 
extension ClaudeModel: Hashable, Identifiable, Codable {
    static var `default`: ClaudeModel {
        return .claude(model: "claude-3-5-sonnet-latest", tokens: 200000)
    }

    static var allCases: [ClaudeModel] {
        return [
            .custom(model: "CUSTOM", tokens: 200000),
            .claude(model: "claude-3-5-sonnet-latest", tokens: 200000),
            .claude(model: "claude-3-5-haiku-latest", tokens: 200000),
            .claude(model: "claude-3-5-opus-latest", tokens: 200000),
            .claude(model: "claude-3-sonnet-20240229", tokens: 200000),
            .claude(model: "claude-3-haiku-20240307", tokens: 200000),
            .claude(model: "claude-3-opus-20240229", tokens: 200000),
            .claude(model: "claude-2.1", tokens: 200000),
            .claude(model: "claude-2.0", tokens: 100000),
            .claudeInstant(model: "claude-instant-1.2", tokens: 100000)
        ]
    }
    
    var id: String {
        switch self {
        case .claudeInstant(let model, _), .claude(let model, _), .custom(let model, _):
            return model
        }
    }
    
    static func fromUserDefaults(key: String = UserDefaults.Keys.claudeModel) -> ClaudeModel {
        // Retrieve the model string from UserDefaults
        guard let modelString = UserDefaults.standard.string(forKey: key) else {
            return ClaudeModel.default
        }
        
        // Iterate through all cases to find a match
        for caseItem in allCases {
            switch caseItem {
            case .claudeInstant(let model, _), .claude(let model, _), .custom(let model, _):
                if model == modelString {
                    return caseItem
                }
            }
        }
        
        // If no match is found, return a custom model with the retrieved string
        return .custom(model: modelString, tokens: 100000)
    }
    
    var maxTokens: Int {
        switch self {
        case .claudeInstant(_, let tokens), .claude(_, let tokens), .custom(_, let tokens):
            return tokens
        }
    }
}

extension SwiftAnthropic.APIError: @retroactive LocalizedError, @retroactive CustomStringConvertible {
    public var description: String {
        return displayDescription
    }
    
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        return displayDescription
    }
}
