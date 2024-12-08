//
//  DataModels.swift
//  AgentOrange
//
//  Created by Paul Leo on 08/12/2024.
//


import Foundation
import SwiftData

@Model
final class CDMessageGroup {
    @Attribute(.unique) var groupId: String
    var timestamp: Date
    var title: String
    
    @Relationship(deleteRule: .cascade, inverse: \CDChatMessage.group)
    var messages: [CDChatMessage]
    
    init(id: String = UUID().uuidString, timestamp: Date = Date.now, title: String, messages: [CDChatMessage] = []) {
        self.groupId = id
        self.timestamp = timestamp
        self.title = title
        self.messages = messages
    }
}

extension CDMessageGroup: PersistentModelProtocol {
    var sendableModel: MessageGroupSendable {
        return MessageGroupSendable(id: groupId, timestamp: timestamp, title: title)
    }
}

@Model
final class CDChatMessage {
    @Attribute(.unique) var messageId: String
    var timestamp: Date
    var role: GPTRole
    var type: MessageType
    var content: String
    var tag: String?
    var code: CDCodeSnippet?
    var group: CDMessageGroup?
    
    init(messageId: String = UUID().uuidString, timestamp: Date = Date.now, role: GPTRole = .user, type: MessageType = .message, content: String, tag: String? = nil, code: CDCodeSnippet? = nil) {
        self.messageId = messageId
        self.timestamp = timestamp
        self.role = role
        self.type = type
        self.content = content
        self.tag = tag
        self.code = code
    }
}

extension CDChatMessage: PersistentModelProtocol {
    var sendableModel: ChatMessage {
        return ChatMessage(id: messageId, timestamp: timestamp, role: role, type: type, content: content, tag: tag, codeId: code?.codeId)
    }
}

@Model
final class CDCodeSnippet {
    @Attribute(.unique) var codeId: String
    var timestamp: Date
    var title: String
    var code: String
    var message: CDChatMessage?
    
    init(codeId: String = UUID().uuidString, timestamp: Date = Date.now, title: String, code: String) {
        self.codeId = codeId
        self.timestamp = timestamp
        self.title = title
        self.code = code
    }
}

extension CDCodeSnippet: PersistentModelProtocol {
    var sendableModel: CodeSnippetSendable {
        return CodeSnippetSendable(codeId: codeId, timestamp: timestamp, title: title, code: code)
    }
}

@MainActor
class PreviewController {
    static let messageGroupPreviewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: CDMessageGroup.self, configurations: config)
            
            for i in 1..<100 {
                let group = CDMessageGroup(id: "\(i)", title: "Group \(i)")
                container.mainContext.insert(group)
            }
            try? container.mainContext.save()
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
    
    static let chatsPreviewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: CDChatMessage.self, configurations: config)
            
            for i in 1..<100 {
                let group = CDChatMessage(messageId: "\(i)", content: "Message \(i)")
                container.mainContext.insert(group)
            }
            try? container.mainContext.save()
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
    
    static let codeSnippetPreviewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: CDCodeSnippet.self, configurations: config)
            
            for i in 1..<100 {
                let group = CDCodeSnippet(codeId: "\(i)", title: "Message \(i)", code: "Code \(i)")
                container.mainContext.insert(group)
            }
            try? container.mainContext.save()
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
}
