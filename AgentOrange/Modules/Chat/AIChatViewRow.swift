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
            if chat.role == .user {
                userMessage
            } else if chat.tag != nil {
                botCodeMessage
            } else {
                botSimpleMessage
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
                    deleteAction()
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
                    fileVM.didSelectCode(id: chat.codeId)
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
        HStack {
            Text("\(Text("Agent").bold().underline().foregroundStyle(.white)) Orange")
                .bold()
                .foregroundStyle(.accent)
            Spacer()
            Menu {
                Button {
                    deleteAction()
                } label: {
                    Label("Delete", systemImage: "trash")
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
    private var logo: some View {
        ZStack {
            Circle()
                .fill(.accent)
                .frame(width: 20, height: 20)
            Image("biohazard")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 14, height: 14)
                .foregroundColor(.black)
            Circle()
                .stroke(.black, lineWidth: 2)
                .frame(width: 20, height: 20)
                .shadow(color: .gray, radius: 2)
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
        AIChatViewRow(chat: ChatMessage(role: .user, content: "blah blah", groupId: "1")) {}
        AIChatViewRow(chat: ChatMessage(role: .assistant, content: "blah blah", tag: "CodeGen1", groupId: "1")) {}
    }
    .listStyle(.plain)
    .environment(FileViewerViewModel(modelContext: PreviewController.chatsPreviewContainer.mainContext))
}
