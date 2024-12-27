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
    @State private var viewModel: WorkflowListViewModel
    @Query(sort: \CDWorkflow.timestamp, order: .reverse) private var workflows: [CDWorkflow]

    init(modelContext: ModelContext) {
        self._viewModel = State(initialValue: WorkflowListViewModel(modelContext: modelContext))
    }

    var body: some View {
#if DEBUG
let _ = Self._printChanges()
#endif
        ScrollView {
            LazyVStack {
                if workflows.isEmpty {
                    Text("No workflows found.\nTap + to add a new workflow.")
                        .foregroundStyle(.secondary)
                        .padding()
                }
                ForEach(workflows, id:\.name) { workflow in
                    Button {
                        // Force a state update by creating a new value
                        navVM.selectedDetailedItem = nil
                        // Bug workaround: add slight delay to ensure state is cleared
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            navVM.selectedDetailedItem = .workflowDetail(workflow: workflow.sendableModel)
                        }
                    } label: {
                        WorkflowRowView(workflow: workflow.sendableModel) { event in
                            viewModel.delete(workflow: workflow.sendableModel)
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
                .animation(.easeInOut, value: workflows.count)
            }
            .padding()
        }
        .alert("Are you sure?", isPresented: $viewModel.showAlert) {
            Button("Delete", role: .destructive, action: {
                Task { @MainActor in
                    viewModel.deleteAllWorkflows()
                }
            })
            Button("Cancel", role: .cancel, action: {})
        } message: {
            Text("Delete ALL workflows?")
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.addWorkflow()
                }, label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                })
                Menu {
                    Button(action: {
                        viewModel.showAlert = true
                    }, label: {
                        Label("Delete All", systemImage: "trash")
                            .foregroundColor(.white)
                    })
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.white)
                }
                .menuOrder(.fixed)
                .highPriorityGesture(TapGesture())
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
    WorkflowListView(modelContext: PreviewController.workflowsPreviewContainer.mainContext)
        .environment(NavigationViewModel.mock())
        .modelContext(PreviewController.workflowsPreviewContainer.mainContext)
}
