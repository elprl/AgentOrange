//
//  AgentOrangeApp.swift
//  AgentOrange
//
//  Created by Paul Leo on 03/12/2024.
//

import SwiftUI
import SwiftData

@main
struct AgentOrangeApp: App {
    @State private var codeVM: FileViewerViewModel = FileViewerViewModel()
    @State private var aiVM: AIChatViewModel = AIChatViewModel()
    
    var body: some Scene {
        WindowGroup {
            TDSplitView()
                .environment(codeVM)
                .environment(aiVM)
        }
    }
}
