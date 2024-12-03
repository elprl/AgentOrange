//
//  TDSplitView.swift
//  LLMJsonTestHarness
//
//  Created by Paul Leo on 03/12/2024.
//

import SwiftUI

struct TDSplitView: View {
    var body: some View {
        NavigationSplitView {
            /* Column 1 */
            SideBarSUI(selection: .constant("code"))
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
                FileViewerSUI()
            }
        }
        .tint(.white)
    }
}

#Preview {
    TDSplitView()
}
