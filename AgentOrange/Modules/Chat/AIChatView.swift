//
//  ContentView.swift
//  LLMJsonTestHarness
//
//  Created by Paul Leo on 02/12/2024.
//

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
                            .frame(width: 28, height: 28, alignment: .center)
                    }
                } else {
                    Button {
                        chatVM.stop()
                    } label: {
                        Image(systemName: "stop.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28, alignment: .center)
                    }
                }
            }
        }
        .transition(.opacity)
        .tint(.orange)
        .padding()
    }
}

#Preview("Empty") {
    AIChatView()
        .environment(AIChatViewModel.mock())
        .environment(FileViewerViewModel())
}

