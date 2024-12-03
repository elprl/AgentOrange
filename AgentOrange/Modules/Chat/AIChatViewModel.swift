//
//  ViewModel.swift
//  LLMJsonTestHarness
//
//  Created by Paul Leo on 03/12/2024.
//

import SwiftUI
import Factory

@Observable
final class AIChatViewModel {
    @Injected(\.codeService) @ObservationIgnored private var codeService
    var chats: [UUID: ChatMessage] = [:]
    var isGenerating: Bool = false
    var question: String = ""
    @ObservationIgnored private var bot: LLM?
    
    init(fileName: String = "Meta-Llama-3.1-8B-Instruct-128k-Q4_0") {
        let systemPrompt = "You are an experienced professional Swift iOS engineer. All your responses must contain swift code ONLY where comments or answers are in code comments (\\\\)."
        guard let bundleURL = Bundle.main.url(forResource: fileName, withExtension: "gguf") else {
            return
        }
        bot = LLM(from: bundleURL, template: .chatML(systemPrompt))
    }

    func streamResponse() {
        Task { @MainActor in
            guard let bot = self.bot else {
                return
            }
            let questionCopy = String(self.question.trimmingCharacters(in: .whitespacesAndNewlines))
            self.question = ""
            start()
            let questionPr = bot.preprocess(questionCopy, generateHistory())
            addChatMessage(content: questionCopy)
            let response = bot.getResponse(from: questionPr)
            let responseMessage = addChatMessage(role: .bot, content: "")
            var tempOutput = ""
            for await responseDelta in response {
                tempOutput += responseDelta
                updateMessage(message: responseMessage, content: tempOutput)
            }
            print(tempOutput)
            codeService.code = tempOutput
            stop()
        }
    }
    
    @discardableResult private func addChatMessage(role: Role = .user, content: String) -> ChatMessage {
        let chatMessage = ChatMessage(role: role, content: content)
        chats[chatMessage.id] = chatMessage
        return chatMessage
    }
    
    private func updateMessage(message: ChatMessage, content: String) {
        guard var chat = chats[message.id] else {
            return
        }
        chat.content = content
        chats[message.id] = chat
    }

    func start() {
        isGenerating = true
    }
    
    func stop() {
        bot?.stop()
        isGenerating = false
    }
    
    func markdown(from response: String) -> AttributedString {
        do {
            return try AttributedString(markdown: response, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        } catch {
            return AttributedString("Error parsing markdown: \(error)")
        }
    }
    
    private func generateHistory() -> [Chat] {
        var history: [Chat] = []
        if let code = codeService.code {
            history.append(Chat(role: .user, content: code))
        }
        history.append(contentsOf: chats.values.sorted(by: { $0.timestamp < $1.timestamp }).map { Chat(role: $0.role, content: $0.content) })
        return history
    }
}
