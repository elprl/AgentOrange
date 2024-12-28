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
    var defaultWorkflows: Workflows { get set }
    func loadWorkflows() async
    func save(command: ChatCommand) async
    func delete(command: ChatCommand) async
    func deleteAllCommands() async
}

actor CommandService: CommandServiceProtocol {
    /* @Injected(\.dataService) */ @ObservationIgnored private var dataService: PersistentDataManagerProtocol
    
    let defaultCommands: [ChatCommand] = [
        ChatCommand(name: "//correctness",
                    prompt: "Check the code carefully for correctness and security. Give helpful and constructive criticism for how to improve it.",
                    shortDescription: "Refactors the code",
                    role: "You are an expert reviewer of Swift 6 code.",
                    model: "qwen2.5-coder-32b-instruct",
                    host: "http://localhost:1234",
                    type: .reviewer),
        ChatCommand(name: "//styleReview",
                    prompt: "Review the code for adherence to the language's style guide and best practices.",
                    shortDescription: "Reviews code style",
                    role: "You are a Swift 6 code style expert in this language.",
                    model: "qwen2.5-coder-32b-instruct",
                    host: "http://localhost:1234",
                    type: .reviewer),
        ChatCommand(name: "//performance",
                    prompt: "Analyze the code for performance bottlenecks and provide optimization suggestions.",
                    shortDescription: "Optimizes performance",
                    role: "You are an expert in performance optimization for Swift 6.",
                    model: "qwen2.5-coder-32b-instruct",
                    host: "http://localhost:1234",
                    type: .reviewer),
        
        ChatCommand(name: "//comments",
                    prompt: "Add professional inline code comments while avoiding DocC documentation outside of functions.",
                    shortDescription: "Adds code comments",
                    role: "You are an expert professional Swift iOS engineer.",
                    type: .coder),
        ChatCommand(name: "//docC",
                    prompt: "Add professional DocC documentation to the code.",
                    shortDescription: "Adds code documentation",
                    role: "You are an expert professional Swift iOS engineer.",
                    type: .coder),
        ChatCommand(name: "//printlogs",
                    prompt: "Add or enhance logging in the code to make debugging and monitoring easier.",
                    shortDescription: "Improves logging",
                    role: "You are a monitoring and logging expert.",
                    type: .coder),
        ChatCommand(name: "//refactor",
                    prompt: "Refactor the code to improve readability, maintainability, and performance (for Swift 6).",
                    shortDescription: "Refactors the code",
                    role: "You are an expert professional Swift iOS engineer specializing in clean code.",
                    type: .coder),
        
        ChatCommand(name: "//mocks",
                    prompt: "Create mock-based objects for use within unit tests but don't create the unit tests.",
                    shortDescription: "Adds mock objects",
                    role: "You are an expert professional Swift iOS engineer in writing dependency-mock objects.",
                    model: "claude-3-5-sonnet-latest",
                    host: AGIServiceChoice.claude.name,
                    type: .coder),
        ChatCommand(name: "//unittests",
                    prompt: "Create a suite of unit tests for this code using the new Swift Testing '#expect(...)' framework (NOT XCTest).",
                    shortDescription: "Adds unit tests",
                    role: "You are an expert professional Swift iOS engineer.",
                    model: "gpt-4o",
                    host: AGIServiceChoice.openai.name,
                    type: .coder),
        ChatCommand(name: "//quickNimble",
                    prompt: "Create a suite of unit tests for this code using the Quick and Nimble framework and a describe(\"GIVEN...\") { context(\"WHEN...\") { it(\"THEN...\") }}} style.",
                    shortDescription: "Adds unit tests",
                    role: "You are an expert professional Swift iOS engineer.",
                    model: "gemini-2.0-flash-exp",
                    host: AGIServiceChoice.gemini.name,
                    type: .coder),

    ]
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
    var defaultWorkflows: Workflows = [
        "All": ["//correctness", "//styleReview", "//performance", "//comments", "//docC", "//printlogs", "//refactor", "//mocks", "//unittests", "//quickNimble"],
        "Testing" : ["//mocks", "//unittests", "//quickNimble"],
        "Documentation" : ["//comments", "//docC", "//printlogs"],
        "Correctness" : ["//correctness", "//styleReview", "//performance"],
        "ParallelTest" : ["//correctness", "//mocks"],
    ]
    
    func loadWorkflows() async {
        self.workflows = await dataService.fetchAllWorkflows()
    }

    func save(command: ChatCommand) async {
        await dataService.add(command: command)
    }
    
    func delete(command: ChatCommand) async {
        await dataService.delete(command: command)
    }
    
    func deleteAllCommands() async {
        await dataService.deleteAllCommands()
    }
}

