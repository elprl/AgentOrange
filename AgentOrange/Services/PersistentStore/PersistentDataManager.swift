//
//  ChatMessagesDataService.swift
//  AgentOrange
//
//  Created by Paul Leo on 08/12/2024.
//

import SwiftData
import SwiftUI

protocol PersistentGroupDataManagerProtocol: Actor {
    func add(group: MessageGroupSendable)
    func delete(group: MessageGroupSendable)
}

protocol PersistentChatDataManagerProtocol: Actor {
    func add(message: ChatMessage)
    func delete(messages: [ChatMessage])
    func delete(message: ChatMessage)
    func fetchData(for groupId: String) async -> [ChatMessage]
}

protocol PersistentCodeDataManagerProtocol: Actor {
    func add(code: CodeSnippetSendable)
    func delete(code: CodeSnippetSendable)
    func fetchData(for groupId: String) async -> [CodeSnippetSendable]
    func fetchSnippet(for codeId: String) async -> CodeSnippetSendable?
}

protocol PersistentCommandDataManagerProtocol: Actor {
    func add(command: ChatCommand)
    func delete(command: ChatCommand)
    func fetchAllCommands() async -> [ChatCommand]
    func fetchCommand(for name: String) async -> ChatCommand?
}

protocol PersistentWorkflowDataManagerProtocol: Actor {
    func add(workflow: Workflow)
    func delete(workflow: Workflow)
    func fetchAllWorkflows() async -> [Workflow]
    func fetchWorkflow(for name: String) async -> Workflow?
}

protocol PersistentDataManagerProtocol: PersistentGroupDataManagerProtocol,
                                        PersistentChatDataManagerProtocol,
                                        PersistentCodeDataManagerProtocol,
                                        PersistentCommandDataManagerProtocol,
                                        PersistentWorkflowDataManagerProtocol {}

actor PersistentDataManager: PersistentDataManagerProtocol {
    private let container: ModelContainer
    
    /// pass nil for previews or unit testing
    init(container: ModelContainer) {
        self.container = container
    }
}

// MARK: - ChatMessage
extension PersistentDataManager: PersistentChatDataManagerProtocol {
    
    func add(message: ChatMessage) {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let container = self?.container else { return }
            let dataService = DataService<CDChatMessage, ChatMessage>(modelContainer: container)
            await dataService.insert(data: message)
        }
    }
    
    func delete(messages: [ChatMessage]) {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let container = self?.container else { return }
            let dataService = DataService<CDChatMessage, ChatMessage>(modelContainer: container)
            do {
                for message in messages {
                    let id = message.id
                    try await dataService.remove(predicate: #Predicate<CDChatMessage> { $0.messageId == id } )
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func delete(message: ChatMessage) {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let container = self?.container else { return }
            let dataService = DataService<CDChatMessage, ChatMessage>(modelContainer: container)
            do {
                let id: String = message.id
                try await dataService.remove(predicate: #Predicate<CDChatMessage> { $0.messageId == id } )
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchData(for groupId: String) async -> [ChatMessage] {
        let vmItems: [ChatMessage] = await Task.detached(priority: .userInitiated) { [weak self] in
            guard let container = self?.container else { return [] }
            let dataService = DataService<CDChatMessage, ChatMessage>(modelContainer: container)
            if let items: [ChatMessage] = try? await dataService.fetchDataVMs(predicate: #Predicate<CDChatMessage> { $0.groupId == groupId }, sortBy: [SortDescriptor(\.timestamp)]) {
                return items
            }
            return []
        }.value
        return vmItems
    }
}

// MARK: - Message Groups
extension PersistentDataManager: PersistentGroupDataManagerProtocol {
    func add(group: MessageGroupSendable) {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let container = self?.container else { return }
            let dataService = DataService<CDMessageGroup, MessageGroupSendable>(modelContainer: container)
            await dataService.insert(data: group)
        }
    }
    
    func delete(group: MessageGroupSendable) {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let container = self?.container else { return }
            let dataService = DataService<CDMessageGroup, MessageGroupSendable>(modelContainer: container)
            do {
                let id: String = group.groupId
                try await dataService.remove(predicate: #Predicate<CDMessageGroup> { $0.groupId == id } )
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - Code Snippets
extension PersistentDataManager: PersistentCodeDataManagerProtocol {
    func add(code: CodeSnippetSendable) {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let container = self?.container else { return }
            let dataService = DataService<CDCodeSnippet, CodeSnippetSendable>(modelContainer: container)
            await dataService.insert(data: code)
        }
    }
    
    func delete(code: CodeSnippetSendable) {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let container = self?.container else { return }
            let dataService = DataService<CDCodeSnippet, CodeSnippetSendable>(modelContainer: container)
            do {
                let id: String = code.id
                try await dataService.remove(predicate: #Predicate<CDCodeSnippet> { $0.codeId == id } )
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchData(for groupId: String) async -> [CodeSnippetSendable] {
        let vmItems: [CodeSnippetSendable] = await Task.detached(priority: .userInitiated) { [weak self] in
            guard let container = self?.container else { return [] }
            let dataService = DataService<CDCodeSnippet, CodeSnippetSendable>(modelContainer: container)
            if let items: [CodeSnippetSendable] = try? await dataService.fetchDataVMs(predicate: #Predicate<CDCodeSnippet> { $0.groupId == groupId }, sortBy: [SortDescriptor(\.timestamp)]) {
                return items
            }
            return []
        }.value
        return vmItems
    }
    
    func fetchSnippet(for codeId: String) async -> CodeSnippetSendable? {
        let vmItem: CodeSnippetSendable? = await Task.detached(priority: .userInitiated) { [weak self] in
            guard let container = self?.container else { return nil }
            let dataService = DataService<CDCodeSnippet, CodeSnippetSendable>(modelContainer: container)
            if let items: [CodeSnippetSendable] = try? await dataService.fetchDataVMs(predicate: #Predicate<CDCodeSnippet> { $0.codeId == codeId }, sortBy: [SortDescriptor(\.timestamp)]) {
                return items.first
            }
            return nil
        }.value
        return vmItem
    }
}

// MARK: - Command
extension PersistentDataManager: PersistentCommandDataManagerProtocol {
    func add(command: ChatCommand) {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let container = self?.container else { return }
            let dataService = DataService<CDChatCommand, ChatCommand>(modelContainer: container)
            await dataService.insert(data: command)
        }
    }
    
    func delete(command: ChatCommand) {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let container = self?.container else { return }
            let dataService = DataService<CDChatCommand, ChatCommand>(modelContainer: container)
            do {
                let id: String = command.name
                try await dataService.remove(predicate: #Predicate<CDChatCommand> { $0.name == id } )
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchAllCommands() async -> [ChatCommand] {
        let vmItems: [ChatCommand] = await Task.detached(priority: .userInitiated) { [weak self] in
            guard let container = self?.container else { return [] }
            let dataService = DataService<CDChatCommand, ChatCommand>(modelContainer: container)
            if let items: [ChatCommand] = try? await dataService.fetchDataVMs(predicate: nil, sortBy: [SortDescriptor(\.timestamp)]) {
                return items
            }
            return []
        }.value
        return vmItems
    }
    
    func fetchCommand(for name: String) async -> ChatCommand? {
        let vmItem: ChatCommand? = await Task.detached(priority: .userInitiated) { [weak self] in
            guard let container = self?.container else { return nil }
            let dataService = DataService<CDChatCommand, ChatCommand>(modelContainer: container)
            if let items: [ChatCommand] = try? await dataService.fetchDataVMs(predicate: #Predicate<CDChatCommand> { $0.name == name }, sortBy: [SortDescriptor(\.timestamp)]) {
                return items.first
            }
            return nil
        }.value
        return vmItem
    }
}

// MARK: - Workflow
extension PersistentDataManager: PersistentWorkflowDataManagerProtocol {
    func add(workflow: Workflow) {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let container = self?.container else { return }
            let dataService = DataService<CDWorkflow, Workflow>(modelContainer: container)
            await dataService.insert(data: workflow)
        }
    }
    
    func delete(workflow: Workflow) {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let container = self?.container else { return }
            let dataService = DataService<CDWorkflow, Workflow>(modelContainer: container)
            do {
                let id: String = workflow.name
                try await dataService.remove(predicate: #Predicate<CDWorkflow> { $0.name == id } )
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchAllWorkflows() async -> [Workflow] {
        let vmItems: [Workflow] = await Task.detached(priority: .userInitiated) { [weak self] in
            guard let container = self?.container else { return [] }
            let dataService = DataService<CDWorkflow, Workflow>(modelContainer: container)
            if let items: [Workflow] = try? await dataService.fetchDataVMs(predicate: nil, sortBy: [SortDescriptor(\.timestamp)]) {
                return items
            }
            return []
        }.value
        return vmItems
    }
    
    func fetchWorkflow(for name: String) async -> Workflow? {
        let vmItem: Workflow? = await Task.detached(priority: .userInitiated) { [weak self] in
            guard let container = self?.container else { return nil }
            let dataService = DataService<CDWorkflow, Workflow>(modelContainer: container)
            if let items: [Workflow] = try? await dataService.fetchDataVMs(predicate: #Predicate<CDWorkflow> { $0.name == name }, sortBy: [SortDescriptor(\.timestamp)]) {
                return items.first
            }
            return nil
        }.value
        return vmItem
    }
}
