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
    var selectedName: String?
    var isEditing: Bool = false
    var editableCommand: ChatCommand = ChatCommand.blank()
    var selectedCommand: ChatCommand?
    var errorMessage: String?

    init(modelContext: ModelContext) {
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
        if validateCommand() {
            errorMessage = nil
            Task {
                await dataService.add(command: editableCommand)
            }
        } else {
            errorMessage = "Name and prompt are required"
        }
    }
    
    func createNewCommand() {
        isEditing = true
        editableCommand = ChatCommand.blank()
    }
    
    private func validateCommand() -> Bool {
        return !editableCommand.name.isEmpty && !editableCommand.prompt.isEmpty
    }
    
    func editBtnPressed(command: ChatCommand) {
        selectedName = command.name
        if isEditing {
            isEditing = false
            save()
        } else {
            editableCommand = command
            isEditing = true
        }
    }
    
    func cancelBtnPressed(command: ChatCommand) {
        isEditing = false
        editableCommand = command
        errorMessage = nil
    }
        
}

extension CommandListViewModel {
    static func mock() -> CommandListViewModel {
        let viewModel = CommandListViewModel(modelContext: PreviewController.commandsPreviewContainer.mainContext)
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
