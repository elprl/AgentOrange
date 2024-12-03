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

    var body: some View {
        @Bindable var chatVM = chatVM

        VStack {
#if DEBUG
let _ = Self._printChanges()
#endif
            List(chatVM.chats.values.sorted { $0.timestamp < $1.timestamp }, id: \.self) { chat in
                Text(chatVM.markdown(from: chat.content))
            }
            .listStyle(.insetGrouped)
            Spacer()
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).foregroundStyle(.thinMaterial).frame(height: 40)
                    TextField("Ask a question", text: $chatVM.question)
                        .padding(8)
                }
                Spacer()
                Group {
                    if !chatVM.isGenerating {
                        Button("", systemImage: "paperplane.fill") {
                            chatVM.streamResponse()
                        }
                    } else {
                        Button("", systemImage: "stop.circle") {
                            chatVM.stop()
                        }
                    }
                }
                .padding(.leading, 8)
            }
            .transition(.opacity)
            .tint(.orange)
        }
        .padding()
        .navigationBarTitle("AI Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.orange, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview("Empty") {
    AIChatView()
        .environment(AIChatViewModel())
        .environment(FileViewerViewModel())
}

