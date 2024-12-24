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
    
    init(id: String = UUID().uuidString, timestamp: Date = Date.now, title: String) {
        self.groupId = id
        self.timestamp = timestamp
        self.title = title
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
    var codeId: String?
    var groupId: String
    var model: String?
    var host: String?
    
    init(messageId: String = UUID().uuidString, timestamp: Date = Date.now, role: GPTRole = .user, type: MessageType = .message, content: String, tag: String? = nil, codeId: String? = nil, groupId: String, model: String? = nil, host: String? = nil) {
        self.messageId = messageId
        self.timestamp = timestamp
        self.role = role
        self.type = type
        self.content = content
        self.tag = tag
        self.codeId = codeId
        self.groupId = groupId
        self.model = model
        self.host = host
    }
}

extension CDChatMessage: PersistentModelProtocol {
    var sendableModel: ChatMessage {
        return ChatMessage(id: messageId, timestamp: timestamp, role: role, type: type, content: content, tag: tag, codeId: codeId, groupId: groupId, model: model, host: host)
    }
}

@Model
final class CDChatCommand {
    @Attribute(.unique) var name: String
    var timestamp: Date
    var prompt: String
    var shortDescription: String
    
    var role: String?
    var model: String?
    var host: String?
    var type: AgentType?
    var inputCodeId: String?
    var dependencyIds: [String]?
    // @Relationship(deleteRule: .nullify, inverse: \CDWorkflow.commands) var workflows: [CDWorkflow]? // unordered set under the hood
    
    init(name: String, timestamp: Date = Date.now, prompt: String, shortDescription: String, role: String? = nil, model: String? = nil, host: String? = nil, type: AgentType? = .coder, inputCodeId: String? = nil, dependencyIds: [String]? = nil) {
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
    }
}

extension CDChatCommand: PersistentModelProtocol {
    var sendableModel: ChatCommand {
        return ChatCommand(name: name, timestamp: timestamp, prompt: prompt, shortDescription: shortDescription, role: role, model: model, host: host, type: type, inputCodeId: inputCodeId, dependencyIds: dependencyIds)
    }
}

@Model
final class CDWorkflow {
    @Attribute(.unique) var name: String
    var timestamp: Date
    var shortDescription: String
    // @Relationship var commands: [CDChatCommand]? // unordered set under the hood
    var commandIds: String? // Comma separated list of command names because SwiftData relationships don't support ordered arrays
    
    init(name: String, timestamp: Date = Date.now, shortDescription: String, commandIds: String? = nil) {
        self.name = name
        self.timestamp = timestamp
        self.shortDescription = shortDescription
        self.commandIds = commandIds
    }
}

extension CDWorkflow: PersistentModelProtocol {
    var sendableModel: Workflow {
        return Workflow(name: name, timestamp: timestamp, shortDescription: shortDescription, commandIds: commandIds)
    }
}

@Model
final class CDCodeSnippet {
    @Attribute(.unique) var codeId: String
    var timestamp: Date
    var title: String
    var subTitle: String?
    var code: String
    var messageId: String?
    var isVisible: Bool
    var groupId: String

    init(codeId: String = UUID().uuidString, timestamp: Date = Date.now, title: String, code: String, messageId: String? = nil, subTitle: String? = nil, isVisible: Bool = true, groupId: String) {
        self.codeId = codeId
        self.timestamp = timestamp
        self.title = title
        self.code = code
        self.messageId = messageId
        self.subTitle = subTitle
        self.isVisible = isVisible
        self.groupId = groupId
    }
}

extension CDCodeSnippet: PersistentModelProtocol {
    var sendableModel: CodeSnippetSendable {
        return CodeSnippetSendable(codeId: codeId, timestamp: timestamp, title: title, code: code, messageId: messageId, subTitle: subTitle, isVisible: isVisible, groupId: groupId)
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
                let group = CDChatMessage(messageId: "\(i)", content: "Message \(i)", groupId: "1")
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
            
            for i in 1..<10 {
                let group = CDCodeSnippet(codeId: "\(i)", title: "Message \(i)", code: "Code \(i)", groupId: "1")
                container.mainContext.insert(group)
            }
            try? container.mainContext.save()
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
    
    static let commandsPreviewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: CDChatCommand.self, configurations: config)
            
            for i in 1..<10 {
                let group = CDChatCommand(name: "Command \(i)", prompt: "Prompt \(i)", shortDescription: "Description \(i)")
                container.mainContext.insert(group)
            }
            try? container.mainContext.save()
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
    
    static let workflowsPreviewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: CDWorkflow.self, configurations: config)
            
            for i in 1..<10 {
                let group = CDWorkflow(name: "Workflow \(i)", shortDescription: "Description \(i)", commandIds: "Command \(i)")
                container.mainContext.insert(group)
            }
            try? container.mainContext.save()
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
}
