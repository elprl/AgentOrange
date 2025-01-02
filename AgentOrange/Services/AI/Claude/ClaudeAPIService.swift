//
//  ClaudeAPIService.swift
//  TDCodeReview
//
//  Created by Paul Leo on 24/05/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Foundation
import Factory
@preconcurrency import SwiftAnthropic

actor ClaudeAPIService {
    private var service: AnthropicService?
    private var apiKey: String?
    internal var historyList = [GPTMessage]()
    private var hasCancelledStream: Bool = false

    init(apiKey: String? = nil) {
        Log.agi.debug("ClaudeAPIService init")
        var prepToken = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        #if DEBUG
        if prepToken == nil {
            if let mockToken = Bundle.main.infoDictionary?["MOCK_CLAUDE_TOKEN"] as? String {
                prepToken = mockToken
            }
        }
        #endif
        
        self.apiKey = prepToken
        if let key = self.apiKey {
            self.service = AnthropicServiceFactory.service(apiKey: key, betaHeaders: nil)
        }
    }
    
    deinit {
        Log.agi.debug("deinit \(String(describing: type(of: self)))")
    }
    
    private func generateMessages(from text: String) -> [GPTMessage] {
        var messages = historyList + [GPTMessage(role: ClaudeRole.user.rawValue, content: text)]
        
        if messages.contentCount > (ClaudeModel.fromUserDefaults().maxTokens * 4) {
            _ = historyList.removeFirst()
            messages = generateMessages(from: text)
        }
        Log.agi.debug("Generated \(messages.count) messages")
        return messages
    }
    
    /// claude messages must alternate between roles
    private func processClaudeMessages(messages: [GPTMessage]) -> [MessageParameter.Message] {
        var orderedMessages = [GPTMessage]()
        messages.forEach {
            if !$0.content.isEmpty {
                if let index = orderedMessages.indices.last {
                    if $0.role == orderedMessages[index].role {
                        orderedMessages[index].content = String(orderedMessages[index].content + "\n" + $0.content)
                    } else {
                        orderedMessages.append($0)
                    }
                } else {
                    orderedMessages.append($0)
                }
            }
        }
        return orderedMessages.map { MessageParameter.Message(role: MessageParameter.Message.Role(rawValue: $0.role) ?? .user, content: .text($0.content)) }
    }
}

extension ClaudeAPIService: TokenServiceProtocol {
    var hasSetToken: Bool {
        if let token = apiKey {
            return !token.isEmpty
        }
        return false
    }
    
    func resetAccessToken(apiKey: String? = nil) {
        let prepToken = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.apiKey = prepToken
    }
    
    func setIsActive() {
        if let key = apiKey, !key.isEmpty {
            if !(UserDefaults.standard.hasClaudeKey ?? false) {
                UserDefaults.standard.hasClaudeKey = true
            }
        }
    }
}

extension ClaudeAPIService: AGIStreamingServiceProtocol {
    func sendMessageStream(text: String, needsJSONResponse: Bool, host: String, model: String) async throws -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                do {
                    let gptMessages = await generateMessages(from: text)
                    let messages = await processClaudeMessages(messages: gptMessages)
                    Log.agi.debug("Sending messages \(messages)")
                    let parameters = MessageParameter(model: Model.other(model), messages: messages, maxTokens: 1024)
                    guard let service = await self.service else { throw APIError.requestFailed(description: "Claude service has not been setup") }
                    let stream = try await service.streamMessage(parameters)
                        for try await result in stream {
                            let content = result.delta?.text ?? ""
                            continuation.yield(content)
                        }
                    
                    continuation.finish()
                } catch {
                    Log.agi.error("AGI stream error: \(error.localizedDescription)")
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    func cancelStream() {
        self.hasCancelledStream = true
    }
}

extension ClaudeAPIService: AGIHistoryServiceProtocol { }
