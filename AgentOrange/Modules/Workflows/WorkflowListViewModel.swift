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
    var errorMessage: String?
    var showAlert: Bool = false
    
    init(modelContext: ModelContext) {
        self.dataService = Container.shared.dataService(modelContext.container) // Injected PersistentDataManager(container: modelContext.container)
    }

    func addWorkflow() {
        let newWorkflow = Workflow(name: "", timestamp: Date.now, shortDescription: "", commandIds: nil)
        Task {
            await dataService.add(workflow: newWorkflow)
        }
    }
    
    func delete(workflow: Workflow) {
        Task {
            await dataService.delete(workflow: workflow)
        }
    }
    
    func duplicate(workflow: Workflow) {
        var newWorkflow = workflow
        newWorkflow.name += " Copy"
        Task {
            await dataService.add(workflow: newWorkflow)
        }
    }
    
    func removeCommands(workflow: Workflow) {
        var newWorkflow = workflow
        newWorkflow.commandIds = nil
        Task {
            await dataService.add(workflow: newWorkflow)
        }
    }
    
    func deleteAllWorkflows() {
        Task {
            await dataService.deleteAllWorkflows()
        }
    }
}

extension WorkflowListViewModel {
    static func mock() -> WorkflowListViewModel {
        let viewModel = WorkflowListViewModel(modelContext: PreviewController.workflowsPreviewContainer.mainContext)
        return viewModel
    }
}

