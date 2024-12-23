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
    
    let pub = NotificationCenter.default.publisher(for: NSNotification.Name("refreshWorkflows"))

    init(modelContext: ModelContext) {
        self._viewModel = State(initialValue: WorkflowListViewModel(modelContext: modelContext))
    }

    var body: some View {
#if DEBUG
let _ = Self._printChanges()
#endif
        ScrollView {
            LazyVStack {
                ForEach(viewModel.workflows, id:\.name) { workflow in
                    Button {
                        // Force a state update by creating a new value
                        navVM.selectedDetailedItem = nil
                        // Bug workaround: add slight delay to ensure state is cleared
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            navVM.selectedDetailedItem = .workflowDetail(workflow: workflow)
                        }
                    } label: {
                        WorkflowRowView(workflow: workflow) { event in
                            viewModel.delete(workflow: workflow)
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
                .animation(.default, value: viewModel.workflows.count)
            }
            .padding()
        }
        .task {
            viewModel.load()
        }
        .onReceive(pub) { _ in
            viewModel.load()
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.addWorkflow()
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
    WorkflowListView(modelContext: PreviewController.workflowsPreviewContainer.mainContext)
        .environment(NavigationViewModel.mock())
        .modelContext(PreviewController.workflowsPreviewContainer.mainContext)
}
