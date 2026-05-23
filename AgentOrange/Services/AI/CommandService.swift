//
//  Untitled.swift
//  AgentOrange
//
//  Created by Paul Leo on 11/12/2024.
//
import Factory
import SwiftData
import Foundation

typealias Workflows = [String: [String]]

protocol CommandServiceProtocol: Actor {
    var defaultCommands: [ChatCommand] { get }
    var commands: [ChatCommand] { get set }
    func loadCommands() async
    func resetToDefaults() async
    var workflows: [Workflow] { get set }
    func loadWorkflows() async
    func add(command: ChatCommand) async
    func delete(command: ChatCommand) async
    func deleteAllCommands() async
}

actor CommandService: CommandServiceProtocol {
    /* @Injected(\.dataService) */ @ObservationIgnored private var dataService: any PersistentDataManagerProtocol
    
    var defaultCommands: [ChatCommand] = DefaultCommands.all
    var commands: [ChatCommand] = []
    
    init(container: ModelContainer) {
        self.dataService = Container.shared.dataService(container) // Injected PersistentDataManager(container: modelContext.container)
        let hasLoadedDefaultCommand = UserDefaults.standard.bool(forKey: "hasLoadedDefaultCommand")
        if !hasLoadedDefaultCommand {
            defaultCommands.forEach { command in
                Task {
                    await dataService.add(command: command)
                }
            }
            UserDefaults.standard.set(true, forKey: "hasLoadedDefaultCommand")
        }
    }
    
    func loadCommands() async {
        self.commands = await dataService.fetchAllCommands()
    }
    
    func resetToDefaults() {
        defaultCommands.forEach { command in
            Task {
                await dataService.add(command: command)
            }
        }
    }
    
    var workflows: [Workflow] = []
    
    func loadWorkflows() async {
        self.workflows = await dataService.fetchAllWorkflows()
    }

    func add(command: ChatCommand) async {
        await dataService.add(command: command)
    }
    
    func delete(command: ChatCommand) async {
        await dataService.delete(command: command)
    }
    
    func deleteAllCommands() async {
        await dataService.deleteAllCommands()
    }
}

