//
//  WorkflowDetailedViewModel.swift
//  AgentOrange
//
//  Created by Paul Leo on 22/12/2024.
//

import SwiftUI
import SwiftData
import Factory

@Observable
@MainActor
final class WorkflowDetailedViewModel {
    /* @Injected(\.dataService) */ @ObservationIgnored private var dataService: PersistentWorkflowDataManagerProtocol & PersistentCommandDataManagerProtocol
    var editingWorkflow: Workflow
    var selectedWorkflow: Workflow
    var isEditing: Bool = false
    var errorMessage: String?
    
    init(modelContext: ModelContext, workflow: Workflow) {
        editingWorkflow = workflow
        selectedWorkflow = workflow
        self.dataService = Container.shared.dataService(modelContext.container) // Injected PersistentDataManager(container: modelContext.container)
    }
    
    func save() {
        if validateCommand() {
            errorMessage = nil
            Task {
                await dataService.add(workflow: editingWorkflow)
                self.selectedWorkflow = self.editingWorkflow
                NotificationCenter.default.post(name: NSNotification.Name("refreshWorkflows"), object: nil)
            }
        } else {
            errorMessage = "Name, short description and commands are required"
        }
    }
    
    private func validateCommand() -> Bool {
        guard let commandIds = editingWorkflow.commandIds else { return false }
        return !editingWorkflow.name.isEmpty && !editingWorkflow.shortDescription.isEmpty && !commandIds.isEmpty
    }
    
    func delete(workflow: Workflow) {
        Task {
            await dataService.delete(workflow: workflow)
        }
    }
    
    func editBtnPressed() {
        if isEditing {
            save()
            isEditing = false
        } else {
            isEditing = true
        }
    }
    
    func cancelBtnPressed() {
        isEditing = false
        editingWorkflow = selectedWorkflow
        errorMessage = nil
    }
    
    func getHosts(commands: [CDChatCommand]) -> [String] {
        let workflowCommands = filteredCommands(commands: commands)
        var uniqueHosts = [String]()
        workflowCommands.forEach {
            let host = $0.host ?? UserDefaults.standard.customAIHost ?? "http://localhost:1234"
            if uniqueHosts.contains(host) == false {
                uniqueHosts.append(host)
            }
        }
        return uniqueHosts
    }
        
    func commands(for host: String, commands: [CDChatCommand]) -> [CDChatCommand] {
        let workflowCommands = filteredCommands(commands: commands)

        let filteredCommands = workflowCommands.filter {
            let existingHost = $0.host ?? UserDefaults.standard.customAIHost ?? "http://localhost:1234"
            return existingHost == host
        }
        return filteredCommands
    }
    
    // get the ordered commands for the workflow based on the order of the commandIds
    func filteredCommands(commands: [CDChatCommand]) -> [CDChatCommand] {
        let workflowCommands = commands.filter { commandIds.contains($0.name) }
        // reorder the commands based on the commandIds
        let orderedCommands = commandIds.compactMap { commandId in
            return workflowCommands.first { $0.name == commandId }
        }
        return orderedCommands
    }
    
    func addToWorkflow(command: ChatCommand) {
        var commandIds = commandIds
        if !commandIds.contains(command.name) {
            commandIds.append(command.name)
            editingWorkflow.commandIds = commandIds.joined(separator: ",").trimmingCharacters(in: .whitespaces)
        }
    }
    
    func deleteFromWorkflow(command: ChatCommand) {
        var commandIds = commandIds
        if let index = commandIds.firstIndex(of: command.name) {
            commandIds.remove(at: index)
            let newCommandIds = commandIds.joined(separator: ",").trimmingCharacters(in: .whitespaces)
            editingWorkflow.commandIds = newCommandIds
        }
    }
    
    var commandIds: [String] {
        guard let commandIds = editingWorkflow.commandIds else { return [] }
        return commandIds.components(separatedBy: ",")
    }

}

extension WorkflowDetailedViewModel {
    static func mock() -> WorkflowDetailedViewModel {
        let viewModel = WorkflowDetailedViewModel(modelContext: PreviewController.workflowsPreviewContainer.mainContext,
                                                  workflow: Workflow(name: "Workflow", timestamp: Date.now, shortDescription: "Workflow Description", commandIds: "command1,command2"))
        return viewModel
    }
}

