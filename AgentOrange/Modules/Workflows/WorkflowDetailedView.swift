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
                        ForEach(viewModel.getHosts(commands: commands), id: \.self) { host in
                            VStack(spacing: 0) {
                                Text(host)
                                    .lineLimit(1)
                                    .font(.headline)
                                    .underline()
                                    .foregroundStyle(.secondary)
                                    .padding(.vertical)
                                
                                List {
                                    ForEach(viewModel.commands(for: host, commands: commands), id: \.self) { command in
                                        CommandRowView(command: command.sendableModel, showMenu: false)
                                    }
                                    .onDelete { indexSet in
                                        for offset in indexSet {
                                            if offset < viewModel.commands(for: host, commands: commands).count {
                                                let command = viewModel.commands(for: host, commands: commands)[offset]
                                                viewModel.deleteFromWorkflow(command: command.sendableModel)
                                            }
                                        }
                                    }
                                    .onMove { from, to in
                                        var arrayCopy = viewModel.commands(for: host, commands: commands)
                                        arrayCopy.move(fromOffsets: from, toOffset: to)
                                        var commandIds = [String]()
                                        for moveHost in viewModel.getHosts(commands: commands) {
                                            if moveHost != host {
                                                for command in viewModel.commands(for: moveHost, commands: commands) {
                                                    commandIds.append(command.name)
                                                }
                                            } else {
                                                commandIds.append(contentsOf: arrayCopy.map { $0.name })
                                            }
                                        }
                                        let idsString = commandIds.joined(separator: ",")
                                        print("idsString: \(idsString)")
                                        viewModel.editingWorkflow.commandIds = idsString
                                    }
                                }
                                .environment(\.editMode, .constant(EditMode.active))
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
                            ForEach(commands) { command in
                                Button {
                                    viewModel.addToWorkflow(command: command.sendableModel)
                                } label: {
                                    CommandRowView(command: command.sendableModel, showMenu: false)
                                        .overlay {
                                            if viewModel.editingWorkflow.commandIds?.contains(command.name) ?? false {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.accent, lineWidth: 2)
                                            }
                                        }
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
                if (viewModel.selectedWorkflow.commandIds ?? "").isEmpty {
                    Text("No commands selected")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    tracks
                    hosts
                }
            }
        }
    }

    @ViewBuilder
    private var tracks: some View {
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
            GeometryReader { geometry in
                let width = geometry.frame(in: .local).width
                if viewModel.getHosts(commands: commands).count > 1 {
                    Rectangle()
                        .fill(Color.accent)
                        .frame(height: 1, alignment: .center)
                        .padding(.horizontal, ((width / CGFloat(viewModel.getHosts(commands: commands).count)) * 0.5))
                        .transition(.scale)
                        .animation(.easeInOut, value: viewModel.getHosts(commands: commands).count)
                }
            }
            .frame(height: 1, alignment: .center)
            .padding(.bottom, -10)
            .padding(.horizontal, -4)

            HStack(alignment: .top) {
                ForEach(viewModel.getHosts(commands: commands), id: \.self) { host in
                        Rectangle()
                            .fill(Color.accent)
                            .frame(width: 1, height: 20, alignment: .center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .transition(.scale)
                            .animation(.easeInOut, value: viewModel.getHosts(commands: commands).count)
                    if host != viewModel.getHosts(commands: commands).last {
                        Spacer()
                    }
                }
            }
            .padding(.bottom, -8)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    @ViewBuilder
    private var hosts: some View {
        HStack(alignment: .top) {
            ForEach(viewModel.getHosts(commands: commands), id: \.self) { host in
                VStack(spacing: 0) {
                    Text(host)
                        .lineLimit(1)
                        .font(.headline)
                        .underline()
                        .foregroundStyle(.secondary)
                        .padding(.vertical)
                    ForEach(viewModel.commands(for: host, commands: commands), id: \.self) { command in
                        Button {
                            
                        } label: {
                            CommandRowView(command: command.sendableModel, showMenu: false)
//                                .frame(width: 200, alignment: .center)
                                .padding(.bottom, 10)
                                .background {
                                    if command != viewModel.commands(for: host, commands: commands).last {
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
                if host != viewModel.getHosts(commands: commands).last {
                    Spacer()
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
