//
//  TDSplitView.swift
//  AgentOrange
//
//  Created by Paul Leo on 03/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import SwiftUI

struct TDSplitView: View {
    @Environment(FileViewerViewModel.self) private var viewModel: FileViewerViewModel
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        NavigationSplitView(columnVisibility: $columnVisibility) {
            /* Column 1 */
            SideBarSUI()
                .navigationSplitViewColumnWidth(240)
        } content: {
            /* Column 2 */
            NavigationStack {
                AIChatView()
            }
            .navigationSplitViewColumnWidth(min: 320, ideal: 420, max: .infinity)
        } detail: {
            /* Column 3 */
            NavigationStack {
                FileViewerSUI(groupId: viewModel.selectedGroupId)
            }
        }
        .tint(.white)
    }
}

#Preview {
    TDSplitView()
        .environment(FileViewerViewModel.mock())
}
