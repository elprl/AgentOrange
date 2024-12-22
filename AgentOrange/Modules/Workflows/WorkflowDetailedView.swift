//
//  WorkflowDetailedView.swift
//  AgentOrange
//
//  Created by Paul Leo on 20/12/2024.
//

import SwiftUI
import SwiftData

struct WorkflowDetailedView: View {
    @Environment(WorkflowListViewModel.self) private var viewModel: WorkflowListViewModel
    let workflow: Workflow
    @Query private var commands: [CDChatCommand]

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
            HStack(alignment: .top) {
                GroupBox {
                    Text("Selected Commands")
                        .lineLimit(1)
                        .font(.title3)
                        .foregroundStyle(.accent)
                    List {
                        ForEach(viewModel.editingWorkflow.commands, id: \.self) { command in
                            CommandRowView(command: command, showMenu: false)
                                .frame(width: 200, alignment: .center)
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
                VStack(alignment: .center, spacing: 0) {
                    Text("Parallel Tracks")
                        .lineLimit(1)
                        .font(.title3)
                        .foregroundStyle(.accent)
                    Text("Based on hosts")
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Rectangle()
                        .fill(Color.accent)
                        .frame(width: 1, height: 20)
                    Rectangle()
                        .fill(Color.accent)
                        .frame(height: 1)
                        .padding(.horizontal, 108)
                    HStack {
                        ForEach(viewModel.parallelTracks(from: workflow.commands).indices, id: \.self) { index in
                            Rectangle()
                                .fill(Color.accent)
                                .frame(width: 1, height: 20, alignment: .leading)
                            if index != viewModel.parallelTracks(from: workflow.commands).count - 1 {
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 108)
                    .padding(.bottom, -8)
                }
                HStack(alignment: .top) {
                    ForEach(viewModel.parallelTracks(from: workflow.commands).indices, id: \.self) { trackIndex in
                        let host = viewModel.parallelTracks(from: workflow.commands)[trackIndex]
                        VStack(spacing: 0) {
                            Text(host)
                                .lineLimit(1)
                                .font(.headline)
                                .underline()
                                .foregroundStyle(.secondary)
                                .padding(.vertical)
                            ForEach(viewModel.commands(for: host, commands: workflow.commands).indices, id: \.self) { index in
                                Button {
                                    
                                } label: {
                                    let command = viewModel.commands(for: host, commands: workflow.commands)[index]
                                    CommandRowView(command: command, showMenu: false)
                                        .frame(width: 200, alignment: .center)
                                        .padding(.bottom, 10)
                                        .background {
                                            if index != viewModel.commands(for: host, commands: workflow.commands).count - 1 {
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
                        if trackIndex != viewModel.parallelTracks(from: workflow.commands).count - 1 {
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
        WorkflowDetailedView(workflow: Workflow.mock())
            .environment(WorkflowListViewModel.mock())
            .modelContext(PreviewController.commandsPreviewContainer.mainContext)
    }
}
