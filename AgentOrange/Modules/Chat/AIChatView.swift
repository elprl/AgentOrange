//
//  AIChatView.swift
//  AgentOrange
//
//  Created by Paul Leo on 02/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import SwiftUI
import SwiftData

struct AIChatView: View {
    @Environment(AIChatViewModel.self) private var chatVM: AIChatViewModel
    @Environment(FileViewerViewModel.self) private var fileVM: FileViewerViewModel
    @FocusState private var isFocused: Bool
    @State private var isPresented = false
    @Query(sort: \CDChatCommand.timestamp, order: .reverse) private var commands: [CDChatCommand]
    @Query(sort: \CDWorkflow.timestamp, order: .reverse) private var workflows: [CDWorkflow]
    @Query(sort: \CDChatMessage.timestamp, order: .forward) private var chats: [CDChatMessage]

    init(groupId: String) {
        _chats = Query(filter: #Predicate<CDChatMessage> { $0.groupId == groupId }, sort: \CDChatMessage.timestamp, order: .forward)
    }

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
        .fullScreenCover(isPresented: $isPresented) {
            NavigationStack {
                ScrollView {
                    if let id = chatVM.selectedChatId, let chat = chats.first(where: { $0.messageId == id }) {
                        AIChatViewRow(chat: chat.sendableModel) { action in
                            switch action {
                            case .deleted:
                                chatVM.delete(message: chat.sendableModel)
                            case .selected:
                                fileVM.didSelectCode(id: chat.codeId)
                            case .stopped:
                                chatVM.stop(chatId: chat.messageId)
                            case .fullscreen:
                                isPresented = false
                            }
                        }
                        .padding()
                    } else {
                        EmptyView()
                    }
                }
                .navigationTitle("Chat Message")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button(action: {
                            isPresented = false
                        }, label: {
                            Image(systemName: "xmark")
                        })
                    }
                }
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(.accent, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
            }
        }
    }
    
    @ViewBuilder
    private var messages: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(chats, id: \.self) { chat in
                    AIChatViewRow(chat: chat.sendableModel) { action in
                        switch action {
                        case .deleted:
                            chatVM.delete(message: chat.sendableModel)
                        case .selected:
                            fileVM.didSelectCode(id: chat.codeId)
                        case .stopped:
                            chatVM.stop(chatId: chat.messageId)
                        case .fullscreen:
                            chatVM.selectedChatId = chat.messageId
                            isPresented = true
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                }
                .transition(.slide)
                .animation(.default, value: chatVM.chats.count)
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
                ForEach(commands, id: \.self) { command in
                    Button {
                        chatVM.runCommand(command: command.sendableModel)
                    } label: {
                        Text(command.name)
                    }
                }
                Divider()
                Text("WORKFLOWS")
                ForEach(workflows, id: \.self) { workflow in
                    Button {
                        chatVM.runWorkflow(name: workflow.name)
                    } label: {
                        Text(workflow.name)
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
        .tint(.messageBlue)
        .padding(.horizontal)
    }
}

#Preview("Empty") {
    AIChatView(groupId: "1")
        .environment(AIChatViewModel.mock())
        .environment(FileViewerViewModel(modelContext: PreviewController.chatsPreviewContainer.mainContext))
}

