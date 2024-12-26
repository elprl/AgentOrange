//
//  CommandDetailedViewModel.swift
//  AgentOrange
//
//  Created by Paul Leo on 22/12/2024.
//

import Foundation
import Factory
import SwiftData

@Observable
@MainActor
final class CommandDetailedViewModel {
    /* @Injected(\.commandService) */ @ObservationIgnored private var commandService: CommandServiceProtocol
    var isEditing: Bool = false
    var editableCommand: ChatCommand
    var selectedCommand: ChatCommand
    var errorMessage: String?

    init(modelContext: ModelContext, command: ChatCommand) {
        self.selectedCommand = command
        self.editableCommand = command
        self.commandService = Container.shared.commandService(modelContext.container) // Injected CommandService(container: modelContext.container)
    }
    
    func save() {
        if validateCommand() {
            errorMessage = nil
            Task {
                await commandService.save(command: editableCommand)
                selectedCommand = editableCommand
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

extension CommandDetailedViewModel {
    static func mock() -> CommandDetailedViewModel {
        let viewModel = CommandDetailedViewModel(modelContext: PreviewController.commandsPreviewContainer.mainContext, command: ChatCommand.mock())
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
    var _bindableHost: String? {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    public var bindableHost: String {
        get {
            return _bindableHost ?? UserDefaults.standard.customAIHost ?? "http://localhost:1234"
        }
        set {
            _bindableHost = newValue.isEmpty ? nil : newValue
        }
    }
    
    var _bindableModel: String? {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    public var bindableModel: String {
        get {
            return _bindableModel ?? UserDefaults.standard.customAIModel ?? "qwen2.5-coder-32b-instruct"
        }
        set {
            _bindableModel = newValue.isEmpty ? nil : newValue
        }
    }
}
