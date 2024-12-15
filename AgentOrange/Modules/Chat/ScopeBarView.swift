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
        scopes
        files
    }
    
    @ViewBuilder
    private var scopes: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Text("Scopes: ")
                ToggleButton(title: Scope.role.rawValue, isOn: $systemScope, onColor: .accent) {}
                ToggleButton(title: Scope.history.rawValue, isOn: $historyScope, onColor: .accent) {}
                ToggleButton(title: Scope.genCode.rawValue, isOn: $genCodeScope, onColor: .accent) {}
                Spacer()
            }
        }
        .transition(.opacity)
        .padding(.vertical, 4)
        .padding(.horizontal)
    }

    @ViewBuilder
    private var files: some View {
        if !codeVM.scopedFiles.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack {
                    ForEach(codeVM.scopedFiles, id: \.self) { fileName in
                        HStack(alignment: .center) {
                            Image(systemName: "text.page.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 14, height: 14, alignment: .center)
                            Text(fileName.title)
                                .font(.system(size: 14))
                            Button {
                                codeVM.removeFromScope(snippetId: fileName.codeId)
                            } label: {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 14, height: 14, alignment: .center)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .foregroundStyle(.white)
                        .background(
                            ZStack {
                                Color.accent
                                Capsule()
                                    .stroke(.accent, lineWidth: 3)
                            }
                        )
                        .contentShape(Capsule())
                        .clipShape(Capsule())
                    }
                    Spacer()
                }
            }
            .transition(.opacity)
            .padding(.vertical, 4)
            .padding(.horizontal)
        }
    }
}

#Preview {
    ScopeBarView()
        .environment(FileViewerViewModel(modelContext: PreviewController.messageGroupPreviewContainer.mainContext))
}
