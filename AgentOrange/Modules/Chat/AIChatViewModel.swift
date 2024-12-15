//
//  AIChatViewModel.swift
//  AgentOrange
//
//  Created by Paul Leo on 03/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import SwiftUI
import Factory
import SwiftData
import Combine

@Observable
@MainActor
final class AIChatViewModel {
    @Injected(\.agiService) @ObservationIgnored private var agiService
    @Injected(\.parserService) @ObservationIgnored private var parserService
    @Injected(\.commandService) @ObservationIgnored private var commandService
    /* @Injected(\.dataService) */ @ObservationIgnored private var dataService: PersistentDataManagerProtocol
    @ObservationIgnored private var sessionIndex: Int = 0
    @ObservationIgnored private var cancellationTask: Task<Void, Never>?
    var chats: [ChatMessage] = []
    var isGenerating: [String: Bool] = [:]
    var question: String = ""
    var hasScrolledOffBottom: Bool = false
    var commands: [ChatCommand] {
        commandService.defaultCommands
    }
    var workflows: Workflows {
        commandService.workflows
    }
    var workflowNames: [String] {
        workflows.keys.map { $0 }
    }
    var isAnyGenerating: Bool {
        isGenerating.values.contains(true)
    }
    
//    private let chatService: PersistentDataManager
    private var cancellable: AnyCancellable?
    var selectedGroup: MessageGroupSendable? {
        didSet {
            loadMessages()
            self.selectedGroupId = selectedGroup?.groupId
        }
    }
    var selectedGroupId: String?
    var navTitle: String? {
        return selectedGroup?.title
    }

    /// pass nil for previews or unit testing
    init(modelContext: ModelContext) {
        self.dataService = Container.shared.dataService(modelContext.container) // Injected PersistentDataManager(container: modelContext.container)
    }
    
    func loadMessages() {
        Task { @MainActor in
            if let selectedGroupId = selectedGroupId {
                self.chats = await dataService.fetchData(for: selectedGroupId)
            }
        }
    }
    
    func streamResponse() {
        Task { @MainActor in
            let questionCopy = String(self.question.trimmingCharacters(in: .whitespacesAndNewlines))
            self.question = ""
            let chatId = UUID().uuidString
            start(chatId: chatId)
            self.sessionIndex += 1
            let tag = "Version \(self.sessionIndex)"
            await respondToPrompt(id: chatId, prompt: questionCopy, tag: tag)
            stop(chatId: chatId)
        }
    }
    
    func isGenerating(chatId: String) -> Bool {
        isGenerating[chatId] ?? false
    }
    
    func stopAll() {
        isGenerating.keys.forEach {
            stop(chatId: $0)
        }
    }
    
    private func respondToPrompt(id: String = UUID().uuidString,
                                 prompt: String,
                                 tag: String,
                                 isCmd: Bool = false,
                                 history: [ChatMessage]? = nil,
                                 subTitle: String? = UserDefaults.standard.string(forKey: UserDefaults.Keys.selectedCodeTitle),
                                 host: String = UserDefaults.standard.customAIHost ?? "http://localhost:1234",
                                 model: String = UserDefaults.standard.customAIModel ?? "qwen2.5-coder-32b-instruct") async {
        if isCmd {
            addChatMessage(content: "**Command**: " + tag + "\n**Prompt**: " + prompt)
        } else {
            addChatMessage(content: prompt)
        }
        let responseMessage = addChatMessage(id: id, role: .assistant, content: "", model: model, host: host)
        var tempOutput = ""
        await Task.detached { [weak self] in
            do {
                guard let self else { return }
                if let history = history {
                    await self.agiService.setHistory(messages: history)
                } else {
                    await self.agiService.setHistory(messages: generateHistory())
                }
                let stream = try await self.agiService.sendMessageStream(text: prompt, needsJSONResponse: false, host: host, model: model)
                for try await responseDelta in stream {
                    if await !self.isGenerating(chatId: responseMessage.id) {
                        break
                    }
                    tempOutput += responseDelta
                    let readonlyOutput = tempOutput
                    DispatchQueue.main.async { [weak self] in
                        self?.updateMessage(message: responseMessage, content: readonlyOutput)
                    }
                }
                let finalOutput = await removeMarkdown(from: tempOutput)
                Log.pres.debug("AI Generated: \(tempOutput)")
                DispatchQueue.main.async { [weak self] in
                    if UserDefaults.standard.scopeGenCode {
                        let codeSnippet: CodeSnippetSendable
                        if let subTitle {
                            codeSnippet = CodeSnippetSendable(title: tag, code: finalOutput, subTitle: subTitle, groupId: self?.selectedGroupId ?? "1")
                        } else {
                            codeSnippet = CodeSnippetSendable(title: tag, code: finalOutput, subTitle: "Generated", groupId: self?.selectedGroupId ?? "1")
                        }
                        self?.updateMessage(message: responseMessage, content: finalOutput, tag: tag, codeId: codeSnippet.id)
                        Task {
                            await self?.dataService.add(code: codeSnippet)
                        }
                    }
                }
            } catch {
                Log.pres.error("Error: \(error.localizedDescription)")
                tempOutput += "\n\(error.localizedDescription)"
                let readonlyOutput = tempOutput
                DispatchQueue.main.async { [weak self] in
                    self?.updateMessage(message: responseMessage, content: readonlyOutput)
                }
            }
        }.value
    }
    
    private func removeMarkdown(from content: String) -> String {
        let header1 = "```swift\n"
        let header2 = "```\n"
        let footer = "\n```"
        var output = content
        if content.hasPrefix(header1) {
            output = content.replacingOccurrences(of: header1, with: "")
        } else if content.hasPrefix(header2) {
            output = content.replacingOccurrences(of: header2, with: "")
        }
        if content.hasSuffix(footer) {
            output = output.replacingOccurrences(of: footer, with: "")
        }
        return output
    }
    
    // the following function loops over the commands array and calls one at a time to the respondToPrompt function
    func runWorkflow(name: String) {
        Task { @MainActor in
            let history = generateHistory() // capture scopes to prevent changes during browsing
            let subTitle = UserDefaults.standard.string(forKey: UserDefaults.Keys.selectedCodeTitle)
            if let cmdNames = workflows[name] {
                for command in commandService.defaultCommands {
                    if cmdNames.contains(command.name) {
                        let chatId = UUID().uuidString
                        start(chatId: chatId)
                        let host = command.host ?? UserDefaults.standard.customAIHost ?? "http://localhost:1234"
                        let model = command.model ?? UserDefaults.standard.customAIModel ?? "qwen2.5-coder-32b-instruct"
                        await respondToPrompt(id: chatId,
                                              prompt: command.prompt,
                                              tag: command.type == .coder ? command.name : "",
                                              isCmd: true,
                                              history: history,
                                              subTitle: subTitle,
                                              host: host,
                                              model: model)
                        stop(chatId: chatId)
                    }
                }
            }
        }
    }
    
    func runCommand(command: ChatCommand) {
        Task { @MainActor in
            let chatId = UUID().uuidString
            start(chatId: chatId)
            let history = generateHistory()
            let subTitle = UserDefaults.standard.string(forKey: UserDefaults.Keys.selectedCodeTitle)
            let host = command.host ?? UserDefaults.standard.customAIHost ?? "http://localhost:1234"
            let model = command.model ?? UserDefaults.standard.customAIModel ?? "qwen2.5-coder-32b-instruct"
            await respondToPrompt(id: chatId,
                                  prompt: command.prompt,
                                  tag: command.name,
                                  isCmd: true,
                                  history: history,
                                  subTitle: subTitle,
                                  host: host,
                                  model: model)
            stop(chatId: chatId)
        }
    }
    
    @MainActor
    @discardableResult private func addChatMessage(id: String = UUID().uuidString, role: GPTRole = .user, content: String, type: MessageType = .message, tag: String? = nil, model: String? = nil, host: String? = nil) -> ChatMessage {
        let chatMessage = ChatMessage(id: id, role: role, type: type, content: content, tag: tag, groupId: selectedGroupId ?? "1", model: model, host: host)
        chats.append(chatMessage)
        persistChat(message: chatMessage)
        return chatMessage
    }
    
    @MainActor
    private func updateMessage(message: ChatMessage, content: String, tag: String? = nil, codeId: String? = nil) {
        guard var chat = chats.first(where: { $0.id == message.id } ) else {
            return
        }
        chat.content = content
        if let tag {
            chat.tag = tag
        }
        if let codeId {
            chat.codeId = codeId
        }
        chats.safeReplace(chat) // replace the chat message with the updated one
        persistChat(message: chat)
    }
    
    func persistChat(message: ChatMessage) {
        Task {
            await dataService.add(message: message)
        }
    }
    
    func start(chatId: String) {
        isGenerating[chatId] = true
    }
    
    func stop(chatId: String) {
        isGenerating[chatId] = false
        cancellationTask?.cancel()
    }
    
    @MainActor
    private func generateHistory() -> [ChatMessage] {
        var history: [ChatMessage] = []
        setScopeDefaults()
        let defaults = UserDefaults.standard
        if defaults.scopeRole {
            var systemPrompt = "You are an experienced professional Swift iOS engineer."
            if defaults.scopeGenCode {
                systemPrompt += " All your responses must contain swift code ONLY without Markdown."
            }
            history.append(ChatMessage(role: .system, content: systemPrompt, groupId: selectedGroupId ?? "1"))
        }
        if defaults.scopeHistory {
            history.append(contentsOf: chats)
        }
        for snippet in parserService.scopedCodeFiles {
            history.append(ChatMessage(role: .user, content: snippet.code, groupId: selectedGroupId ?? "1"))
        }
        return history
    }
    
    private func setScopeDefaults() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Scope.role.rawValue) == nil {
            defaults.scopeRole = true
        }
        if defaults.object(forKey: Scope.history.rawValue) == nil {
            defaults.scopeHistory = true
        }
        if defaults.object(forKey: Scope.genCode.rawValue) == nil {
            defaults.scopeGenCode = false
        }
    }
    
    @MainActor
    func deleteAll() {
        Task { @MainActor in
            await dataService.delete(messages: chats)
            chats.removeAll()
        }
    }
    
    @MainActor
    func delete(message: ChatMessage) {
        Task {
            await dataService.delete(message: message)
        }
        if let index = chats.firstIndex(where: { $0.id == message.id }) {
            chats.remove(at: index)
        }
    }
    
    @MainActor
    func delete(group: CDMessageGroup) {
        let groupSendable = group.sendableModel
        Task {
            await dataService.delete(group: groupSendable)
        }
        if groupSendable.groupId == selectedGroupId {
            addGroup()
        }
    }
    
    @MainActor
    func addGroup() {
        let groupSendable = MessageGroupSendable(title: "Chat #\(UUID().uuidString.prefix(5))")
        selectedGroup = groupSendable
        Task {
            await dataService.add(group: groupSendable)
        }
    }
}

#if DEBUG

extension AIChatViewModel {
    @MainActor static func mock() -> AIChatViewModel {
        let vm = AIChatViewModel(modelContext: PreviewController.chatsPreviewContainer.mainContext)
        vm.chats = [
            ChatMessage(role: .user, content: "Give me an attribute string from plain string", groupId: "1"),
            ChatMessage(role: .assistant, content: "return try AttributedString(markdown: response, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))", tag: "CodeGen1", groupId: "1"),
            ChatMessage(role: .user, content: "blah blah", groupId: "1"),
            ChatMessage(role: .assistant, content: "return try AttributedString(markdown: response, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))", tag: "CodeGen1", groupId: "1")
        ]
        return vm
    }
}

#endif

extension Array where Iterator.Element == ChatMessage {
    mutating func safeReplace(_ newElement: Element)  {
        if let index = self.firstIndex(where: { $0.id == newElement.id }) {
            self[index] = newElement
        }
    }
}
