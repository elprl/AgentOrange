//
//  OpenSourceLLMAPIService.swift
//  TDCodeReview
//
//  Created by Paul Leo on 23/05/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Foundation
import Factory

final class OpenSourceLLMAPIService: ChatGPTAPIService, @unchecked Sendable {

    override var urlRequest: URLRequest {
        let url = URL(string: "\(host)/v1/chat/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        headers.forEach {  urlRequest.setValue($1, forHTTPHeaderField: $0) }
        return urlRequest
    }
    
    override var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
    
    override var model: String {
        let modelString = UserDefaults.standard.customAIModel ?? "qwen2.5-coder-7b-instruct" // "llama-3.2-3b-instruct"
        return modelString
    }
    
    var host: String {
        let myHost = UserDefaults.standard.customAIHost ?? "http://localhost:1234" // "http://169.254.5.254:1234" // "http://localhost:1234"
        return myHost
    }

    init() {
        Log.agi.debug("CustomAIAPIService init")
    }
    
    override var hasSetToken: Bool {
        return !host.isEmpty
    }
    
    override func resetAccessToken(apiKey: String? = nil) {
        // do nothing
    }
}
