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
    /* @Injected(\.dataService) */ @ObservationIgnored private var dataService: PersistentWorkflowDataManagerProtocol
    var editingWorkflow: Workflow
    var selectedWorkflow: Workflow
    var isEditing: Bool = false
    var errorMessage: String?
    
    init(modelContext: ModelContext, workflow: Workflow) {
        editingWorkflow = workflow
        selectedWorkflow = workflow
        self.dataService = Container.shared.dataService(modelContext.container) // Injected PersistentDataManager(container: modelContext.container)
    }
    
    func selected(workflow: Workflow) {
        cancelBtnPressed()
        selectedWorkflow = workflow
        editingWorkflow = workflow
    }
    
    func addWorkflow() {
        let newWorkflow = Workflow(name: "New Workflow", timestamp: Date.now, shortDescription: "New Workflow", commands:[])
        editingWorkflow = newWorkflow
        Task {
            await dataService.add(workflow: newWorkflow)
        }
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
        return !editingWorkflow.name.isEmpty && !editingWorkflow.shortDescription.isEmpty && !editingWorkflow.commands.isEmpty
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
    
    func getHosts() -> [String] {
        var uniqueHosts = [String]()
        editingWorkflow.commands.forEach {
            let host = $0.host ?? UserDefaults.standard.customAIHost ?? "http://localhost:1234"
            if uniqueHosts.contains(host) == false {
                uniqueHosts.append(host)
            }
        }
        return uniqueHosts
    }
        
    func commands(for host: String) -> [ChatCommand] {
        let filteredCommands = editingWorkflow.commands.filter {
            let existingHost = $0.host ?? UserDefaults.standard.customAIHost ?? "http://localhost:1234"
            return existingHost == host
        }
        print("Filtered Commands for \(host): \(filteredCommands.map { $0.name })")
        return filteredCommands
    }
    
    func addCommand(command: ChatCommand) {
        if !editingWorkflow.commands.contains(command) {
            editingWorkflow.commands.append(command)
        }
    }
}

extension WorkflowDetailedViewModel {
    static func mock() -> WorkflowDetailedViewModel {
        let viewModel = WorkflowDetailedViewModel(modelContext: PreviewController.workflowsPreviewContainer.mainContext, workflow: Workflow(name: "Workflow", timestamp: Date.now, shortDescription: "Workflow Description", commands: []))
        return viewModel
    }
}

