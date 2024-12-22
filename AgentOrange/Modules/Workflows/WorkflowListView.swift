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
#if DEBUG
let _ = Self._printChanges()
#endif
        ScrollView {
            LazyVStack {
                ForEach(workflows) { workflow in
                    Button {
                        navVM.selectedDetailedItem = .workflowDetail(workflow: workflow.sendableModel)
                    } label: {
                        WorkflowRowView(workflow: workflow.sendableModel) { event in
                            workflowVM.delete(workflow: workflow.sendableModel)
                        }
                    }
                    .overlay {
                        if case let .workflowDetail(selectedWorkflow) = navVM.selectedDetailedItem, selectedWorkflow.name == workflow.name {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.accent, lineWidth: 3)
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
        .onChange(of: workflowVM.isEditing) { 
            if case let .workflowDetail(selectedWorkflow) = navVM.selectedDetailedItem, let index = workflows.firstIndex(where: { $0.name == selectedWorkflow.name }) {
                let workflow = workflows[index]
                navVM.selectedDetailedItem = .workflowDetail(workflow: workflow.sendableModel)
            }
        }
    }
}

#Preview {
    WorkflowListView()
        .environment(NavigationViewModel())
        .environment(WorkflowListViewModel(modelContext: PreviewController.workflowsPreviewContainer.mainContext))
        .modelContext(PreviewController.workflowsPreviewContainer.mainContext)
}
