//
//  ScopeBarView.swift
//  AgentOrange
//
//  Created by Paul Leo on 05/12/2024.
//

import SwiftUI

struct ScopeBarView: View {
    @Environment(FileViewerViewModel.self) private var codeVM: FileViewerViewModel
    @AppStorage(Scope.role.rawValue) private var systemScope: Bool = true
    @AppStorage(Scope.code.rawValue) private var codeScope: Bool = true
    @AppStorage(Scope.history.rawValue) private var historyScope: Bool = true

    var body: some View {
#if DEBUG
let _ = Self._printChanges()
#endif
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Text("Scopes: ")
                ToggleButton(title: Scope.role.rawValue, isOn: $systemScope, onColor: .orange) {}
                if let tag = codeVM.selectedVersion?.tag {
                    ToggleButton(title: "\(Scope.code.rawValue): \(tag)", isOn: $codeScope, onColor: .orange) {}
                }
                ToggleButton(title: Scope.history.rawValue, isOn: $historyScope, onColor: .orange) {}
                Spacer()
            }
        }
        .transition(.opacity)
        .padding(.vertical, 4)
        .padding(.horizontal)
    }
}

#Preview {
    ScopeBarView()
        .environment(FileViewerViewModel())
}
