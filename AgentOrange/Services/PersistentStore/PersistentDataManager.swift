//
//  ChatMessagesDataService.swift
//  AgentOrange
//
//  Created by Paul Leo on 08/12/2024.
//

import SwiftData
import SwiftUI

protocol PersistentGroupDataManagerProtocol: Actor {
    func add(group: MessageGroupSendable) async
    func delete(group: MessageGroupSendable) async
}

protocol PersistentChatDataManagerProtocol: Actor {
    func add(message: ChatMessage) async
    func delete(messages: [ChatMessage]) async
    func delete(message: ChatMessage) async
    func fetchData(for groupId: String) async -> [ChatMessage]
    func fetchMessages(with messageIds: [String]) async -> [ChatMessage]
    func fetchMessage(with messageId: String) async -> ChatMessage?
}

protocol PersistentCodeDataManagerProtocol: Actor {
    func add(code: CodeSnippetSendable) async
    func delete(code: CodeSnippetSendable) async
    func fetchData(for groupId: String) async -> [CodeSnippetSendable]
    func fetchSnippet(for codeId: String) async -> CodeSnippetSendable?
}

protocol PersistentCommandDataManagerProtocol: Actor {
    func add(command: ChatCommand) async
    func delete(command: ChatCommand) async
    func fetchAllCommands() async -> [ChatCommand]
    func fetchCommand(for name: String) async -> ChatCommand?
}

protocol PersistentWorkflowDataManagerProtocol: Actor {
    func add(workflow: Workflow) async
    func delete(workflow: Workflow) async
    func fetchAllWorkflows() async -> [Workflow]
    func fetchWorkflow(for name: String) async -> Workflow?
}

protocol PersistentDataManagerProtocol: PersistentGroupDataManagerProtocol,
                                        PersistentChatDataManagerProtocol,
                                        PersistentCodeDataManagerProtocol,
                                        PersistentCommandDataManagerProtocol,
                                        PersistentWorkflowDataManagerProtocol {}

actor PersistentDataManager: PersistentDataManagerProtocol {
    let chatDataService: DataService<CDChatMessage, ChatMessage>
    let messageGroupDataService: DataService<CDMessageGroup, MessageGroupSendable>
    let codeSnippetDataService: DataService<CDCodeSnippet, CodeSnippetSendable>
    let commandDataService: DataService<CDChatCommand, ChatCommand>
    let workflowDataService: DataService<CDWorkflow, Workflow>
    
    /// pass nil for previews or unit testing
    init(container: ModelContainer) {
        chatDataService = DataService(modelContainer: container)
        messageGroupDataService = DataService(modelContainer: container)
        codeSnippetDataService = DataService(modelContainer: container)
        commandDataService = DataService(modelContainer: container)
        workflowDataService = DataService(modelContainer: container)
    }
}

// MARK: - ChatMessage
extension PersistentDataManager: PersistentChatDataManagerProtocol {
    
    func add(message: ChatMessage) async {
        await self.chatDataService.insert(data: message)
    }
    
    func delete(messages: [ChatMessage]) async {
        do {
            for message in messages {
                let id = message.id
                try await self.chatDataService.remove(predicate: #Predicate<CDChatMessage> { $0.messageId == id } )
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func delete(message: ChatMessage) async {
        do {
            let id: String = message.id
            try await self.chatDataService.remove(predicate: #Predicate<CDChatMessage> { $0.messageId == id } )
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchData(for groupId: String) async -> [ChatMessage] {
        if let items: [ChatMessage] = try? await self.chatDataService.fetchDataVMs(predicate: #Predicate<CDChatMessage> { $0.groupId == groupId }, sortBy: [SortDescriptor(\.timestamp)]) {
            return items
        }
        return []
    }
    
    func fetchMessage(with messageId: String) async -> ChatMessage? {
        if let items: [ChatMessage] = try? await self.chatDataService.fetchDataVMs(predicate: #Predicate<CDChatMessage> { $0.messageId == messageId }, sortBy: [SortDescriptor(\.timestamp)]) {
            return items.first
        }
        return nil
    }
    
    func fetchMessages(with messageIds: [String]) async -> [ChatMessage] {
        if let items: [ChatMessage] = try? await self.chatDataService.fetchDataVMs(predicate: #Predicate<CDChatMessage> { messageIds.contains($0.messageId) }, sortBy: [SortDescriptor(\.timestamp)]) {
            return items
        }
        return []
    }
}

// MARK: - Message Groups
extension PersistentDataManager: PersistentGroupDataManagerProtocol {
    func add(group: MessageGroupSendable) async {
        await self.messageGroupDataService.insert(data: group)
    }
    
    func delete(group: MessageGroupSendable) async {
        do {
            let id: String = group.groupId
            try await self.messageGroupDataService.remove(predicate: #Predicate<CDMessageGroup> { $0.groupId == id } )
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Code Snippets
extension PersistentDataManager: PersistentCodeDataManagerProtocol {
    func add(code: CodeSnippetSendable) async {
        await self.codeSnippetDataService.insert(data: code)
    }
    
    func delete(code: CodeSnippetSendable) async {
        do {
            let id: String = code.id
            try await self.codeSnippetDataService.remove(predicate: #Predicate<CDCodeSnippet> { $0.codeId == id } )
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchData(for groupId: String) async -> [CodeSnippetSendable] {
        if let items: [CodeSnippetSendable] = try? await self.codeSnippetDataService.fetchDataVMs(predicate: #Predicate<CDCodeSnippet> { $0.groupId == groupId }, sortBy: [SortDescriptor(\.timestamp)]) {
            return items
        }
        return []
    }
    
    func fetchSnippet(for codeId: String) async -> CodeSnippetSendable? {
        if let items: [CodeSnippetSendable] = try? await self.codeSnippetDataService.fetchDataVMs(predicate: #Predicate<CDCodeSnippet> { $0.codeId == codeId }, sortBy: [SortDescriptor(\.timestamp)]) {
            return items.first
        }
        return nil
    }
}

// MARK: - Command
extension PersistentDataManager: PersistentCommandDataManagerProtocol {
    func add(command: ChatCommand) async {
        await self.commandDataService.insert(data: command)
    }
    
    func delete(command: ChatCommand) async {
        do {
            let id: String = command.name
            try await self.commandDataService.remove(predicate: #Predicate<CDChatCommand> { $0.name == id } )
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchAllCommands() async -> [ChatCommand] {
        if let items: [ChatCommand] = try? await self.commandDataService.fetchDataVMs(predicate: nil, sortBy: [SortDescriptor(\.timestamp)]) {
            return items
        }
        return []
    }
    
    func fetchCommand(for name: String) async -> ChatCommand? {
        if let items: [ChatCommand] = try? await self.commandDataService.fetchDataVMs(predicate: #Predicate<CDChatCommand> { $0.name == name }, sortBy: [SortDescriptor(\.timestamp)]) {
            return items.first
        }
        return nil
    }
}

// MARK: - Workflow
extension PersistentDataManager: PersistentWorkflowDataManagerProtocol {
    func add(workflow: Workflow) async {
        Log.data.debug("Adding or updating Workflow: \(workflow.name)")
        await self.workflowDataService.insert(data: workflow)
    }
    
//    func update(workflow: Workflow) async {
//        Log.data.debug("Updating Workflow: \(workflow.name)")
//        do {
//        let existingWorkflow = try await self.workflowDataService.fetchData(predicate: #Predicate<CDWorkflow> { $0.name == workflow.name }, sortBy: [SortDescriptor(\.timestamp)])
//        if let existing = existingWorkflow.first {
//            existing.name = workflow.name
//            existing.timestamp = workflow.timestamp
//            existing.shortDescription = workflow.shortDescription
//            existing.commands = workflow.commands.map { $0.persistentModel }
//                try await self.workflowDataService.save()
//        }
//        } catch {
//            Log.data.error("Failed to update Workflow: \(workflow.name)")
//        }
//    }
    
    func delete(workflow: Workflow) async {
        do {
            let id: String = workflow.name
            try await self.workflowDataService.remove(predicate: #Predicate<CDWorkflow> { $0.name == id } )
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchAllWorkflows() async -> [Workflow] {
        if let items: [Workflow] = try? await self.workflowDataService.fetchDataVMs(predicate: nil, sortBy: [SortDescriptor(\.timestamp)]) {
            return items
        }
        return []
    }
    
    func fetchWorkflow(for name: String) async -> Workflow? {
        if let items: [Workflow] = try? await self.workflowDataService.fetchDataVMs(predicate: #Predicate<CDWorkflow> { $0.name == name }, sortBy: [SortDescriptor(\.timestamp)]) {
            return items.first
        }
        return nil
    }
}
