//
//  ChatGPTAPIService.swift
//  TDCodeReview
//
//  Created by Paul Leo on 30/03/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Foundation
import Factory

class ChatGPTAPIService: @unchecked Sendable, AGIServiceProtocol {
    internal var apiKey: String?
    var historyList = [GPTMessage]()
    var urlSession = URLSession.shared
    var urlRequest: URLRequest {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        headers.forEach {  urlRequest.setValue($1, forHTTPHeaderField: $0) }
        return urlRequest
    }
    let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
    var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey ?? "")"
        ]
    }
    var model: String {
        let modelString = UserDefaults.standard.openAiModel ?? "gpt-3.5-turbo"
        return modelString
    }


    init(apiKey: String? = nil) {
        Log.agi.debug("ChatGPTAPIService init")
        var prepToken: String? = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        #if DEBUG
        if prepToken == nil {
            if let mockToken = Bundle.main.infoDictionary?["MOCK_OPENAI_TOKEN"] as? String {
                prepToken = mockToken
            }
        }
        #endif
        self.apiKey = prepToken
        setIsActive()
    }
    
    func setIsActive() {
        if let key = apiKey, !key.isEmpty {
            if !(UserDefaults.standard.hasAgiKey ?? false) {
                UserDefaults.standard.hasAgiKey = true
            }
        }
    }
    
    deinit {
        Log.agi.debug("deinit \(String(describing: type(of: self)))")
    }
    
    func setHistory(messages: [ChatMessage]) {
        deleteHistoryList()
        let oldMessages = messages.compactMap { message -> GPTMessage? in
            return GPTMessage(id: message.id.uuidString, role: message.role.rawValue, content: message.content)
        }
        historyList.append(contentsOf: oldMessages)
    }
    
    func setupHistory(for fileContent: String, selectedRows: Set<Int>, scopes: HistoryOptions, messages: [ChatMessage]) {
        deleteHistoryList()
        
        if scopes.contains(.role) {
            let systemPrompt = GPTMessage(role: GPTRole.system.rawValue, content: UserDefaults.standard.agiRole ?? AGIServiceConstants.agiRole)
            historyList.append(systemPrompt)
        }
        if scopes.contains(.code) {
            let filePrompt = GPTMessage(role: GPTRole.system.rawValue, content: fileContent)
            historyList.append(filePrompt)
        }
        if scopes.contains(.selection) {
            let selectionContent = processSelection(for: fileContent, selectedRows: selectedRows)
            historyList.append(selectionContent)
        }
        if scopes.contains(.messages) {
            let oldMessages = messages.compactMap { message -> GPTMessage? in
                return GPTMessage(id: message.id.uuidString, role: message.type.rawValue.hasPrefix("ai") ? GPTRole.assistant.rawValue : GPTRole.user.rawValue, content: message.content)
            }
            historyList.append(contentsOf: oldMessages)
        }
    }
    
    func processSelection(for fileContent: String, selectedRows: Set<Int>) -> GPTMessage {
        // Split the string into an array of lines
        let lines = fileContent.components(separatedBy: "\n")
        // Filter lines based on the rowIndexesToInclude Set
        let filteredLines = lines.enumerated().filter { selectedRows.contains($0.offset) }.map { $0.element }
        // Join the filtered lines back into a single string
        let filteredString = filteredLines.joined(separator: "\n")
        return GPTMessage(role: GPTRole.system.rawValue, content: filteredString)
    }
    
    func getHistory() -> [GPTMessage] {
        return historyList
    }
    
    func addHistoryItem(message: ChatMessage) {
        let mess = GPTMessage(id: message.id.uuidString, role: message.type.rawValue.hasPrefix("ai") ? GPTRole.assistant.rawValue : GPTRole.user.rawValue, content: message.content)
        historyList.append(mess)
    }
    
    func removeHistoryItem(message: ChatMessage) {
        if let index = historyList.firstIndex(where: { mess in
            mess.id == message.id.uuidString
        }) {
            historyList.remove(at: index)
        }
    }
    
    func generateMessages(from text: String) -> [GPTMessage] {
        var messages = historyList + [GPTMessage(role: GPTRole.user.rawValue, content: text)]
        
        if messages.contentCount > (GPTModel.fromUserDefaults().maxTokens * 4) { // 1 token ~= 4 chars
            _ = historyList.removeFirst()
            messages = generateMessages(from: text)
        }
        Log.agi.debug("Generated \(messages.count) messages")
        return messages
    }
    
    func jsonBody(text: String, stream: Bool = true, needsJSONResponse: Bool = false) throws -> Data {
        let request = Request(model: model, temperature: 0.5,
                              messages: generateMessages(from: text), 
                              stream: stream,
                              responseFormat: needsJSONResponse ? ResponseFormat(type: "json_object") : nil)
        return try JSONEncoder().encode(request)
    }
    
    func appendToHistoryList(userText: String, responseText: String) {
        self.historyList.append(GPTMessage(role: GPTRole.user.rawValue, content: userText))
        self.historyList.append(GPTMessage(role: GPTRole.assistant.rawValue, content: responseText))
    }
    
    func sendMessageStream(text: String, needsJSONResponse: Bool = false, cancellationHandler: ((Task<Void, Never>?) -> Void)? = nil) async throws -> AsyncThrowingStream<String, Error> {
        var urlRequest = self.urlRequest
        do {
            let httpBody = try jsonBody(text: text, needsJSONResponse: needsJSONResponse)
            Log.api.debug("JSON Body: \(String(data: httpBody, encoding: .utf8) ?? "")")
            urlRequest.httpBody = httpBody
        } catch _ as EncodingError {
            Log.agi.error("AGI invalidJsonEncoding")
            throw TDAPIError.invalidJsonEncoding
        } catch {
            Log.agi.error("AGI request error: \(error.localizedDescription)")
            throw error
        }
        
        do {
            let (result, response) = try await urlSession.bytes(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw TDAPIError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                var errorText = ""
                for try await line in result.lines {
                    errorText += line
                }
                
                if let data = errorText.data(using: .utf8), let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
                    errorText = "\n\(errorResponse.message)"
                }
                Log.agi.error("AGI bad response: \(errorText)")
                throw TDAPIError.badResponse(httpResponse.statusCode, errorText)
            }
            
            return AsyncThrowingStream<String, Error> { continuation in
                let task = Task(priority: .userInitiated) { [weak self] in
                    guard let self else { return }
                    do {
                        var responseText = ""
                        for try await line in result.lines {
                            // Check for task cancellation
                            try Task.checkCancellation()
                            
                            if line.hasPrefix("data: "),
                               let data = line.dropFirst(6).data(using: .utf8),
                               let response = try? self.jsonDecoder.decode(StreamCompletionResponse.self, from: data),
                               let text = response.choices.first?.delta.content {
                                responseText += text
                                continuation.yield(text)
                            } 
                        }
                        self.appendToHistoryList(userText: text, responseText: responseText)
                        continuation.finish()
                    } catch is CancellationError {
                        continuation.finish(throwing: CancellationError())
                    } catch {
                        Log.agi.error("AGI stream error: \(error.localizedDescription)")
                        continuation.finish(throwing: error)
                    }
                }
                
                // Call cancellation handler if provided
                cancellationHandler?(task)
            }
        } catch {
            throw error
        }
    }

    func sendMessage(_ text: String) async throws -> String {
        var urlRequest = self.urlRequest
        urlRequest.httpBody = try jsonBody(text: text, stream: false)
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw "Invalid response"
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            var error = "Bad Response: \(httpResponse.statusCode)"
            if let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
                error.append("\n\(errorResponse.message)")
            }
            throw error
        }
        
        do {
            let completionResponse = try self.jsonDecoder.decode(CompletionResponse.self, from: data)
            let responseText = completionResponse.choices.first?.message.content ?? ""
            self.appendToHistoryList(userText: text, responseText: responseText)
            return responseText
        } catch {
            throw error
        }
    }
    
    func deleteHistoryList() {
        self.historyList.removeAll()
    }
    
    var hasSetToken: Bool {
        if let token = apiKey {
            return !token.isEmpty
        }
        return false
    }
    
    func resetAccessToken(apiKey: String? = nil) {
        self.apiKey = nil
    }
}

extension String: @retroactive CustomNSError {
    
    public var errorUserInfo: [String : Any] {
        [
            NSLocalizedDescriptionKey: self
        ]
    }
}
