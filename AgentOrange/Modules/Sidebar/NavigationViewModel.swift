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
