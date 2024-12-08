//
//  SendableModels.swift
//  AgentOrange
//
//  Created by Paul Leo on 08/12/2024.
//
import Foundation

struct MessageGroupSendable {
    let groupId: String
    let timestamp: Date
    let title: String
    
    init(id: String = UUID().uuidString, timestamp: Date = Date.now, title: String) {
        self.groupId = id
        self.timestamp = timestamp
        self.title = title
    }
}

extension MessageGroupSendable: SendableModelProtocol {
    var persistentModel: CDMessageGroup {
        return CDMessageGroup(id: groupId, timestamp: timestamp, title: title)
    }
}

struct CodeSnippetSendable {
    let codeId: String
    let timestamp: Date
    let title: String
    let code: String
    let messageId: String?
    
    init(codeId: String = UUID().uuidString, timestamp: Date = Date.now, title: String, code: String, messageId: String? = nil) {
        self.codeId = codeId
        self.timestamp = timestamp
        self.title = title
        self.code = code
        self.messageId = messageId
    }
}

extension CodeSnippetSendable: SendableModelProtocol {
    var persistentModel: CDCodeSnippet {
        return CDCodeSnippet(codeId: codeId, timestamp: timestamp, title: title, code: code)
    }
}
