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
    @Injected(\.commandService) @ObservationIgnored private var commandService
    /* @Injected(\.dataService) */ @ObservationIgnored private var dataService: PersistentCommandDataManagerProtocol
    var commands: [ChatCommand] = []
    var selectedIndex: Int?
    var isEditing: Bool = false
    var editableCommand: ChatCommand = ChatCommand.blank()
    var selectedCommand: ChatCommand?

    init(modelContext: ModelContext, command: ChatCommand? = nil) {
        self.dataService = Container.shared.dataService(modelContext.container) // Injected PersistentDataManager(container: modelContext.container)

        let hasLoadedDefaultCommand = UserDefaults.standard.bool(forKey: "hasLoadedDefaultCommand")
        if !hasLoadedDefaultCommand {
            commandService.defaultCommands.forEach { command in
                Task {
                    await dataService.add(command: command)
                }
            }
            UserDefaults.standard.set(true, forKey: "hasLoadedDefaultCommand")
        }
    }
    
    func save() {
        Task {
            await dataService.add(command: editableCommand)
        }
    }
}

extension CommandListViewModel {
    static func mock() -> CommandListViewModel {
        let viewModel = CommandListViewModel(modelContext: PreviewController.commandsPreviewContainer.mainContext)
        viewModel.commands = [ChatCommand.mock(), ChatCommand.mock(), ChatCommand.mock()]
        return viewModel
    }
}

extension Optional where Wrapped == String {
    var _binding: String? {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    public var binding: String {
        get {
            return _binding ?? ""
        }
        set {
            _binding = newValue.isEmpty ? nil : newValue
        }
    }
}
