//
//  AIChatView.swift
//  AgentOrange
//
//  Created by Paul Leo on 02/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import SwiftUI

struct AIChatView: View {
    @Environment(AIChatViewModel.self) private var chatVM: AIChatViewModel
    @Environment(FileViewerViewModel.self) private var codeVM: FileViewerViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
#if DEBUG
let _ = Self._printChanges()
#endif
            messages
            Spacer()
            scope
            input
        }
        .padding(.bottom)
        .navigationBarTitle("AI Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.orange, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    @ViewBuilder
    private var messages: some View {
        List(chatVM.chats.values.sorted { $0.timestamp < $1.timestamp }, id: \.self) { chat in
            AIChatViewRow(chat: chat)
        }
        .listStyle(.plain)
        .tint(.orange)
    }
    
    @ViewBuilder
    private var input: some View {
        @Bindable var chatVMBindable = chatVM
        HStack {
            Menu {
                Button {

                } label: {
                    Text("Command: Make Better")
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
        .tint(.orange)
        .padding([.horizontal])
    }
    
    @AppStorage(Scope.role.rawValue) private var systemScope: Bool = true
    @AppStorage(Scope.code.rawValue) private var codeScope: Bool = true
    @AppStorage(Scope.history.rawValue) private var historyScope: Bool = true
    
    @ViewBuilder
    private var scope: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Text("Scopes: ")
                ToggleButton(title: Scope.role.rawValue, isOn: $systemScope, onColor: .orange) {}
                ToggleButton(title: Scope.code.rawValue, isOn: $codeScope, onColor: .orange) {}
                ToggleButton(title: Scope.history.rawValue, isOn: $historyScope, onColor: .orange) {}
                Spacer()
            }
        }
        .transition(.opacity)
        .padding(.vertical, 4)
        .padding(.horizontal)
    }
}

#Preview("Empty") {
    AIChatView()
        .environment(AIChatViewModel.mock())
        .environment(FileViewerViewModel())
}

