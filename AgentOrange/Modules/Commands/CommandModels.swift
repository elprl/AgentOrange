//
//  CommandModels.swift
//  AgentOrange
//
//  Created by Paul Leo on 29/12/2024.
//

import Foundation

struct ChatCommand {
    var name: String
    var timestamp = Date.now
    var prompt: String
    var shortDescription: String
    
    var role: String
    var model: String
    var host: String
    var temperature: Double
    var type: AgentType
    var inputCodeId: String?
    var dependencyIds: [String]
    
    init(name: String,
         timestamp: Foundation.Date = Date.now,
         prompt: String,
         shortDescription: String,
         role: String = UserDefaults.standard.agiRole ?? "You are a helpful AI assistant.",
         model: String = UserDefaults.standard.agiModel ?? "qwen2.5-coder-32b-instruct",
         host: String = UserDefaults.standard.customAIHost ?? "http://localhost:1234",
         temperature: Double = 0.5,
         type: AgentType = .reviewer,
         inputCodeId: String? = nil,
         dependencyIds: [String] = []) {
        self.name = name
        self.timestamp = timestamp
        self.prompt = prompt
        self.shortDescription = shortDescription
        self.role = role
        self.model = model
        self.host = host
        self.type = type
        self.inputCodeId = inputCodeId
        self.dependencyIds = dependencyIds
        self.temperature = temperature
    }
}

extension ChatCommand: Identifiable, Hashable {
    var id: String { name }
    
    static func blank() -> ChatCommand {
        ChatCommand(name: "", prompt: "", shortDescription: "")
    }
}

extension ChatCommand: SendableModelProtocol {
    var persistentModel: CDChatCommand {
        return CDChatCommand(name: name, timestamp: timestamp, prompt: prompt, shortDescription: shortDescription, role: role, model: model, host: host, temperature: temperature, type: type, inputCodeId: inputCodeId, dependencyIds: dependencyIds)
    }
}

enum AgentType: String, Codable {
    case coder
    case reviewer
}

#if DEBUG

extension ChatCommand {
    static func mock() -> ChatCommand {
        ChatCommand(name: String(UUID().uuidString.prefix(9)),
                    prompt: "Check the code carefully for correctness and security. Give helpful and constructive criticism for how to improve it.",
                    shortDescription: "Refactors the code",
                    role: "You are an expert reviewer of Swift 6 code.",
                    model: "meta-llama-3.1-8b-instruct",
                    host: "http://192.168.50.3:1234",
                    type: .reviewer)
    }
}

#endif
