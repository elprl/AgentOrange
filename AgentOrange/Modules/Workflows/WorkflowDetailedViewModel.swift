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
        return !editingWorkflow.name.isEmpty && !editingWorkflow.shortDescription.isEmpty && !editingWorkflow.commandIds.isEmpty
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
        // get commands where name is in editingWorkflow.commandIds
        let workflowCommands = commands.filter { editingWorkflow.commandIds.contains($0.name) }
        
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
        let workflowCommands = commands.filter { editingWorkflow.commandIds.contains($0.name) }

        let filteredCommands = workflowCommands.filter {
            let existingHost = $0.host ?? UserDefaults.standard.customAIHost ?? "http://localhost:1234"
            return existingHost == host
        }
        return filteredCommands
    }
    
    func addCommand(command: ChatCommand) {
        if !editingWorkflow.commandIds.contains(command.name) {
            editingWorkflow.commandIds.append(command.name)
        }
    }
}

extension WorkflowDetailedViewModel {
    static func mock() -> WorkflowDetailedViewModel {
        let viewModel = WorkflowDetailedViewModel(modelContext: PreviewController.workflowsPreviewContainer.mainContext,
                                                  workflow: Workflow(name: "Workflow", timestamp: Date.now, shortDescription: "Workflow Description", commandIds: []))
        return viewModel
    }
}

