//
//  WorkflowDetailedView.swift
//  AgentOrange
//
//  Created by Paul Leo on 20/12/2024.
//

import SwiftUI
import SwiftData

struct WorkflowDetailedView: View {
    @State private var viewModel: WorkflowDetailedViewModel
    @Query private var commands: [CDChatCommand]
    
    init(workflow: Workflow, modelContext: ModelContext) {
        self._viewModel = State(initialValue: WorkflowDetailedViewModel(modelContext: modelContext, workflow: workflow))
    }

    var body: some View {
#if DEBUG
let _ = Self._printChanges()
#endif
        
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
                    viewModel.editBtnPressed()
                }, label: {
                    Text(viewModel.isEditing ? "Save" :"Edit")
                        .foregroundStyle(.white)
                })
                if viewModel.isEditing {
                    Button(action: {
                        viewModel.cancelBtnPressed()
                    }, label: {
                        Text("Cancel")
                            .foregroundStyle(.white)
                    })
                }
            }
        }
        .navigationBarTitle("Workflow Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.accent, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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
            HStack(alignment: .top) {
                GroupBox {
                    Text("Selected Commands")
                        .lineLimit(1)
                        .font(.title3)
                        .foregroundStyle(.accent)
                    List {
                        ForEach(viewModel.editingWorkflow.commands, id: \.self) { command in
                            CommandRowView(command: command, showMenu: false)
                        }
                        .onDelete { viewModel.editingWorkflow.commands.remove(atOffsets: $0) }
                        .onMove { from, to in
                            viewModel.editingWorkflow.commands.move(fromOffsets: from, toOffset: to)
                        }
                    }
                    .environment(\.editMode, .constant(EditMode.active))
                }
                .padding(.vertical)
                Spacer()
                VStack {
                    Text("Available Commands")
                        .lineLimit(1)
                        .font(.title3)
                    ScrollView {
                        LazyVStack {
                            ForEach(commands) { command in
                                Button {
                                    viewModel.addCommand(command: command.sendableModel)
                                } label: {
                                    CommandRowView(command: command.sendableModel, showMenu: false)
                                }
                            }
                        }
                        .frame(width: 200, alignment: .center)
                    }
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder
    private var readOnlyView: some View {
        Section("Basics") {
            HStack(alignment: .top) {
                Text("Name: ").foregroundStyle(.primary)
                Spacer()
                Text(viewModel.selectedWorkflow.name)
                    .foregroundStyle(.accent)
            }
            HStack(alignment: .top) {
                Text("Short Description: ").foregroundStyle(.primary)
                Spacer()
                Text(viewModel.selectedWorkflow.shortDescription)
                    .foregroundStyle(.accent)
            }
        }
        
        Section("Commands") {
            ScrollView {
                VStack(alignment: .center, spacing: 0) {
                    Text("Parallel Tracks")
                        .lineLimit(1)
                        .font(.title3)
                        .foregroundStyle(.accent)
                        .padding(.top)
                    Text("Based on hosts")
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Rectangle()
                        .fill(Color.accent)
                        .frame(width: 1, height: 20)
                    if viewModel.hosts.count > 1 {
                        Rectangle()
                            .fill(Color.accent)
                            .frame(height: 1)
                            .padding(.horizontal, 108)
                    }
                    HStack {
                        ForEach(viewModel.hosts.indices, id: \.self) { index in
                            Rectangle()
                                .fill(Color.accent)
                                .frame(width: 1, height: 20, alignment: .leading)
                            if index != viewModel.hosts.count - 1 {
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 108)
                    .padding(.bottom, -8)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                HStack(alignment: .top) {
                    ForEach(viewModel.hosts.indices, id: \.self) { trackIndex in
                        let host = viewModel.hosts[trackIndex]
                        VStack(spacing: 0) {
                            Text(host)
                                .lineLimit(1)
                                .font(.headline)
                                .underline()
                                .foregroundStyle(.secondary)
                                .padding(.vertical)
                            ForEach(viewModel.commands(for: host).indices, id: \.self) { index in
                                Button {
                                    
                                } label: {
                                    CommandRowView(command: viewModel.commands(for: host)[index], showMenu: false)
                                        .frame(width: 200, alignment: .center)
                                        .padding(.bottom, 10)
                                        .background {
                                            if index != viewModel.commands(for: host).count - 1 {
                                                VStack {
                                                    Spacer()
                                                    Rectangle()
                                                        .fill(Color.accent)
                                                        .frame(width: 1, height: 10, alignment: .center)
                                                }
                                            }
                                        }
                                }
                            }
                        }
                        .padding([.horizontal, .top], 8)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.accent, lineWidth: 1)
                        }
                        if trackIndex != viewModel.hosts.count - 1 {
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        WorkflowDetailedView(workflow: Workflow.mock(), modelContext: PreviewController.commandsPreviewContainer.mainContext)
            .environment(WorkflowListViewModel.mock())
            .modelContext(PreviewController.commandsPreviewContainer.mainContext)
    }
}
