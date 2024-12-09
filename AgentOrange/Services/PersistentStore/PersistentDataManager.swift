//
//  ChatMessagesDataService.swift
//  AgentOrange
//
//  Created by Paul Leo on 08/12/2024.
//

import SwiftData
import SwiftUI

final class PersistentDataManager {
    private let modelContext: ModelContext?
    
    /// pass nil for previews or unit testing
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
}

// MARK: - ChatMessage
extension PersistentDataManager {
    
    @MainActor
    func add(message: ChatMessage) async {
        guard let container = modelContext?.container else { return }
        Task.detached(priority: .userInitiated) {
            let dataService = DataService<CDChatMessage, ChatMessage>(modelContainer: container)
            await dataService.insert(data: message)
        }
    }
    
    @MainActor
    func delete(messages: [ChatMessage]) async {
        guard let container = modelContext?.container else { return }
        Task.detached(priority: .userInitiated) {
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
    
    @MainActor
    func delete(message: ChatMessage) async {
        guard let container = modelContext?.container else { return }
        Task.detached(priority: .userInitiated) {
            let dataService = DataService<CDChatMessage, ChatMessage>(modelContainer: container)
            do {
                let id: String = message.id
                try await dataService.remove(predicate: #Predicate<CDChatMessage> { $0.messageId == id } )
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func fetchData(for groupId: String) async -> [ChatMessage] {
        guard let container = modelContext?.container else { return [] }
        let vmItems: [ChatMessage] = await Task.detached(priority: .userInitiated) {
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
extension PersistentDataManager {
    @MainActor
    func add(group: MessageGroupSendable) async {
        guard let container = modelContext?.container else { return }
        Task.detached(priority: .userInitiated) {
            let dataService = DataService<CDMessageGroup, MessageGroupSendable>(modelContainer: container)
            await dataService.insert(data: group)
        }
    }
    
    @MainActor
    func delete(group: MessageGroupSendable) async {
        guard let container = modelContext?.container else { return }
        Task.detached(priority: .userInitiated) {
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
