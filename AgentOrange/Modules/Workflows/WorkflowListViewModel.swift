//
//  WorkflowListViewModel.swift
//  AgentOrange
//
//  Created by Paul Leo on 22/12/2024.
//

import SwiftUI
import SwiftData
import Factory

@Observable
@MainActor
final class WorkflowListViewModel {
    /* @Injected(\.dataService) */ @ObservationIgnored private var dataService: PersistentWorkflowDataManagerProtocol
    var editingWorkflow: Workflow = Workflow(name: "", timestamp: Date.now, shortDescription: "", commands: [])
    var selectedName: String?
    var isEditing: Bool = false
    var errorMessage: String?
    
    init(modelContext: ModelContext) {
        self.dataService = Container.shared.dataService(modelContext.container) // Injected PersistentDataManager(container: modelContext.container)
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
    
    func editBtnPressed(workflow: Workflow) {
        selectedName = workflow.name
        if isEditing {
            isEditing = false
            save()
        } else {
            editingWorkflow = workflow
            isEditing = true
        }
    }
    
    func cancelBtnPressed(workflow: Workflow) {
        isEditing = false
        editingWorkflow = workflow
        errorMessage = nil
    }
    
    func parallelTracks(from commands: [ChatCommand]) -> [String] {
        var uniqueHosts = [String]()
        commands.forEach {
            if let host = $0.host, uniqueHosts.contains(host) == false {
                uniqueHosts.append(host)
            }
        }
        return uniqueHosts
    }
        
    func commands(for host: String, commands: [ChatCommand]) -> [ChatCommand] {
        return commands.filter { $0.host == host }
    }
    
    func addCommand(command: ChatCommand) {
        if !editingWorkflow.commands.contains(command) {
            editingWorkflow.commands.append(command)
        }
    }
}

extension WorkflowListViewModel {
    static func mock() -> WorkflowListViewModel {
        let viewModel = WorkflowListViewModel(modelContext: PreviewController.workflowsPreviewContainer.mainContext)
        return viewModel
    }
}

