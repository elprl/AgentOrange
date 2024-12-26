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
    var isEditing: Bool = false
    var editableCommand: ChatCommand = ChatCommand.blank()
    var selectedCommand: ChatCommand?
    var errorMessage: String?

    init(modelContext: ModelContext) {
        self.commandService = Container.shared.commandService(modelContext.container) // Injected CommandService(container: modelContext.container)
    }
    
    func createNewCommand() {
        isEditing = true
        editableCommand = ChatCommand.blank()
    }
}

extension CommandListViewModel {
    static func mock() -> CommandListViewModel {
        let viewModel = CommandListViewModel(modelContext: PreviewController.commandsPreviewContainer.mainContext)
        return viewModel
    }
}

