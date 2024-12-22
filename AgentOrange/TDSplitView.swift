//
//  TDSplitView.swift
//  AgentOrange
//
//  Created by Paul Leo on 03/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import SwiftUI

struct TDSplitView: View {
    @Environment(FileViewerViewModel.self) private var viewModel: FileViewerViewModel
    @Environment(AIChatViewModel.self) private var chatVM: AIChatViewModel
    @Environment(NavigationViewModel.self) private var navVM: NavigationViewModel
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        NavigationSplitView(columnVisibility: $columnVisibility) {
            /* Column 1 */
            SideBarSUI()
        } content: {
            /* Column 2 */
            switch navVM.selectedNavigationItem {
            case .chatGroup(_):
                NavigationStack {
                    AIChatView()
                }
            case .commandList, .commandDetail:
                NavigationStack {
                    CommandListView()
                }
            case .workflowList, .workflowDetail:
                NavigationStack {
                    WorkflowListView()
                }                
            default:
                NavigationStack {
                    Text("Select an item")
                }
            }
        } detail: {
            /* Column 3 */
            switch navVM.selectedNavigationItem {
            case .chatGroup(let group):
                NavigationStack {
                    FileViewerSUI(groupId: group.groupId)
                }
            case .commandDetail(let command):
                CommandDetailedView(command: command)
                    .environment(viewModel)
            default:
                NavigationStack {
                    Text("Select an item")
                }
            }
        }
        .tint(.white)
    }
}

#Preview {
    TDSplitView()
        .environment(FileViewerViewModel.mock())
}
