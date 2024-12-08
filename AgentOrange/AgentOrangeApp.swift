//
//  AgentOrangeApp.swift
//  AgentOrange
//
//  Created by Paul Leo on 03/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import SwiftUI
import SwiftData

@main
struct AgentOrangeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CDChatMessage.self, CDMessageGroup.self, CDCodeSnippet.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    @State private var codeVM: FileViewerViewModel
    @State private var aiVM: AIChatViewModel
    
    init() {
        let modelContext = sharedModelContainer.mainContext
        _codeVM = State(initialValue: FileViewerViewModel(modelContext: modelContext))
        _aiVM = State(initialValue: AIChatViewModel(modelContext: modelContext))
    }
    
    var body: some Scene {
        WindowGroup {
            TDSplitView()
                .environment(codeVM)
                .environment(aiVM)
                .modelContainer(sharedModelContainer)
        }
    }
}
