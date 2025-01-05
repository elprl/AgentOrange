//
//  WorkflowManager.swift
//  AgentOrange
//
//  Created by Paul Leo on 26/12/2024.
//

import Foundation
import Combine
import Factory
import SwiftData

enum ExecutionState {
    case pending
    case running
    case completed
    case failed
}

protocol WorkflowManagerProtocol: Actor {
    func run(workflow: Workflow, groupId: String, history: [ChatMessage]) async
    func run(command: ChatCommand, groupId: String, history: [ChatMessage], timestamp: Date) async -> ChatMessage?
    func stop(chatId: String)
}

actor WorkflowManager: WorkflowManagerProtocol {
    /* @Injected(\.commandService) */ @ObservationIgnored private var commandService: CommandServiceProtocol
    /* @Injected(\.dataService) */ @ObservationIgnored private var dataService: PersistentDataManagerProtocol
    @Injected(\.keychainService) @ObservationIgnored private var keychainService
    var isGenerating: [String: Bool] = [:]
    var commandStates: [ChatCommand: ExecutionState] = [:]

    // Inject any other services as needed
    init(container: ModelContainer) {
        self.dataService = Container.shared.dataService(container) // Injected PersistentDataManager(container: modelContext.container)
        self.commandService = Container.shared.commandService(container) // Injected CommandService(container: modelContext.container)
    }
    
    // this function will run the commands in the workflow. It will run in
    // in parallel the commands from different hosts. It will run serially if the commands on the same host.
    func run(workflow: Workflow, groupId: String, history: [ChatMessage]) async {
        commandStates = [:]
        await commandService.loadCommands()        
        await addChatMessage(content: workflow.shortDescription, type: .workflow, tag: workflow.name, groupId: groupId)
        
        if let arrangement = workflow.commandArrangement {
            let (commandIds, commands) = await getCommands(for: arrangement)
            let rowOrientedIds = process(commandIds: commandIds)
            var newChats: [ChatMessage] = []
            for (index, rowGroup) in rowOrientedIds.enumerated() {
                // the commands in this loop must complete before moving to the next row
                Log.agi.debug("Starting rowGroup: \(index)")
                await withTaskGroup(of: ChatMessage?.self) { taskGroup in
                    var timestamp = Date.now
                    for column in rowGroup {
                        let delay = Calendar.current.date(byAdding: .nanosecond, value: 1_000_000, to: timestamp) ?? Date.now
                        timestamp = delay
                        if let command = commands.first(where: { $0.name == column }) {
                            let commandCopy = command
                            let groupIdCopy = groupId
                            let historyCopy = history + newChats
                            taskGroup.addTask {
                                Log.agi.debug("Starting command: \(commandCopy.name)")
                                let newChat = await self.run(command: commandCopy, groupId: groupIdCopy, history: historyCopy, timestamp: delay)
                                Log.agi.debug("Finished command: \(commandCopy.name)")
                                return newChat
                            }
                        }
                    }
                    
                    // Collect results from the tasks
                    for await result in taskGroup {
                        if let newChat = result {
                            newChats.append(newChat)
                        }
                    }
                }
                Log.agi.debug("Finished rowGroup: \(index)")
            }
        }
    }
    
    private func getCommands(for arrangement: String) async -> ([[String]], [ChatCommand]) {
        do {
            let data = Data(arrangement.utf8)
            let decoder = JSONDecoder()
            var commandIds = try decoder.decode([[String]].self, from: data)
            commandIds = commandIds.filter { !$0.isEmpty }
            
            var commands: [ChatCommand] = []
            let flatternedCommandIds = commandIds.reduce([], +)
            for id in flatternedCommandIds {
                if let command = await commandService.commands.first(where: { $0.name == id }) {
                    if !commands.contains(command) {
                        commands.append(command)
                    }
                }
            }
            return (commandIds, commands)
        } catch {
            Log.pres.error("Error decoding command arrangement: \(error)")
            return ([], [])
        }
    }
    
    // process the commands into rows for execution. The commands in the same row will run in parallel
    private func process(commandIds: [[String]]) -> [[String]] {
        var newCommandIds : [[String]] = []
        for column in commandIds {
            for (index, row) in column.enumerated() {
                if newCommandIds.indices.contains(index) {
                    newCommandIds[index].append(row)
                } else {
                    newCommandIds.append([row])
                }
            }
        }
        return newCommandIds
    }
    
    private func processCommands(for host: String, groupId: String, history: [ChatMessage]) async {
        let commandsForHost = commandStates.keys.filter { $0.host == host }
        
        while commandStates.values.contains(.pending) || commandStates.values.contains(.running) {
            for command in commandsForHost {
                let depCommands = await dependentCommands(command: command)
                if await canExecute(command: command, depCommands: depCommands) {
                    commandStates[command] = .running
                    await run(command: command, groupId: groupId, history: history)
                    commandStates[command] = .completed
                }
            }
            // Avoid busy waiting
            try? await Task.sleep(nanoseconds: 100_000_000_000) // Sleep for 100ms
        }
    }
    
    private func canExecute(command: ChatCommand, depCommands: [ChatCommand]) async -> Bool {
        // Check if all dependencies are completed
        for depCommand in depCommands {
            if commandStates[depCommand] != .completed {
                return false
            }
        }
        return true
    }
    
    private func dependentCommands(command: ChatCommand) async -> [ChatCommand] {
        var commands: [ChatCommand] = []
        for cmdName in command.dependencyIds {
            if let command = await commandService.commands.first(where: { $0.name == cmdName }) {
                commands.append(command)
            }
        }
        return commands
    }
    
    @discardableResult func run(command: ChatCommand, groupId: String, history: [ChatMessage], timestamp: Date = Date.now) async -> ChatMessage? {
        let chatId = UUID().uuidString
        start(chatId: chatId)
        
        let content = """
**Host**: \(command.host) \n\n **Model**: \(command.model) \n\n **Prompt**: \n\n \(command.prompt)
"""
        await addChatMessage(timestamp: timestamp, content: content, type: .command, tag: command.name, groupId: groupId)
        
        let responseMessage = await addChatMessage(id: chatId, timestamp: timestamp, role: .assistant, content: "", model: command.model, host: command.host, groupId: groupId)
        
        do {
            let host = command.host
            let model = command.model
            
            var agiService: AGIStreamingServiceProtocol & AGIHistoryServiceProtocol
            switch host.lowercased() {
            case AGIServiceChoice.gemini.name.lowercased():
                let key = await getGeminiAPIKey()
                agiService = GeminiAPIService(apiKey: key)
            case AGIServiceChoice.openai.name.lowercased():
                let key = await getOpenAIAPIKey()
                agiService = ChatGPTAPIService(apiKey: key)
            case AGIServiceChoice.claude.name.lowercased():
                let key = await getClaudeAPIKey()
                agiService = ClaudeAPIService(apiKey: key)
            default:
                agiService = LMStudioAPIService()
            }
            
            await agiService.setHistory(messages: history)
            let stream = try await agiService.sendMessageStream(text: command.prompt, needsJSONResponse: false, host: host, model: model, temperature: 0.5)
            
            var tempOutput = ""
            for try await responseDelta in stream {
                if !isGenerating(chatId: chatId) {
                    break
                }
                tempOutput += responseDelta
                await updateMessage(message: responseMessage, content: tempOutput)
            }
            
            let finalOutput = tempOutput // await removeMarkdown(from: tempOutput)
            Log.pres.debug("AI Generated: \(finalOutput)")
            let finalChat = await updateMessage(message: responseMessage, content: tempOutput)
            
            if command.type == .coder {
                let codeSnippet: CodeSnippetSendable
                let subTitle = UserDefaults.standard.string(forKey: UserDefaults.Keys.selectedCodeTitle) ?? "Generated"
                
                codeSnippet = CodeSnippetSendable(title: command.name, code: finalOutput, subTitle: subTitle, groupId: groupId)
                // Add the code snippet to your data service or wherever needed
                await dataService.add(code: codeSnippet)
            }
            
            stop(chatId: chatId)
            return finalChat
        } catch {
            Log.pres.error("Error: \(error.localizedDescription)")
        }
        
        stop(chatId: chatId)
        return nil
    }
    
    @discardableResult private func addChatMessage(id: String = UUID().uuidString, timestamp: Date = Date.now, role: GPTRole = .user, content: String, type: MessageType = .message, tag: String? = nil, model: String? = nil, host: String? = nil, groupId: String) async -> ChatMessage {
        let chatMessage = ChatMessage(id: id, timestamp: timestamp, role: role, type: type, content: content, tag: tag, groupId: groupId, model: model, host: host)
        await persistChat(message: chatMessage)
        return chatMessage
    }
    
    @discardableResult private func updateMessage(message: ChatMessage, content: String, tag: String? = nil, codeId: String? = nil) async -> ChatMessage {
        var chat = message
        chat.content = content
        if let tag {
            chat.tag = tag
        }
        if let codeId {
            chat.codeId = codeId
        }
        await persistChat(message: chat)
        return chat
    }
    
    private func persistChat(message: ChatMessage) async {
        await dataService.add(message: message)
    }
    
    private func start(chatId: String) {
        isGenerating[chatId] = true
    }
    
    func stop(chatId: String) {
        isGenerating[chatId] = false
    }
    
    private func isGenerating(chatId: String) -> Bool {
        isGenerating[chatId] ?? false
    }
    
    // Helper methods to get API keys
    private func getClaudeAPIKey() async -> String? {
        return keychainService[AGIServiceChoice.claude.rawValue]?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func getOpenAIAPIKey() async -> String? {
        return keychainService[AGIServiceChoice.openai.rawValue]?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func getGeminiAPIKey() async -> String? {
        return keychainService[AGIServiceChoice.gemini.rawValue]?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
