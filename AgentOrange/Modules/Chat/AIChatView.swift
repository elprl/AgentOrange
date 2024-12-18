//
//  AIChatView.swift
//  AgentOrange
//
//  Created by Paul Leo on 02/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import SwiftUI

struct AIChatView: View {
    @Environment(AIChatViewModel.self) private var chatVM: AIChatViewModel
    @Environment(FileViewerViewModel.self) private var fileVM: FileViewerViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
#if DEBUG
let _ = Self._printChanges()
#endif
            if chatVM.selectedGroup == nil {
                Text("← Select or create a new group to start chatting")
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                messages
                Spacer()
                ScopeBarView()
                input
            }
        }
        .transition(.opacity)
        .padding(.bottom)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    Button(action: {
                        chatVM.addGroup()
                    }, label: {
                        Label("New Group", systemImage: "plus")
                            .foregroundColor(.white)
                    })
                    Button(action: {
                        chatVM.groupName = chatVM.selectedGroup?.title ?? ""
                        chatVM.shouldShowRenameDialog = true
                    }, label: {
                        Label("Rename", systemImage: "pencil")
                    })
                    Button(action: {
                        chatVM.deleteAll()
                    }, label: {
                        Label("Delete All", systemImage: "trash")
                            .foregroundStyle(.white)
                    })
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.white)
                }
                .menuOrder(.fixed)
                .highPriorityGesture(TapGesture())                
            }
        }
        .navigationBarTitle(chatVM.selectedGroup?.title ?? "AI Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.accent, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            chatVM.loadMessages()
        }
    }
    
    @ViewBuilder
    private var messages: some View {
        @Bindable var vm = chatVM
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(chatVM.chats.indices, id: \.self) { index in
                    AIChatViewRow(chat: $vm.chats[index]) { action in
                        switch action {
                        case .deleted:
                            chatVM.delete(message: vm.chats[index])
                        case .selected:
                            fileVM.didSelectCode(id: vm.chats[index].codeId)
                        case .stopped:
                            chatVM.stop(chatId: vm.chats[index].id)
                        }
                    }
                    .transition(.slide)
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                }
            }
            .padding(.vertical)
        }
        .tint(.accent)
    }
    
    @ViewBuilder
    private var input: some View {
        @Bindable var chatVMBindable = chatVM
        HStack {
            Menu {
                Text("COMMANDS")
                ForEach(chatVM.commands, id: \.self) { command in
                    Button {
                        chatVM.runCommand(command: command)
                    } label: {
                        Text(command.name)
                    }
                }
                Divider()
                Text("WORKFLOWS")
                ForEach(chatVM.workflowNames, id: \.self) { name in
                    Button {
                        chatVM.runWorkflow(name: name)
//                        chatVM.runWorkflowInParallel(name: name)
                    } label: {
                        Text(name)
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28, alignment: .center)
            }
            .menuOrder(.fixed)
            .highPriorityGesture(TapGesture())
            
            TextField("Ask a question", text: $chatVMBindable.question, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .keyboardType(.asciiCapable)
                .focused($isFocused)
                .onSubmit {
                    self.isFocused = true
                }
                .submitLabel(.return)
                .lineLimit(1...10)
            Spacer()
            Group {
                if chatVM.isAnyGenerating {
                    DebouncedButton {
                        chatVM.stopAll()
                    } label: {
                        Image(systemName: "stop.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 26, height: 26, alignment: .center)
                    }
                } else {
                    DebouncedButton {
                        chatVM.streamResponse()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 26, height: 26, alignment: .center)
                    }
                }
            }
        }
        .transition(.opacity)
        .tint(.accent)
        .padding(.horizontal)
    }
}

#Preview("Empty") {
    AIChatView()
        .environment(AIChatViewModel.mock())
        .environment(FileViewerViewModel(modelContext: PreviewController.chatsPreviewContainer.mainContext))
}

