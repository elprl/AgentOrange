//
//  GeminiAPIService.swift
//  TDCodeReview
//
//  Created by Paul Leo on 18/05/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Foundation
import Factory
@preconcurrency import GoogleGenerativeAI

actor GeminiAPIService {
    internal var apiKey: String?
    var historyList = [GPTMessage]()
    var hasCancelledStream: Bool = false

    init(apiKey: String? = nil) {
        Log.agi.debug("ChatGPTAPIService init")
        var prepToken: String? = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        #if DEBUG
        if prepToken == nil {
            if let mockToken = Bundle.main.infoDictionary?["MOCK_GEMINI_TOKEN"] as? String {
                prepToken = mockToken
            }
        }
        #endif
        
        self.apiKey = prepToken
    }
    
    deinit {
        Log.agi.debug("deinit \(String(describing: type(of: self)))")
    }
    
    private func generateMessages(maxTokens: Int = GeminiModel.fromUserDefaults().maxTokens) -> [GPTMessage] {
        var messages = historyList
        
        // TODO: Add token counting here
        if messages.contentCount > (maxTokens * 4) { // rough alternative to token counting
            _ = historyList.removeFirst()
            messages = generateMessages()
        }
        Log.agi.debug("Generated \(messages.count) messages")
        return messages
    }
    
    /// Annoyingly Google requires awkward consolidation of messages and only allows alternating between roles
    private func generateGeminiMessages(text: String) -> [ModelContent] {
        var prevMessage: ModelContent = ModelContent(role: GeminiRole.model.rawValue, parts: "Hi, behaving as a software engineer, how can I help?")
        // gemini only seems to allow a starting with a user message and must include a model message
        var modelContents: [ModelContent] = [
            ModelContent(role: GeminiRole.user.rawValue, parts: "Hi, I'm a software engineer."),
            prevMessage
        ]
        
        do {
            // gemini annoyingly only allows alternating between model and user
            for message in generateMessages() {
                var content = try ModelContent(role: GeminiRole.convertRole(message.role), message.content)
                if prevMessage.role == content.role {
                    content = try ModelContent(role: GeminiRole.convertRole(message.role), prevMessage.parts + [message.content])
                    if let index = modelContents.firstIndex(of: prevMessage) {
                        modelContents[index] = content
                    }
                } else {
                    modelContents.append(content)
                }
                prevMessage = content
            }
            
            // add the prompt
            var content = try ModelContent(role: GeminiRole.user.rawValue, text)
            if prevMessage.role == GeminiRole.user.rawValue {
                content = try ModelContent(role: GeminiRole.user.rawValue, prevMessage.parts + [text])
                if let index = modelContents.firstIndex(of: prevMessage) {
                    modelContents[index] = content
                }
            } else {
                modelContents.append(content)
            }
        } catch {
            print("Error generating messages: \(error)")
        }

        return modelContents
    }
}

extension GeminiAPIService: TokenServiceProtocol {
    var hasSetToken: Bool {
        if let token = apiKey {
            return !token.isEmpty
        }
        return false
    }
    
    func setIsActive() {
        if let key = self.apiKey, !key.isEmpty {
            if !(UserDefaults.standard.hasGeminiKey ?? false) {
                UserDefaults.standard.hasGeminiKey = true
            }
        }
    }
    
    func resetAccessToken(apiKey: String? = nil) {
        let prepToken = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.apiKey = prepToken
        setIsActive()
    }
}

extension GeminiAPIService: AGIStreamingServiceProtocol {
    func sendMessageStream(text: String, needsJSONResponse: Bool = false, host: String, model: String, temperature: Double) async throws -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) { [weak self] in
                guard let self = self else { return }
                do {
                    guard let key = await self.apiKey, !key.isEmpty else {
                        continuation.finish(throwing: TDAPIError.streamError("No API Key"))
                        return
                    }
                    let client = GenerativeModel(name: model, apiKey: key)
                    let messages: [ModelContent] = await generateGeminiMessages(text: text)
                    let outputContentStream = client.generateContentStream(messages)
                    var outputText: String = ""
                    
                    // stream response
                    for try await chunk in outputContentStream {
                        // Check for task cancellation
                        if await self.hasCancelledStream {
                            continuation.finish()
                            return
                        }
                        
                        if let line = chunk.text {
                            outputText += line
                            continuation.yield(line)
                        }
                    }
                    Log.api.debug("outputText: \(outputText)")
                    continuation.finish()
                } catch {
                    var errorMessage: String = ""
                    switch error {
                    case let GenerateContentError.internalError(underlying: underlyingError):
                        Log.api.error("Gemini Failed: underlying error: \(underlyingError.localizedDescription)")
                        errorMessage = NSLocalizedString("Gemini Failed: Internal error", comment: "")
                    case let GenerateContentError.promptBlocked(response: generateContentResponse):
                        Log.api.error("Gemini Failed: promptBlocked error: \(generateContentResponse.text ?? "")")
                        errorMessage = NSLocalizedString("Gemini Failed: Your prompt was blocked", comment: "")
                    case let GenerateContentError.responseStoppedEarly(reason: finishReason, response: generateContentResponse):
                        Log.api.error("Gemini Failed: responseStoppedEarly error: \(generateContentResponse.text ?? "")")
                        errorMessage = NSLocalizedString("Gemini Failed: Response stopped early, \(finishReason.rawValue)", comment: "")
                    case GenerateContentError.invalidAPIKey:
                        errorMessage = NSLocalizedString("Gemini Failed: Invalid API Key", comment: "")
                    case GenerateContentError.unsupportedUserLocation:
                        errorMessage = NSLocalizedString("Gemini Failed: Unsupported User Location", comment: "")
                    default:
                        errorMessage = NSLocalizedString("Gemini Failed: Unknown error", comment: "")
                    }
                    Log.api.error("Error decoding gemini stream: \(errorMessage)")
                    continuation.finish(throwing: TDAPIError.streamError(errorMessage))
                }
            }
        }
    }
    
    func cancelStream() {
        self.hasCancelledStream = true
    }
}

extension GeminiAPIService: AGIHistoryServiceProtocol { }

extension Array where Element == ModelContent {
    var contentCount: Int { reduce(0, { $0 + ($1.parts.first?.text?.count ?? 0) })}
}

#if DEBUG

// for unit testing
extension GeminiAPIService {
    public func testGenerateMessages(maxTokens: Int = GeminiModel.fromUserDefaults().maxTokens) -> [GPTMessage] {
        generateMessages(maxTokens: maxTokens)
    }
    
    public func testGenerateGeminiMessages(text: String) -> [ModelContent] {
        generateGeminiMessages(text: text)
    }
}

#endif
