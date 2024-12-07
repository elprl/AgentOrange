//
//  ChatGPTAPIService.swift
//  TDCodeReview
//
//  Created by Paul Leo on 30/03/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Foundation

actor ChatGPTAPIService {
    var historyList = [GPTMessage]()
    private var hasCancelledStream: Bool = false
    internal var apiKey: String?
    private var urlSession = URLSession.shared
    private var urlRequest: URLRequest {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        headers.forEach {  urlRequest.setValue($1, forHTTPHeaderField: $0) }
        return urlRequest
    }
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
    private var headers: [String: String] {
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
    }
    
    deinit {
        Log.agi.debug("deinit \(String(describing: type(of: self)))")
    }
    
    private func generateMessages(from text: String) -> [GPTMessage] {
        var messages = historyList + [GPTMessage(role: GPTRole.user.rawValue, content: text)]
        
        if messages.contentCount > (GPTModel.fromUserDefaults().maxTokens * 4) { // 1 token ~= 4 chars
            _ = historyList.removeFirst()
            messages = generateMessages(from: text)
        }
        Log.agi.debug("Generated \(messages.count) messages")
        return messages
    }
    
    private func jsonBody(text: String, stream: Bool = true, needsJSONResponse: Bool = false) throws -> Data {
        let request = Request(model: model, temperature: 0.5,
                              messages: generateMessages(from: text),
                              stream: stream,
                              responseFormat: needsJSONResponse ? ResponseFormat(type: "json_object") : nil)
        return try JSONEncoder().encode(request)
    }
}

extension ChatGPTAPIService: TokenServiceProtocol {
    var hasSetToken: Bool {
        if let token = apiKey {
            return !token.isEmpty
        }
        return false
    }
    
    func resetAccessToken(apiKey: String? = nil) {
        self.apiKey = apiKey
    }
}

extension ChatGPTAPIService: AGIStreamingServiceProtocol {
    
    func sendMessageStream(text: String, needsJSONResponse: Bool) async throws -> AsyncThrowingStream<String, Error> {
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
                Task(priority: .userInitiated) { [weak self] in
                    guard let self else { return }
                    do {
                        var responseText = ""
                        for try await line in result.lines {
                            // Check for task cancellation
                            if await self.hasCancelledStream {
                                continuation.finish()
                                return
                            }
                            
                            if line.hasPrefix("data: "),
                               let data = line.dropFirst(6).data(using: .utf8),
                               let response = try? self.jsonDecoder.decode(StreamCompletionResponse.self, from: data),
                               let text = response.choices.first?.delta.content {
                                responseText += text
                                continuation.yield(text)
                            }
                        }
                        continuation.finish()
                    } catch is CancellationError {
                        continuation.finish(throwing: CancellationError())
                    } catch {
                        Log.agi.error("AGI stream error: \(error.localizedDescription)")
                        continuation.finish(throwing: error)
                    }
                }
            }
        } catch {
            throw error
        }
    }
    
    func cancelStream() {
        self.hasCancelledStream = true
    }
}

extension ChatGPTAPIService: AGIHistoryServiceProtocol { }
