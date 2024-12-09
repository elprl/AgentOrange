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
    @Injected(\.codeService) @ObservationIgnored private var codeService
    @Injected(\.cacheService) @ObservationIgnored private var cacheService
    /* @Injected(\.chatService) */ @ObservationIgnored private var chatService: PersistentGroupDataManagerProtocol & PersistentChatDataManagerProtocol
    @ObservationIgnored private var sessionIndex: Int = 0
    @ObservationIgnored private var cancellationTask: Task<Void, Never>?
    var chats: [ChatMessage] = []
    var isGenerating: Bool = false
    var question: String = ""
    var hasScrolledOffBottom: Bool = false
    var commands: [ChatCommand] = [
        ChatCommand(name: "//refactor", prompt: "Refactor the code", shortDescription: "Refactors the code"),
        ChatCommand(name: "//comments", prompt: "Add professional inline code comments while avoiding DocC documentation outside of functions.", shortDescription: "Adds code comments"),
        ChatCommand(name: "//docC", prompt: "Add professional DocC documentation to the code", shortDescription: "Adds code documentation"),
    ]
//    private let chatService: PersistentDataManager
    private var cancellable: AnyCancellable?
    var selectedGroup: MessageGroupSendable? {
        didSet {
            loadMessages()
        }
    }
    var selectedGroupId: String? {
        return selectedGroup?.groupId
    }
    var navTitle: String? {
        return selectedGroup?.title
    }

    /// pass nil for previews or unit testing
    init(modelContext: ModelContext) {
        self.chatService = Container.shared.chatService(modelContext.container) // Injected PersistentDataManager(container: modelContext.container)
    }
    
    func loadMessages() {
        Task { @MainActor in
            if let selectedGroupId = selectedGroupId {
                self.chats = await chatService.fetchData(for: selectedGroupId)
            }
        }
    }
    
    func streamResponse() {
        Task { @MainActor in
            let questionCopy = String(self.question.trimmingCharacters(in: .whitespacesAndNewlines))
            self.question = ""
            start()
            self.sessionIndex += 1
            let tag = "Version \(self.sessionIndex)"
            await respondToPrompt(prompt: questionCopy, tag: tag)
            stop()
        }
    }
    
    private func respondToPrompt(prompt: String, tag: String, isCmd: Bool = false) async {
        if isCmd {
            addChatMessage(content: "**Command**: " + tag + "\n**Prompt**: " + prompt)
        } else {
            addChatMessage(content: prompt)
        }
        let responseMessage = addChatMessage(role: .assistant, content: "")
        var tempOutput = ""
        await Task.detached { [weak self] in
            do {
                guard let self else { return }
                await self.agiService.setHistory(messages: generateHistory())
                let stream = try await self.agiService.sendMessageStream(text: prompt, needsJSONResponse: false)
                for try await responseDelta in stream {
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
                        if let id = self?.codeService.addCode(code: finalOutput, tag: tag) {
                            self?.codeService.selectedId = id
                            self?.cacheService.saveFileContent(for: id, fileContent: finalOutput)
                            self?.updateMessage(message: responseMessage, content: finalOutput, tag: tag, codeId: id)
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
    func runCommands() {
        Task { @MainActor in
            start()
            for command in commands {
                if isGenerating {
                    await respondToPrompt(prompt: command.prompt, tag: command.name, isCmd: true)
                }
            }
            stop()
        }
    }
    
    @MainActor
    @discardableResult private func addChatMessage(role: GPTRole = .user, content: String, type: MessageType = .message, tag: String? = nil) -> ChatMessage {
        let chatMessage = ChatMessage(role: role, type: type, content: content, tag: tag, groupId: selectedGroupId)
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
            await chatService.add(message: message)
        }
    }
    
    func start() {
        isGenerating = true
    }
    
    func stop() {
        isGenerating = false
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
            history.append(ChatMessage(role: .system, content: systemPrompt))
        }
        if defaults.scopeHistory {
            history.append(contentsOf: chats)
        }
        if defaults.scopeCode {
            if let code = codeService.currentSelectedCode {
                history.append(ChatMessage(role: .user, content: code))
            }
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
        if defaults.object(forKey: Scope.code.rawValue) == nil {
            defaults.scopeCode = true
        }
        if defaults.object(forKey: Scope.genCode.rawValue) == nil {
            defaults.scopeGenCode = false
        }
    }
    
    @MainActor
    func deleteAll() {
        Task {
            await chatService.delete(messages: chats)
        }
        chats.removeAll()
    }
    
    @MainActor
    func delete(message: ChatMessage) {
        Task {
            await chatService.delete(message: message)
        }
        if let index = chats.firstIndex(where: { $0.id == message.id }) {
            chats.remove(at: index)
        }
    }
    
    @MainActor
    func delete(group: CDMessageGroup) {
        let groupSendable = group.sendableModel
        Task {
            await chatService.delete(group: groupSendable)
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
            await chatService.add(group: groupSendable)
        }
    }
}

#if DEBUG

extension AIChatViewModel {
    @MainActor static func mock() -> AIChatViewModel {
        let vm = AIChatViewModel(modelContext: PreviewController.chatsPreviewContainer.mainContext)
        vm.chats = [
            ChatMessage(role: .user, content: "Give me an attribute string from plain string"),
            ChatMessage(role: .assistant, content: "return try AttributedString(markdown: response, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))", tag: "CodeGen1"),
            ChatMessage(role: .user, content: "blah blah"),
            ChatMessage(role: .assistant, content: "return try AttributedString(markdown: response, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))", tag: "CodeGen1")
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
