//
//  WorkflowRowView.swift
//  AgentOrange
//
//  Created by Paul Leo on 20/12/2024.
//

import SwiftUI

struct WorkflowRowView: View {
    let workflow: Workflow
    let action: (RowEvent) -> Void

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Image(systemName: "arrow.trianglehead.swap")
                        .foregroundStyle(.accent)
                    Text(workflow.name)
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
                Text(workflow.shortDescription)
                    .lineLimit(1)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(workflow.commands) { command in
                            Text(command.name)
                                .lineLimit(1)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                    }
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
    WorkflowRowView(workflow: Workflow.mock()) { _ in
        
    }
}
