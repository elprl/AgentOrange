//
//  CommandRowView.swift
//  AgentOrange
//
//  Created by Paul Leo on 20/12/2024.
//

import SwiftUI

struct CommandRowView: View {
    let command: ChatCommand
    var showMenu: Bool = true
    var action: ((RowEvent) -> Void)?
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center) {
                    Image(systemName: "command")
                        .foregroundStyle(.accent)
                    Text(command.name)
                        .lineLimit(1)
                        .font(.headline)
                    Spacer()
                    if showMenu {
                        Menu {
                            Button {
                                action?(.delete)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                action?(.duplicate)
                            } label: {
                                Label("Duplicate", systemImage: "plus.rectangle.on.rectangle")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundStyle(.accent)
                        }
                        .menuOrder(.fixed)
                        .highPriorityGesture(TapGesture())
                    }
                }
                Text(command.shortDescription)
                    .lineLimit(1)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    Text("Model: \(Text(command.model).foregroundStyle(.secondary))")
                        .lineLimit(1)
                        .font(.caption)
                    Text("|")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Host: \(Text(command.host).foregroundStyle(.secondary))")
                        .lineLimit(1)
                        .font(.caption)
                    Spacer()
                }
            }
            .tint(.primary)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color(UIColor.systemGray4), lineWidth: 1)
        }
        .backgroundStyle(.ultraThinMaterial)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack {
                CommandRowView(command: ChatCommand.mock()) { _ in
                    print("Command deleted")
                }
            }
            .padding()
        }
    }
    .tint(.accent)
}

#Preview("Without Menu") {
    NavigationStack {
        ScrollView {
            LazyVStack {
                CommandRowView(command: ChatCommand.mock(), showMenu: false)
                .frame(width: 200)
            }
            .padding()
        }
    }
    .tint(.accent)
}
