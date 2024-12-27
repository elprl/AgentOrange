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
        let newWorkflow = Workflow(name: "New Workflow", timestamp: Date.now, shortDescription: "New Workflow", commandIds: nil)
        Task {
            await dataService.add(workflow: newWorkflow)
        }
    }
    
    func delete(workflow: Workflow) {
        Task {
            await dataService.delete(workflow: workflow)
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

