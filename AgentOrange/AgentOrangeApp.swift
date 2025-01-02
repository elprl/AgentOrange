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
            CDChatMessage.self, CDMessageGroup.self, CDCodeSnippet.self, CDChatCommand.self, CDWorkflow.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
#if DEBUG
            let urlApp = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
            let url = urlApp!.appendingPathComponent("default.store")
            if FileManager.default.fileExists(atPath: url.path) {
                print("swiftdata db at \(url.absoluteString)")
                fatalError("Error: could not create ModelContainer in AgentOrangeApp for db at \(url.absoluteString): \(error)")
            }
#endif
            fatalError("Error: could not create ModelContainer in AgentOrangeApp: \(error)")
        }
    }()
    @State private var navVM: NavigationViewModel
    @State private var codeVM: FileViewerViewModel
    @State private var aiVM: AIChatViewModel

    init() {
        _navVM = State(initialValue: NavigationViewModel())
        let modelContext = sharedModelContainer.mainContext
        _codeVM = State(initialValue: FileViewerViewModel(modelContext: modelContext))
        _aiVM = State(initialValue: AIChatViewModel(modelContext: modelContext))
    }
    
    var body: some Scene {
        WindowGroup {
            TDSplitView()
                .environment(codeVM)
                .environment(aiVM)
                .environment(navVM)
                .modelContainer(sharedModelContainer)
                .preferredColorScheme(ColorScheme(darkLightAutoMode)) // tint on status bar
        }
    }
}
