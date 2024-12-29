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
                HStack(alignment: .center) {
                    Image(systemName: "arrow.trianglehead.swap")
                        .foregroundStyle(.accent)
                    Text(workflow.name)
                        .lineLimit(1)
                        .font(.headline)
                    Spacer()
                    Menu {
                        Button {
                            action(.delete)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            action(.duplicate)
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
                Text(workflow.shortDescription)
                    .lineLimit(1)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(workflow.commandIds?.components(separatedBy: ",") ?? [], id: \.self) { name in
                            Text(name)
                                .lineLimit(1)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color(UIColor.systemGray5))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.top, 2)
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
    WorkflowRowView(workflow: Workflow.mock()) { _ in
        
    }
}
