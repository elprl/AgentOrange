//
//  OpenSourceLLMAPIService.swift
//  AgentOrange
//
//  Created by Paul Leo on 30/09/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.
//

import Foundation

actor LMStudioAPIService {
    var historyList = [GPTMessage]()
    private var hasCancelledStream: Bool = false
    private var urlSession = URLSession.shared
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
    private var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
    
    private func urlRequest(for host: String) -> URLRequest {
        let url = URL(string: "\(host)/v1/chat/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        headers.forEach {  urlRequest.setValue($1, forHTTPHeaderField: $0) }
        return urlRequest
    }

    init() {
        Log.agi.debug("CustomAIAPIService init")
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
    
    private func jsonBody(text: String, stream: Bool = true, needsJSONResponse: Bool = false, model: String, temperature: Double = 0.5) throws -> Data {
        let request = Request(model: model, temperature: temperature,
                              messages: generateMessages(from: text),
                              stream: stream,
                              responseFormat: needsJSONResponse ? ResponseFormat(type: "json_object") : nil)
        return try JSONEncoder().encode(request)
    }
}

extension LMStudioAPIService: AGIStreamingServiceProtocol {
    
    func sendMessageStream(text: String, needsJSONResponse: Bool, host: String, model: String, temperature: Double) async throws -> AsyncThrowingStream<String, Error> {
        self.hasCancelledStream = false
        var urlRequest = urlRequest(for: host)
        do {
            let httpBody = try jsonBody(text: text, needsJSONResponse: needsJSONResponse, model: model, temperature: temperature)
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

extension LMStudioAPIService: AGIHistoryServiceProtocol { }
