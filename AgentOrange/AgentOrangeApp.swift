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
    @AppStorage("darkLightAutoMode") var darkLightAutoMode: UIUserInterfaceStyle = .unspecified
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CDChatMessage.self, CDMessageGroup.self, CDCodeSnippet.self, CDChatCommand.self
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
    @State private var commandVM: CommandListViewModel
    @State private var navVM: NavigationViewModel

    init() {
        let modelContext = sharedModelContainer.mainContext
        _codeVM = State(initialValue: FileViewerViewModel(modelContext: modelContext))
        _aiVM = State(initialValue: AIChatViewModel(modelContext: modelContext))
        _commandVM = State(initialValue: CommandListViewModel(modelContext: modelContext))
        _navVM = State(initialValue: NavigationViewModel())
    }
    
    var body: some Scene {
        WindowGroup {
            TDSplitView()
                .environment(codeVM)
                .environment(aiVM)
                .environment(commandVM)
                .environment(navVM)
                .modelContainer(sharedModelContainer)
                .preferredColorScheme(ColorScheme(darkLightAutoMode)) // tint on status bar
        }
    }
}
