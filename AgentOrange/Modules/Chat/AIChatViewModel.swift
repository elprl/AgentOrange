//
//  AIChatViewModel.swift
//  AgentOrange
//
//  Created by Paul Leo on 03/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import SwiftUI
import Factory

@Observable
final class AIChatViewModel {
    @Injected(\.agiService) @ObservationIgnored private var agiService
    @Injected(\.codeService) @ObservationIgnored private var codeService
    @Injected(\.cacheService) @ObservationIgnored private var cacheService
    var chats: [UUID: ChatMessage] = [:]
    var isGenerating: Bool = false
    var question: String = ""
    @ObservationIgnored private var sessionIndex: Int = 0

    func streamResponse() {
        Task { @MainActor in
            let questionCopy = String(self.question.trimmingCharacters(in: .whitespacesAndNewlines))
            self.question = ""
            start()
            addChatMessage(content: questionCopy)
            self.sessionIndex += 1
            let tag = "Version \(self.sessionIndex)"
            let responseMessage = addChatMessage(role: .assistant, content: "")
            var tempOutput = ""
            do {
                agiService.setHistory(messages: generateHistory())
                let stream = try await agiService.sendMessageStream(text: questionCopy, needsJSONResponse: false)
                for try await responseDelta in stream {
                    tempOutput += responseDelta
                    updateMessage(message: responseMessage, content: tempOutput)
                }
                Log.pres.debug("AI Generated: \(tempOutput)")
                if UserDefaults.standard.scopeGenCode {
                    if let id = codeService.addCode(code: tempOutput, tag: tag) {
                        codeService.selectedId = id
                        updateMessage(message: responseMessage, content: tempOutput, tag: tag, codeId: id)
                        cacheService.saveFileContent(for: id, fileContent: tempOutput)
                    }
                }
            } catch {
                Log.pres.error("Error: \(error.localizedDescription)")
                tempOutput += "\n\(error.localizedDescription)"
                updateMessage(message: responseMessage, content: tempOutput)
            }
            stop()
        }
    }
    
    @discardableResult private func addChatMessage(role: GPTRole = .user, content: String, type: MessageType = .message, tag: String? = nil) -> ChatMessage {
        let chatMessage = ChatMessage(role: role, type: type, content: content, tag: tag)
        chats[chatMessage.id] = chatMessage
        return chatMessage
    }
    
    private func updateMessage(message: ChatMessage, content: String, tag: String? = nil, codeId: String? = nil) {
        guard var chat = chats[message.id] else {
            return
        }
        chat.content = content
        if let tag {
            chat.tag = tag
        }
        if let codeId {
            chat.codeId = codeId
        }
        chats[message.id] = chat
    }

    func start() {
        isGenerating = true
    }
    
    func stop() {
        isGenerating = false
    }
    
    private func generateHistory() -> [ChatMessage] {
        var history: [ChatMessage] = []
        setScopeDefaults()
        let defaults = UserDefaults.standard
        if defaults.scopeRole {
            var systemPrompt = "You are an experienced professional Swift iOS engineer."
            if defaults.scopeGenCode {
                systemPrompt += " All your responses must contain swift code ONLY where comments or answers are in code comments. No markdown."
            }
            history.append(ChatMessage(role: .system, content: systemPrompt))
        }
        if defaults.scopeHistory {
            history.append(contentsOf: chats.values.sorted(by: { $0.timestamp < $1.timestamp }).map { ChatMessage(role: $0.role, content: $0.content) })
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
    
    func deleteAll() {
        chats.removeAll()
    }
    
    func delete(message: ChatMessage) {
        if let _ = chats[message.id] {
            chats[message.id] = nil
        }
    }
}

#if DEBUG

extension AIChatViewModel {
    static func mock() -> AIChatViewModel {
        let vm = AIChatViewModel()
        vm.chats[UUID()] = ChatMessage(role: .user, content: "Give me an attribute string from plain string")
        vm.chats[UUID()] = ChatMessage(role: .assistant, content: "return try AttributedString(markdown: response, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))", tag: "CodeGen1")
        vm.chats[UUID()] = ChatMessage(role: .user, content: "blah blah")
        vm.chats[UUID()] = ChatMessage(role: .assistant, content: "return try AttributedString(markdown: response, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))", tag: "CodeGen1")
        return vm
    }
}

#endif
