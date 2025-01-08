//
//  GeminiServiceTests.swift
//  AgentOrange
//
//  Created by Paul Leo on 18/05/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Quick
import Nimble
@testable import AgentOrange
import GoogleGenerativeAI

class GeminiAPIServiceSpec: AsyncSpec {
    override class func spec() {
        describe("GIVEN a GeminiAPIService instance") {
            var service: GeminiAPIService!
            
            beforeEach {
                // Mocking the API key for testing purposes
                service = GeminiAPIService(apiKey: "mock-api-key")
            }
            
            context("WHEN initialized with an API key") {
                it("THEN should set the apiKey property") {
                    let apiKey = await service.apiKey
                    let hasSetToken = await service.hasSetToken
                    expect(apiKey).to(equal("mock-api-key"))
                    expect(hasSetToken).to(beTrue())
                }
                
                it("THEN should not be nil") {
                    expect(service).notTo(beNil())
                }
            }
            
            context("WHEN generateMessages is called with a text input") {
                it("THEN should return an array of GPTMessage objects") {
                    await service.addHistoryItem(message: ChatMessage(role: GPTRole.user, content: "Hello", groupId: "1"))
                    let messages = await service.testGenerateMessages()
                    expect(messages.count).to(equal(1))
                }
                
                it("THEN should handle message history exceeding max tokens") {
                    // Assuming a small maxTokens for testing
                    let maxTokens = 5
                    
                    // Adding enough messages to exceed the mock maxTokens
                    var history: [ChatMessage] = []
                    for i in 1..<21 {
                        history.append(ChatMessage(id: "\(i)", role: GPTRole.user, content: "Hello \(i)", groupId: "1"))
                    }
                    await service.setHistory(messages: history)
                    
                    let messages = await service.testGenerateMessages(maxTokens: maxTokens)
                    expect(messages.count).to(beLessThan(history.count))
                }
            }
            
            context("WHEN generateGeminiMessages is called with a text input") {
                it("THEN should return an array of ModelContent objects in the correct format") {
                    let messages = await service.testGenerateGeminiMessages(text: "Hello, how are you?")
                    expect(messages.count).to(beGreaterThan(0))
                    
                    // Check for alternating roles
                    var previousRole: String? = nil
                    for message in messages {
                        if let role = previousRole {
                            expect(role).notTo(equal(message.role))
                        }
                        previousRole = message.role
                    }
                }
            }
            
            context("WHEN sendMessageStream is called with a text input without an API key") {
                it("THEN should throw an error") {
                    do {
                        var receivedMessages: [String] = []
                        
                        let stream = try await service.sendMessageStream(text: "Hello, how are you?", host: "", model: "gemini-2.0-flash-exp", temperature: 0.5)
                        for try await message in stream {
                            receivedMessages.append(message)
                        }
                        
                        fail("Expected an error")
                    } catch {
                        expect(error).toNot(beNil())
                    }                    
                }
            }
            
            context("WHEN cancelStream is called") {
                it("THEN should set hasCancelledStream to true") {
                    await service.cancelStream()
                    let hasCancelledStream = await service.hasCancelledStream
                    expect(hasCancelledStream).to(beTrue())
                }
            }
        }
    }
}
