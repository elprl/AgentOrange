//
//  WorkflowListView.swift
//  AgentOrange
//
//  Created by Paul Leo on 20/12/2024.
//

import SwiftUI
import SwiftData

struct WorkflowListView: View {
    @Environment(NavigationViewModel.self) private var navVM: NavigationViewModel
    @Environment(WorkflowListViewModel.self) private var workflowVM: WorkflowListViewModel
    @Query private var workflows: [CDWorkflow]

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(workflows) { workflow in
                    Button {
                        navVM.selectedNavigationItem = .workflowDetail(workflow: workflow.sendableModel)
                    } label: {
                        WorkflowRowView(workflow: workflow.sendableModel) { event in
                            workflowVM.delete(workflow: workflow.sendableModel)
                        }
                    }
                }
                .transition(.slide)
                .animation(.default, value: workflows.count)
            }
            .padding()
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    workflowVM.addWorkflow()
                }, label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                })
            }
        }
        .navigationBarTitle("Workflows")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.accent, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    WorkflowListView()
        .environment(NavigationViewModel())
        .environment(WorkflowListViewModel(modelContext: PreviewController.workflowsPreviewContainer.mainContext))
        .modelContext(PreviewController.workflowsPreviewContainer.mainContext)
}
