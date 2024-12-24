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
    var workflows: [Workflow] = []
    
    init(modelContext: ModelContext) {
        self.dataService = Container.shared.dataService(modelContext.container) // Injected PersistentDataManager(container: modelContext.container)
    }
    
    func load() {
        Task {
            workflows = await dataService.fetchAllWorkflows()
        }
    }

    func addWorkflow() {
        let newWorkflow = Workflow(name: "New Workflow", timestamp: Date.now, shortDescription: "New Workflow", commandIds: [])
        Task {
            await dataService.add(workflow: newWorkflow)
            workflows = await dataService.fetchAllWorkflows()
        }
    }
    
    func delete(workflow: Workflow) {
        Task {
            await dataService.delete(workflow: workflow)
            if let index = workflows.firstIndex(of: workflow) {
                workflows.remove(at: index)
            }
        }
    }
}

extension WorkflowListViewModel {
    static func mock() -> WorkflowListViewModel {
        let viewModel = WorkflowListViewModel(modelContext: PreviewController.workflowsPreviewContainer.mainContext)
        return viewModel
    }
}

