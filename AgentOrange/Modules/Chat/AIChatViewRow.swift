//
//  AIChatViewRow.swift
//  AgentOrange
//
//  Created by Paul Leo on 04/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import SwiftUI

enum RowEvent {
    case deleted
    case selected
    case stopped
}

struct AIChatViewRow: View {
    let chat: ChatMessage
    let action: (RowEvent) -> Void

    var body: some View {
        GroupBox {
            if chat.role == .user {
                userMessage
            } else if (chat.tag?.isEmpty ?? true)  {
                botSimpleMessage
            } else {
                botCodeMessage
            }
        }
        .transition(.slide)
        .backgroundStyle(chat.role == .assistant ? Color.black.opacity(0.6) : Color.accent)
        .listRowSeparator(.hidden)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    @ViewBuilder
    private var userMessage: some View {
        HStack {
            Text(markdown(from: chat.content))
                .foregroundStyle(.white)
                .padding(.trailing)
            Menu {
                Button {
                    action(.deleted)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                Button {
                    UIPasteboard.general.string = chat.content
                } label: {
                    Label("Copy", systemImage: "document.on.document.fill")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(chat.role == .assistant ? .accent : .white)
            }
            .menuOrder(.fixed)
            .highPriorityGesture(TapGesture())
            .offset(x: 4)
        }
    }
    
    @ViewBuilder
    private var botCodeMessage: some View {
        header
        if let tag = chat.tag {
            DisclosureGroup {
                Text(markdown(from: chat.content))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } label: {
                Button {
                    action(.selected)
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(-6)
                    }
                    .backgroundStyle(.ultraThinMaterial)
                }
                .tint(.accent)
            }
        }
    }
    
    @ViewBuilder
    private var botSimpleMessage: some View {
        header
        Text(markdown(from: chat.content))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                if let author = chat.model {
                    Text(author)
                        .lineLimit(1)
                        .bold()
                        .foregroundStyle(author.color)
                } else {
                    Text("\(Text("Agent").bold().underline().foregroundStyle(.white)) Orange")
                        .lineLimit(1)
                        .bold()
                        .foregroundStyle(.accent)
                }
                if let host = chat.host {
                    Text(host)
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Menu {
                Button {
                    action(.deleted)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                Button {
                    UIPasteboard.general.string = chat.content
                } label: {
                    Label("Copy", systemImage: "document.on.document.fill")
                }
                Button {
                    action(.stopped)
                } label: {
                    Label("Stop", systemImage: "stop.circle")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(chat.role == .assistant ? .accent : .white)
            }
            .menuOrder(.fixed)
            .highPriorityGesture(TapGesture())
            .offset(x: 4)
        }
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
        AIChatViewRow(chat: ChatMessage(role: .user, content: "blah blah", groupId: "1")) { _ in }
        AIChatViewRow(chat: ChatMessage(role: .assistant, content: "blah blah", tag: "CodeGen1", groupId: "1")) { _ in }
    }
    .listStyle(.plain)
    .environment(FileViewerViewModel(modelContext: PreviewController.chatsPreviewContainer.mainContext))
}
