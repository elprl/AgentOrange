//
//  CommandListViewModel.swift
//  AgentOrange
//
//  Created by Paul Leo on 20/12/2024.
//

import Foundation
import Factory
import SwiftData

@Observable
@MainActor
final class CommandListViewModel {
    /* @Injected(\.commandService) */ @ObservationIgnored private var commandService: CommandServiceProtocol
    var selectedCommand: ChatCommand?
    var errorMessage: String?
    var showAlert: Bool = false

    init(modelContext: ModelContext) {
        self.commandService = Container.shared.commandService(modelContext.container) // Injected CommandService(container: modelContext.container)
    }
    
    func createNewCommand() {
        selectedCommand = ChatCommand.blank()
    }
    
    func resetDefaults() {
        Task {
            await commandService.resetToDefaults()
        }
    }
    
    func deleteAllCommands() {
        Task {
            await commandService.deleteAllCommands()
        }
    }
    
    func duplicate(command: ChatCommand) {
        var newCommand = command
        newCommand.name += " Copy"
        Task {
            await commandService.add(command: newCommand)
        }
    }
    
    func delete(command: ChatCommand) {
        Task {
            await commandService.delete(command: command)
        }
    }
}

extension CommandListViewModel {
    static func mock() -> CommandListViewModel {
        let viewModel = CommandListViewModel(modelContext: PreviewController.commandsPreviewContainer.mainContext)
        return viewModel
    }
}

