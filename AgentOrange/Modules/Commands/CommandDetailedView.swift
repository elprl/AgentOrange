//
//  CommandDetailedView.swift
//  AgentOrange
//
//  Created by Paul Leo on 20/12/2024.
//

import SwiftUI
import SwiftData

struct CommandDetailedView: View {
    @State private var viewModel: CommandDetailedViewModel
    @AppStorage(UserDefaults.Keys.customAIModel) var customAIModel: String = "qwen2.5-coder-32b-instruct"
    @AppStorage(UserDefaults.Keys.customAIHost) var customAIHost: String = "http://localhost:1234"
    @Query(sort: \CDChatCommand.timestamp, order: .reverse) private var commands: [CDChatCommand]
    
    init(command: ChatCommand, modelContext: ModelContext) {
        self._viewModel = State(initialValue: CommandDetailedViewModel(modelContext: modelContext, command: command))
    }
    
    var body: some View {
        ScrollView {
            if viewModel.isEditing {
                editingView
                dependencies
            } else {
                readOnlyView
            }
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .padding()
            }
        }
        .padding()
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.editBtnPressed(command: viewModel.selectedCommand)
                }, label: {
                    Text(viewModel.isEditing ? "Save" :"Edit")
                        .foregroundStyle(.white)
                })
                if viewModel.isEditing {
                    Button(action: {
                        viewModel.cancelBtnPressed(command: viewModel.selectedCommand)
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
    }
    
    @ViewBuilder
    private var editingView: some View {
        @Bindable var vm = viewModel
        Text("Basics")
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
            .padding(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        GroupBox {
            HStack(alignment: .top) {
                Text("Name: ").foregroundStyle(.primary)
                Spacer()
                TextField("Enter Name", text: $vm.editableCommand.name)
                    .foregroundStyle(.secondary)
            }
            Divider()
            HStack(alignment: .top) {
                Text("Short Description: ").foregroundStyle(.primary)
                Spacer()
                TextField("Enter Description", text: $vm.editableCommand.shortDescription)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)
            Divider()
            HStack(alignment: .top) {
                Text("Role: ").foregroundStyle(.primary)
                Spacer()
                TextField("Enter role", text: $vm.editableCommand.role)
                    .foregroundStyle(.secondary)
                
            }
            .padding(.top, 8)
            Divider()
            HStack(alignment: .top) {
                Text("Prompt: ").foregroundStyle(.primary).padding(.top, 8)
                Spacer()
                TextEditor(text: $vm.editableCommand.prompt)
                    .foregroundStyle(.secondary)
                    .lineLimit(5...10)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .backgroundStyle(Color(UIColor.secondarySystemBackground))
        
        Text("AI")
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
            .padding([.leading, .top])
            .frame(maxWidth: .infinity, alignment: .leading)
        GroupBox {
            HStack {
                Text("Host")
                Spacer()
                Picker("Host", selection: $vm.editableCommand.host) {
                    Text(AGIServiceChoice.openai.name).tag(AGIServiceChoice.openai.name)
                    Text(AGIServiceChoice.gemini.name).tag(AGIServiceChoice.gemini.name)
                    Text(AGIServiceChoice.claude.name).tag(AGIServiceChoice.claude.name)
                    if (viewModel.editableCommand.host).hasPrefix("http") {
                        Text(AGIServiceChoice.customAI.name).tag(vm.editableCommand.host)
                    } else {
                        Text(AGIServiceChoice.customAI.name).tag(customAIHost)
                    }
                }
                .tint(.secondary)
            }
            Divider()
            if (viewModel.editableCommand.host).hasPrefix("http") {
                TextField(customAIHost, text: $vm.editableCommand.host)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
                    .frame(alignment: .trailing)
                    .padding(.top, 8)
                Divider()
                HStack {
                    Text("Model: ").foregroundStyle(.primary)
                    Spacer()
                    TextField(customAIModel, text: $vm.editableCommand.model)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                        .frame(alignment: .trailing)
                }
                .padding(.top, 8)
                Divider()
            } else {
                HStack {
                    Text("Model")
                    Spacer()
                    Picker("Model", selection: $vm.editableCommand.model) {
                        if viewModel.editableCommand.host == AGIServiceChoice.openai.name {
                            ForEach(GPTModel.allCases) { model in
                                Text("\(model.id) (\(model.maxTokens) tokens)").tag(model.id)
                            }
                        } else if vm.editableCommand.host == AGIServiceChoice.gemini.name {
                            ForEach(GeminiModel.allCases) { model in
                                Text("\(model.id) (\(model.maxTokens) tokens)").tag(model.id)
                            }
                        } else if vm.editableCommand.host == AGIServiceChoice.claude.name {
                            ForEach(ClaudeModel.allCases) { model in
                                Text("\(model.id) (\(model.maxTokens) tokens)").tag(model.id)
                            }
                        } else {
                            TextField(customAIModel, text: $vm.editableCommand.model)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.secondary)
                }
                .padding(.top, 8)
                Divider()
            }
            HStack {
                Text("Type")
                Spacer()
                Picker("Type", selection: $vm.editableCommand.type) {
                    Text(AgentType.coder.rawValue).tag(AgentType.coder)
                    Text(AgentType.reviewer.rawValue).tag(AgentType.reviewer)
                }
                .tint(.secondary)
            }
        }
        .backgroundStyle(Color(UIColor.secondarySystemBackground))
    }
    
    @ViewBuilder
    private var dependencies: some View {
        Text("Dependencies")
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
            .padding([.leading, .top])
            .frame(maxWidth: .infinity, alignment: .leading)
        HStack(alignment: .top) {
            VStack {
                Text("Selected")
                    .lineLimit(1)
                    .font(.headline)
                    .foregroundStyle(.accent)
                if viewModel.selectedCommand.dependencyIds.isEmpty {
                    Text("None")
                }
                List {
                    ForEach(viewModel.selectedCommand.dependencyIds, id: \.self) { id in
                        if let command = commands.first(where: { $0.name == id }) {
                            CommandRowView(command: command.sendableModel, showMenu: false)
                        }
                    }
                    .onDelete { indexSet in
                        for offset in indexSet {
                            if offset < viewModel.selectedCommand.dependencyIds.count {
                                let id = viewModel.selectedCommand.dependencyIds[offset]
                                viewModel.deleteDependency(id: id)
                            }
                        }
                    }
                }
                .environment(\.editMode, .constant(EditMode.active))
            }
            Spacer()
            VStack {
                Text("Available")
                    .lineLimit(1)
                    .font(.headline)
                    .padding(.top)
                ScrollView {
                    LazyVStack {
                        ForEach(commands) { command in
                            Button {
                                viewModel.addDependency(id: command.name)
                            } label: {
                                CommandRowView(command: command.sendableModel, showMenu: false)
                                    .frame(maxWidth: 300)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: 316)
        }
    }
    
    @ViewBuilder
    private var readOnlyView: some View {
        Text("Basics")
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
            .padding(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        GroupBox {
            HStack(alignment: .top) {
                Text("Name: ").foregroundStyle(.primary)
                Spacer()
                Text(viewModel.selectedCommand.name)
                    .foregroundStyle(.accent)
            }
            Divider()
            HStack(alignment: .top) {
                Text("Short Description: ").foregroundStyle(.primary)
                Spacer()
                Text(viewModel.selectedCommand.shortDescription)
                    .foregroundStyle(.accent)
            }
            .padding(.top, 8)
            Divider()
            HStack(alignment: .top) {
                Text("Role: ").foregroundStyle(.primary)
                Spacer()
                Text(viewModel.selectedCommand.role)
                    .foregroundStyle(.accent)
            }
            .padding(.top, 8)
            Divider()
            HStack(alignment: .top) {
                Text("Prompt: ").foregroundStyle(.primary)
                Spacer()
                Text(viewModel.selectedCommand.prompt)
                    .lineLimit(nil)
                    .foregroundStyle(.accent)
            }
        }
        .backgroundStyle(Color(UIColor.secondarySystemBackground))
        
        Text("AI")
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
            .padding([.leading, .top])
            .frame(maxWidth: .infinity, alignment: .leading)
        GroupBox {
            HStack {
                Text("Host: ").foregroundStyle(.primary)
                Spacer()
                Text(viewModel.selectedCommand.host)
                    .foregroundStyle(.accent)
            }
            .padding(.top, 8)
            Divider()
            HStack {
                Text("Model: ").foregroundStyle(.primary)
                Spacer()
                Text(viewModel.selectedCommand.model)
                    .foregroundStyle(.accent)
            }
            .padding(.top, 8)
            Divider()
            HStack {
                Text("Type: ").foregroundStyle(.primary)
                Spacer()
                Text(viewModel.selectedCommand.type.rawValue)
                    .foregroundStyle(.accent)
            }
        }
        .backgroundStyle(Color(UIColor.secondarySystemBackground))
        
        Text("Dependencies")
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
            .padding([.leading, .top])
            .frame(maxWidth: .infinity, alignment: .leading)
        GroupBox {
            if viewModel.selectedCommand.dependencyIds.isEmpty {
                Text("None")
            }
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.selectedCommand.dependencyIds, id: \.self) { id in
                        if let command = commands.first(where: { $0.name == id }) {
                            CommandRowView(command: command.sendableModel, showMenu: false)
                        }
                    }
                }
            }
        }
        .backgroundStyle(Color(UIColor.secondarySystemBackground))
    }
}

#Preview {
    NavigationStack {
        CommandDetailedView(command: ChatCommand.mock(), modelContext: PreviewController.commandsPreviewContainer.mainContext)
    }
}
