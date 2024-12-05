//
//  AIChatViewRow.swift
//  AgentOrange
//
//  Created by Paul Leo on 04/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import SwiftUI

struct AIChatViewRow: View {
    let chat: ChatMessage
    @State private var isExpanded: Bool = true
    @Environment(FileViewerViewModel.self) private var fileVM: FileViewerViewModel
    let deleteAction: () -> Void

    var body: some View {
        GroupBox {
            header
            Text(markdown(from: chat.content))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: chat.role == .user ? .trailing : .leading)
            if let tag = chat.tag {
                Button {
                    fileVM.selectedId = chat.codeId
                } label: {
                    GroupBox {
                        HStack {
                            Image(systemName: "text.page")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                            Divider().frame(height: 32)
                            VStack(alignment: .leading) {
                                Text(tag)
                                Text("Click to view code")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(-6)
                    }
                    .backgroundStyle(.ultraThinMaterial)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .tint(.accent)
            }
        }
        .transition(.slide)
        .backgroundStyle(chat.role == .assistant ? Color.black.opacity(0.6) : Color.accent)
        .listRowSeparator(.hidden)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    private func markdown(from response: String) -> AttributedString {
        do {
            return try AttributedString(markdown: response, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        } catch {
            return AttributedString("Error parsing markdown: \(error)")
        }
    }
    
    @ViewBuilder
    private var header: some View {
        HStack {
            if chat.role == .assistant {
                Image(systemName: "brain")
                Text(UserDefaults.standard.customAIModel ?? "Assistent")
                    .bold()
                    .foregroundStyle(chat.role == .assistant ? .purple : .black)
            }
            Spacer()
            Menu {
                Button {
                    deleteAction()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(.white)
            }
            .menuOrder(.fixed)
            .highPriorityGesture(TapGesture())
        }
    }
}

#Preview {
    List {
        AIChatViewRow(chat: ChatMessage(role: .user, content: "blah blah")) {}
        AIChatViewRow(chat: ChatMessage(role: .assistant, content: "blah blah", tag: "CodeGen1")) {}
    }
    .listStyle(.plain)
    .environment(FileViewerViewModel())
}
