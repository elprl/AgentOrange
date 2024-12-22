//
//  WorkflowDetailedView.swift
//  AgentOrange
//
//  Created by Paul Leo on 20/12/2024.
//

import SwiftUI

struct WorkflowDetailedView: View {
    @Environment(WorkflowListViewModel.self) private var viewModel: WorkflowListViewModel
    let workflow: Workflow
    
    var body: some View {
        Form {
            if viewModel.isEditing {
                editingView
            } else {
                readOnlyView
            }
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .padding()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.editBtnPressed(workflow: workflow)
                }, label: {
                    Text(viewModel.isEditing ? "Save" :"Edit")
                        .foregroundStyle(.white)
                })
                if viewModel.isEditing {
                    Button(action: {
                        viewModel.cancelBtnPressed(workflow: workflow)
                    }, label: {
                        Text("Cancel")
                            .foregroundStyle(.white)
                    })
                }
            }
        }
        .navigationBarTitle("Command Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.accent, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onChange(of: workflow.name) {
            viewModel.selectedName = workflow.name
        }
    }
    
    @ViewBuilder
    private var editingView: some View {
        @Bindable var vm = viewModel
        Section("Basics") {
            HStack(alignment: .top) {
                Text("Name: ").foregroundStyle(.primary)
                Spacer()
                TextField("Enter Name", text: $vm.editingWorkflow.name)
                    .foregroundStyle(.secondary)
            }
            HStack(alignment: .top) {
                Text("Short Description: ").foregroundStyle(.primary)
                Spacer()
                TextField("Enter Description", text: $vm.editingWorkflow.shortDescription)
                    .foregroundStyle(.secondary)
            }
        }
        
        Section("Commands") {

        }
    }
    
    @ViewBuilder
    private var readOnlyView: some View {
        Section("Basics") {
            HStack(alignment: .top) {
                Text("Name: ").foregroundStyle(.primary)
                Spacer()
                Text(workflow.name)
                    .foregroundStyle(.accent)
            }
            HStack(alignment: .top) {
                Text("Short Description: ").foregroundStyle(.primary)
                Spacer()
                Text(workflow.shortDescription)
                    .foregroundStyle(.accent)
            }
        }
        
        Section("Commands") {
            ScrollView {
                LazyVStack {
                    ForEach(workflow.commands, id: \.self) { command in
                        Button {
                            
                        } label: {
                            HStack {
                                Text(command.name)
                                    .foregroundStyle(.accent)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.accent)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    WorkflowDetailedView(workflow: Workflow.mock())
}
