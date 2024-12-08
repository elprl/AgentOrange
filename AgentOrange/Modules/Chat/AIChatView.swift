//
//  AIChatView.swift
//  AgentOrange
//
//  Created by Paul Leo on 02/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import SwiftUI

struct AIChatView: View {
    @Environment(AIChatViewModel.self) private var chatVM: AIChatViewModel
    @FocusState private var isFocused: Bool
    @State private var position = ScrollPosition(edge: .top)

    var body: some View {
        VStack {
#if DEBUG
let _ = Self._printChanges()
#endif
            messages
            Spacer()
            ScopeBarView()
            input
        }
        .padding(.bottom)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
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
        .navigationBarTitle("AI Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.accent, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    @ViewBuilder
    private var messages: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(chatVM.chats.values.sorted { $0.timestamp < $1.timestamp }, id: \.self) { chat in
                    AIChatViewRow(chat: chat) {
                        chatVM.delete(message: chat)
                    }
                    .transition(.slide)
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                }
                scrollToBottomDetector
            }
        }
        .scrollPosition($position)
        .tint(.accent)
        .onChange(of: self.chatVM.chats) {
            withAnimation {
                if self.chatVM.hasScrolledOffBottom {
                    Log.view.debug("Scrolling to bottom from \(position.point?.y ?? 0)")
                    position.scrollTo(edge: .bottom)
                }
            }
        }
        .onChange(of: self.chatVM.isGenerating) {
            withAnimation {
                if self.chatVM.hasScrolledOffBottom {
                    Log.view.debug("Scrolling to bottom from \(position.point?.y ?? 0)")
                    position.scrollTo(edge: .bottom)
                }
            }
        }
        .onChange(of: self.chatVM.isGenerating) {
            withAnimation {
                if self.chatVM.hasScrolledOffBottom {
                    Log.view.debug("Scrolling to bottom from \(position.point?.y ?? 0)")
                    position.scrollTo(edge: .bottom)
                }
            }
        }
    }
    
    @ViewBuilder
    private var input: some View {
        @Bindable var chatVMBindable = chatVM
        HStack {
            Menu {
                Button {
                    chatVM.runCommands()
                } label: {
                    Text("Run all tasks")
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
                if !chatVM.isGenerating {
                    Button {
                        chatVM.streamResponse()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 26, height: 26, alignment: .center)
                    }
                } else {
                    Button {
                        chatVM.stop()
                    } label: {
                        Image(systemName: "stop.circle")
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
    
    @ViewBuilder
    private var scrollToBottomDetector: some View {
        Color.clear
            .frame(width: 0, height: 30, alignment: .bottom)
            .onAppear {
                chatVM.hasScrolledOffBottom = false
            }
            .onDisappear {
                chatVM.hasScrolledOffBottom = true
            }
            .id(Int.max)
    }
}

#Preview("Empty") {
    AIChatView()
        .environment(AIChatViewModel.mock())
        .environment(FileViewerViewModel())
}

