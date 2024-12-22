//
//  CommandRowView.swift
//  AgentOrange
//
//  Created by Paul Leo on 20/12/2024.
//

import SwiftUI

struct CommandRowView: View {
    let command: ChatCommand
    let action: (RowEvent) -> Void
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Image(systemName: "command")
                        .foregroundStyle(.accent)
                    Text(command.name)
                        .lineLimit(1)
                        .font(.headline)
                    Spacer()
                    Menu {
                        Button {
                            action(.deleted)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(.accent)
                    }
                    .menuOrder(.fixed)
                    .highPriorityGesture(TapGesture())
                }
                Text(command.shortDescription)
                    .lineLimit(1)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    Text("Model: \(Text(command.model ?? "default").foregroundStyle(.secondary))")
                        .lineLimit(1)
                        .font(.caption)
                    Spacer()
                    Text("Host: \(Text(command.host ?? "default").foregroundStyle(.secondary))")
                        .lineLimit(1)
                        .font(.caption)
                }                
            }
            .tint(.primary)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(LinearGradient(colors: [.accent, .gray],
                                             startPoint: .top,
                                             endPoint: .bottom), style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: []))
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
