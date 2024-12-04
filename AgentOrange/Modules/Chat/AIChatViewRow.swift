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

    var body: some View {
        GroupBox {
            if chat.role == .bot {
                DisclosureGroup("AI Response", isExpanded: $isExpanded) {
                    Text(markdown(from: chat.content))
                        .foregroundStyle(.white)
                }
            } else {
                Text(markdown(from: chat.content))
                    .foregroundStyle(.white)
            }
            if !(chat.tag?.isEmpty ?? true) {
                Button {
                    // fileVM.selectedVersion = chat.tag ?? ""
                } label: {
                    GroupBox {
                        HStack {
                            Image(systemName: "text.page")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                            Divider().frame(height: 32)
                            VStack(alignment: .leading) {
                                Text(chat.tag ?? "")
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
                .tint(.orange)
            }
        }
        .transition(.slide)
        .backgroundStyle(chat.role == .bot ? Color.black.opacity(0.6) : Color.orange)
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
}

#Preview {
    List {
        AIChatViewRow(chat: ChatMessage(role: .user, content: "blah blah"))
        AIChatViewRow(chat: ChatMessage(role: .bot, content: "blah blah", tag: "CodeGen1"))
    }
    .listStyle(.plain)
    .environment(FileViewerViewModel())
}
