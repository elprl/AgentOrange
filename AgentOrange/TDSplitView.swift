//
//  TDSplitView.swift
//  AgentOrange
//
//  Created by Paul Leo on 03/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import SwiftUI

struct TDSplitView: View {
    @Environment(\.modelContext) private var modelContext
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
            @Bindable var nav = navVM
            NavigationStack {
                switch navVM.selectedSidebarItem {
                case .chatGroup(let group):
                    AIChatView(groupId: group.groupId)
                case .commandList:
                    CommandListView(modelContext: modelContext)
                case .workflowList:
                    WorkflowListView(modelContext: modelContext)
                default:
                    selectSidedbarItem
                }
            }
        } detail: {
            /* Column 3 */
            NavigationStack {
                switch navVM.selectedDetailedItem {
                case .fileViewer(let group):
                    FileViewerSUI(groupId: group.groupId)
                case .commandDetail(let command):
                    CommandDetailedView(command: command, modelContext: modelContext)
                case .workflowDetail(let workflow):
                    WorkflowDetailedView(workflow: workflow, modelContext: modelContext)
                default:
                    selectDetailedItem
                }
            }
        }
        .tint(.white)
    }
    
    @ViewBuilder
    private var selectDetailedItem: some View {
        VStack {
            Text("Select an item")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.secondarySystemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.accent, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    @ViewBuilder
    private var selectSidedbarItem: some View {
        VStack {
            Text("Select sidebar menu item")
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.accent, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    TDSplitView()
        .environment(NavigationViewModel.mock())
}
