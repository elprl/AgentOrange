//
//  NavigationViewModel.swift
//  AgentOrange
//
//  Created by Paul Leo on 22/12/2024.
//
import SwiftUI

enum NavigationItem: Hashable {
    case commandList
    case commandDetail(command: ChatCommand)
    case workflowList
    case workflowDetail(workflow: Workflow)
    case chatGroup(group: MessageGroupSendable)
    case openAISettings
    case openAIInputSettings
    case geminiSettings
    case geminiInputSettings
    case customAISettings
    case claudeSettings
    case fileViewer(group: MessageGroupSendable)
    
    static func ==(lhs: NavigationItem, rhs: NavigationItem) -> Bool {
        switch (lhs, rhs) {
        case (.commandDetail(let lCommand), .commandDetail(let rCommand)):
            return lCommand.id == rCommand.id
        case (.workflowDetail(let lWorkflow), .workflowDetail(let rWorkflow)):
            return lWorkflow.id == rWorkflow.id
        case (.chatGroup(let lGroup), .chatGroup(let rGroup)):
            return lGroup.id == rGroup.id
        case (.fileViewer(let lGroup), .fileViewer(let rGroup)):
            return lGroup.id == rGroup.id
        default:
            return lhs.hashValue == rhs.hashValue
        }
    }
    
    func hash(into hasher: inout Hasher) {
        let str = String(describing: self)
        switch self {
        case .commandDetail(let value):
            hasher.combine(str)
            hasher.combine(value.id.hashValue)
        case .workflowDetail(let value):
            hasher.combine(str)
            hasher.combine(value.id.hashValue)
        case .fileViewer(let value):
            hasher.combine(str)
            hasher.combine(value.id.hashValue)
        case .chatGroup(let value):
            hasher.combine(str)
            hasher.combine(value.id.hashValue)
        default:
            hasher.combine(str)
        }
    }
}

@Observable
@MainActor
final class NavigationViewModel {
    var selectedSidebarItem: NavigationItem? = nil
    var selectedDetailedItem: NavigationItem? = nil
}

extension NavigationViewModel {
    static func mock() -> Self {
        .init()
    }
}
