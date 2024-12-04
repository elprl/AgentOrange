//
//  AIChatViewRow.swift
//  AgentOrange
//
//  Created by Paul Leo on 04/12/2024.
//

import SwiftUI

struct AIChatViewRow: View {
    let chat: ChatMessage
    @State private var isExpanded: Bool = true

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
                GroupBox {
                    VStack(alignment: .trailing) {
                        HStack {
                            Image(systemName: "text.page")
                            Text(chat.tag ?? "")
                        }
                        Text("Click to view code").font(.caption).foregroundStyle(.secondary)
                    }
                }
                .backgroundStyle(.ultraThinMaterial)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
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
    AIChatViewRow(chat: ChatMessage(role: .user, content: "blah blah"))
    AIChatViewRow(chat: ChatMessage(role: .bot, content: "blah blah"))
}
