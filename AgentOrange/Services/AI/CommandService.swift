//
//  Untitled.swift
//  AgentOrange
//
//  Created by Paul Leo on 11/12/2024.
//
typealias Workflows = [String: [String]]

protocol CommandServiceProtocol {
    var defaultCommands: [ChatCommand] { get }
    var workflows: Workflows { get set }
}

struct CommandService: CommandServiceProtocol {
    let defaultCommands: [ChatCommand] = [
        ChatCommand(name: "//correctness",
                    prompt: "Check the code carefully for correctness and security. Give helpful and constructive criticism for how to improve it.",
                    shortDescription: "Refactors the code",
                    role: "You are an expert reviewer of Swift 6 code.",
                    model: "meta-llama-3.1-8b-instruct",
                    host: "http://192.168.50.3:1234",
                    type: .reviewer),
        ChatCommand(name: "//styleReview",
                    prompt: "Review the code for adherence to the language's style guide and best practices.",
                    shortDescription: "Reviews code style",
                    role: "You are a Swift 6 code style expert in this language.",
                    model: "meta-llama-3.1-8b-instruct",
                    host: "http://192.168.50.3:1234",
                    type: .reviewer),
        ChatCommand(name: "//performance",
                    prompt: "Analyze the code for performance bottlenecks and provide optimization suggestions.",
                    shortDescription: "Optimizes performance",
                    role: "You are an expert in performance optimization for Swift 6.",
                    model: "meta-llama-3.1-8b-instruct",
                    host: "http://192.168.50.3:1234",
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
                    host: "claude",
                    type: .coder),
        ChatCommand(name: "//unittests",
                    prompt: "Create a suite of unit tests for this code using the new Swift Testing '#expect(...)' framework (NOT XCTest).",
                    shortDescription: "Adds unit tests",
                    role: "You are an expert professional Swift iOS engineer.",
                    model: "gpt-4o",
                    host: "openai",
                    type: .coder),
        ChatCommand(name: "//quickNimble",
                    prompt: "Create a suite of unit tests for this code using the Quick and Nimble framework and a describe(\"GIVEN...\") { context(\"WHEN...\") { it(\"THEN...\") }}} style.",
                    shortDescription: "Adds unit tests",
                    role: "You are an expert professional Swift iOS engineer.",
                    model: "gemini-2.0-flash-exp",
                    host: "gemini",
                    type: .coder),

    ]
    var workflows: Workflows = [
        "All": ["//correctness", "//styleReview", "//performance", "//comments", "//docC", "//printlogs", "//refactor", "//mocks", "//unittests", "//quickNimble"],
        "Testing" : ["//mocks", "//unittests", "//quickNimble"],
        "Documentation" : ["//comments", "//docC", "//printlogs"],
        "Correctness" : ["//correctness", "//styleReview", "//performance"],
        "ParallelTest" : ["//correctness", "//mocks"],
    ]
}

