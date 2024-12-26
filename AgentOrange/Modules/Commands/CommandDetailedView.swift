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

    init(command: ChatCommand, modelContext: ModelContext) {
        self._viewModel = State(initialValue: CommandDetailedViewModel(modelContext: modelContext, command: command))
    }
    
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
        Section("Basics") {
            HStack(alignment: .top) {
                Text("Name: ").foregroundStyle(.primary)
                Spacer()
                TextField("Enter Name", text: $vm.editableCommand.name)
                    .foregroundStyle(.secondary)
            }
            HStack(alignment: .top) {
                Text("Short Description: ").foregroundStyle(.primary)
                Spacer()
                TextField("Enter Description", text: $vm.editableCommand.shortDescription)
                    .foregroundStyle(.secondary)
            }
            HStack(alignment: .top) {
                Text("Role: ").foregroundStyle(.primary)
                Spacer()
                TextField("Enter role", text: $vm.editableCommand.role.binding)
                    .foregroundStyle(.secondary)
                
            }
            HStack(alignment: .top) {
                Text("Prompt: ").foregroundStyle(.primary).padding(.top, 8)
                Spacer()
                TextEditor(text: $vm.editableCommand.prompt)
                    .foregroundStyle(.secondary)
                    .lineLimit(5...10)
            }
        }
        
        Section("AI") {
            Picker("Host", selection: $vm.editableCommand.host) {
                Text(AGIServiceChoice.openai.name).tag(AGIServiceChoice.openai.name)
                Text(AGIServiceChoice.gemini.name).tag(AGIServiceChoice.gemini.name)
                Text(AGIServiceChoice.claude.name).tag(AGIServiceChoice.claude.name)
                if (viewModel.editableCommand.host ?? customAIHost).hasPrefix("http") {
                    Text(AGIServiceChoice.customAI.name).tag(vm.editableCommand.host)
                } else {
                    Text(AGIServiceChoice.customAI.name).tag(customAIHost)
                }
            }
            .tint(.secondary)
            if (viewModel.editableCommand.host ?? customAIHost).hasPrefix("http") {
                TextField(customAIHost, text: $vm.editableCommand.host.bindableHost)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
                    .frame(alignment: .trailing)
                HStack {
                    Text("Model: ").foregroundStyle(.primary)
                    Spacer()
                    TextField(customAIModel, text: $vm.editableCommand.model.bindableModel)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                        .frame(alignment: .trailing)

                }
            } else {
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
                        TextField(customAIModel, text: $vm.editableCommand.model.bindableModel)
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(.secondary)
            }
            Picker("Type", selection: $vm.editableCommand.type) {
                Text(AgentType.coder.rawValue).tag(AgentType.coder)
                Text(AgentType.reviewer.rawValue).tag(AgentType.reviewer)
            }
            .tint(.secondary)
        }
    }
    
    @ViewBuilder
    private var readOnlyView: some View {
        Section("Basics") {
            HStack(alignment: .top) {
                Text("Name: ").foregroundStyle(.primary)
                Spacer()
                Text(viewModel.selectedCommand.name)
                    .foregroundStyle(.accent)
            }
            HStack(alignment: .top) {
                Text("Short Description: ").foregroundStyle(.primary)
                Spacer()
                Text(viewModel.selectedCommand.shortDescription)
                    .foregroundStyle(.accent)
            }
            HStack(alignment: .top) {
                Text("Role: ").foregroundStyle(.primary)
                Spacer()
                Text(viewModel.selectedCommand.role ?? "")
                    .foregroundStyle(.accent)
            }
            HStack(alignment: .top) {
                Text("Prompt: ").foregroundStyle(.primary)
                Spacer()
                Text(viewModel.selectedCommand.prompt)
                    .lineLimit(nil)
                    .foregroundStyle(.accent)
            }
        }
        
        Section("AI") {
            HStack {
                Text("Host: ").foregroundStyle(.primary)
                Spacer()
                Text(viewModel.selectedCommand.host ?? customAIHost)
                    .foregroundStyle(.accent)
            }
            HStack {
                Text("Model: ").foregroundStyle(.primary)
                Spacer()
                Text(viewModel.selectedCommand.model ?? customAIModel)
                    .foregroundStyle(.accent)
            }
            HStack {
                Text("Type: ").foregroundStyle(.primary)
                Spacer()
                Text(viewModel.selectedCommand.type?.rawValue ?? "")
                    .foregroundStyle(.accent)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CommandDetailedView(command: ChatCommand.mock(), modelContext: PreviewController.commandsPreviewContainer.mainContext)
    }
}
