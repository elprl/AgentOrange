//
//  ChatMessagesDataService.swift
//  AgentOrange
//
//  Created by Paul Leo on 08/12/2024.
//

import Combine
import SwiftData
import SwiftUI

final class ChatMessagesDataService {
    private let modelContext: ModelContext?
    
    /// pass nil for previews or unit testing
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    @MainActor
    func add(message: ChatMessage) async {
        guard let container = modelContext?.container else { return }
        Task.detached {
            let dataService = DataService<CDChatMessage, ChatMessage>(modelContainer: container)
            await dataService.insert(data: message)
        }
    }
    
    @MainActor
    func delete(messages: [ChatMessage]) async {
        guard let container = modelContext?.container else { return }
        Task.detached {
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
        Task.detached {
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
    func fetchData() async -> [ChatMessage] {
        guard let container = modelContext?.container else { return [] }
        let vmItems: [ChatMessage] = await Task.detached {
            let dataService = DataService<CDChatMessage, ChatMessage>(modelContainer: container)
            if let items: [ChatMessage] = try? await dataService.fetchDataVMs(predicate: nil, sortBy: [SortDescriptor(\.timestamp)]) {
                return items
            }
            return []
        }.value
        return vmItems
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
