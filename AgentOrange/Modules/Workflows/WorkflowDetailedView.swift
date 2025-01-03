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
    @Query(sort: \CDChatCommand.timestamp, order: .reverse) private var commands: [CDChatCommand]
    
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
                    tracks
                    HStack(alignment: .top) {
                        ForEach(0..<viewModel.tracks, id: \.self) { column in
                            List {
                                Section(content: {
                                    ForEach(viewModel.getCommands(for: column, commands: commands), id: \.self) { command in
                                        CommandRowView(command: command.sendableModel, showMenu: false)
                                    }
                                    .onDelete { indexSet in
                                        viewModel.deleteCommand(column: column, indexSet: indexSet)
                                    }
                                    .onMove { from, to in
                                        viewModel.moveCommand(column: column, from: from, to: to)
                                    }
                                    .listRowSeparator(.hidden)
                                }, header: {
                                    Button {
                                        viewModel.selectedColumn = column
                                    } label: {
                                        Text("Track \(column + 1)")
                                            .lineLimit(1)
                                            .font(.subheadline)
                                            .foregroundStyle(.white)
                                            .padding(.horizontal)
                                            .padding(.vertical, 2)
                                            .background(column == viewModel.selectedColumn ? Color.accent : Color.gray)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .shadow(radius: 1)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                })
                            }
                            .environment(\.editMode, .constant(column == viewModel.selectedColumn ? EditMode.active : EditMode.inactive))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(column == viewModel.selectedColumn ? Color.accent : Color.gray, lineWidth: 1)
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.vertical)
                Spacer()
                VStack {
                    Text("Available Commands")
                        .lineLimit(1)
                        .font(.title3)
                    ScrollView {
                        LazyVStack {
                            Button {
                                viewModel.addWaitStep()
                            } label: {
                                GroupBox {
                                    Text("Wait Step")
                                        .lineLimit(1)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(Color(UIColor.systemGray4), lineWidth: 1)
                                }
                                .backgroundStyle(.ultraThinMaterial)
                            }
                            ForEach(commands) { command in
                                Button {
                                    viewModel.addToWorkflow(command: command.sendableModel)
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
        basics
        commandViewer
    }
    
    @ViewBuilder
    private var basics: some View {
        Section("Basics") {
            HStack(alignment: .top) {
                Text("Name: ").foregroundStyle(.primary)
                Spacer()
                Text(viewModel.editingWorkflow.name)
                    .foregroundStyle(.accent)
            }
            HStack(alignment: .top) {
                Text("Short Description: ").foregroundStyle(.primary)
                Spacer()
                Text(viewModel.editingWorkflow.shortDescription)
                    .foregroundStyle(.accent)
            }
        }
    }
    
    @ViewBuilder
    private var commandViewer: some View {
        Section("Commands") {
            ScrollView {
                if (viewModel.selectedWorkflow.commandArrangement ?? "").isEmpty {
                    Text("No commands selected")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    tracks
                    commandList
                }
            }
        }
    }

    @ViewBuilder
    private var tracks: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center) {
                if viewModel.isEditing {
                    Button {
                        if viewModel.tracks > 1 {
                            viewModel.tracks -= 1
                        }
                    } label: {
                        Image(systemName: "minus.rectangle")
                            .foregroundStyle(.accent)
                    }
                    Text("^[\(viewModel.tracks) Execution Track](inflect: true)")
                        .lineLimit(1)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Button {
                        if viewModel.tracks < 5 {
                            viewModel.tracks += 1
                        }
                    } label: {
                        Image(systemName: "plus.rectangle")
                            .foregroundStyle(.accent)
                    }
                } else {
                    Text("^[\(viewModel.tracks) Execution Track](inflect: true)")
                        .lineLimit(1)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top)
            Rectangle()
                .fill(Color.accent)
                .frame(width: 1, height: 20)
            GeometryReader { geometry in
                let width = geometry.frame(in: .local).width
                if viewModel.tracks > 1 {
                    Rectangle()
                        .fill(Color.accent)
                        .frame(height: 1, alignment: .center)
                        .padding(.horizontal, ((width / CGFloat(viewModel.tracks)) * 0.5))
                        .transition(.scale)
                        .animation(.easeInOut, value: viewModel.tracks)
                }
            }
            .frame(height: 1, alignment: .center)
            .padding(.bottom, -10)
            .padding(.horizontal, -4)
            
            HStack(alignment: .top) {
                ForEach(0..<viewModel.tracks, id: \.self) { column in
                    Rectangle()
                        .fill(Color.accent)
                        .frame(width: 1, height: 20, alignment: .center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .transition(.scale)
                        .animation(.easeInOut, value: viewModel.tracks)
                    if column != (viewModel.tracks - 1)  {
                        Spacer()
                    }
                }
            }
            .padding(.bottom, -8)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    @ViewBuilder
    private var commandList: some View {
        HStack(alignment: .top) {
            ForEach(0..<viewModel.tracks, id: \.self) { column in
                VStack(spacing: 0) {
                    ForEach(viewModel.getCommands(for: column, commands: commands), id: \.self) { command in
                        Button {
                            
                        } label: {
                            CommandRowView(command: command.sendableModel, showMenu: false)
                                .padding(.bottom, 10)
                                .background {
                                    if command != viewModel.getCommands(for: column, commands: commands).last {
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
                .padding(.horizontal, 8)
                if column != (viewModel.tracks - 1) {
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        WorkflowDetailedView(workflow: Workflow.mock(), modelContext: PreviewController.commandsPreviewContainer.mainContext)
            .modelContext(PreviewController.commandsPreviewContainer.mainContext)
    }
}
