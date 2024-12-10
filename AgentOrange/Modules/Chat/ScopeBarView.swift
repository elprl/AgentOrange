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
    @AppStorage(Scope.genCode.rawValue) private var genCodeScope: Bool = true

    var body: some View {
#if DEBUG
let _ = Self._printChanges()
#endif
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Text("Scopes: ")
                if let tag = codeVM.selectedSnippet?.title {
                    ToggleButton(title: "\(Scope.code.rawValue): \(tag)", isOn: $codeScope, onColor: .accent) {}
                }
                ToggleButton(title: Scope.genCode.rawValue, isOn: $genCodeScope, onColor: .accent) {}
                ToggleButton(title: Scope.history.rawValue, isOn: $historyScope, onColor: .accent) {}
                ToggleButton(title: Scope.role.rawValue, isOn: $systemScope, onColor: .accent) {}
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
        .environment(FileViewerViewModel(modelContext: PreviewController.messageGroupPreviewContainer.mainContext))
}
