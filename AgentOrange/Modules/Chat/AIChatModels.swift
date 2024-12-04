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
    let id = UUID()
    let timestamp = Date.now
    let role: Role
    var type: MessageType = .message
    var content: String
    var tag: String? = nil
    var codeId: String? = nil
}
