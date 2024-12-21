//
//  AIChatModels.swift
//  AgentOrange
//
//  Created by Paul Leo on 03/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import Foundation

enum MessageType: String, Codable {
    case message
    case command
    case file
}

struct ChatMessage: Identifiable, Hashable {
    var id = UUID().uuidString
    var timestamp = Date.now
    var role: GPTRole
    var type: MessageType = .message
    var content: String
    var tag: String? = nil
    var codeId: String? = nil
    var groupId: String
    var model: String?
    var host: String?
}

extension ChatMessage: SendableModelProtocol {
    var persistentModel: CDChatMessage {
        return CDChatMessage(messageId: id, timestamp: timestamp, role: role, type: type, content: content, tag: tag, codeId: codeId, groupId: groupId, model: model, host: host)
    }
}

enum Scope: String {
    case role
    case history
    case code
    case genCode
}

struct ChatCommand {
    var name: String
    var timestamp = Date.now
    var prompt: String
    var shortDescription: String
    
    var role: String?
    var model: String?
    var host: String?
    var type: AgentType?
    var inputCodeId: String?
    var dependencyIds: [String]?
}

extension ChatCommand: Identifiable, Hashable {
    var id: String { name }
    
    static func blank() -> ChatCommand {
        ChatCommand(name: "", prompt: "", shortDescription: "")
    }
}

extension ChatCommand: SendableModelProtocol {
    var persistentModel: CDChatCommand {
        return CDChatCommand(name: name, timestamp: timestamp, prompt: prompt, shortDescription: shortDescription, role: role, model: model, host: host, type: type, inputCodeId: inputCodeId, dependencyIds: dependencyIds)
    }
}

enum AgentType: String, Codable {
    case coder
    case reviewer
}

#if DEBUG

extension ChatCommand {
    static func mock() -> ChatCommand {
        ChatCommand(name: "//correctness",
                    prompt: "Check the code carefully for correctness and security. Give helpful and constructive criticism for how to improve it.",
                    shortDescription: "Refactors the code",
                    role: "You are an expert reviewer of Swift 6 code.",
                    model: "meta-llama-3.1-8b-instruct",
                    host: "http://192.168.50.3:1234",
                    type: .reviewer)
    }
}

#endif
