//
//  AGIHistoryServiceTests.swift
//  AgentOrangeTests
//
//  Created by Paul Leo on 07/12/2024.
//
import Quick
import Nimble
@testable import AgentOrange

class AGIHistoryServiceTests: AsyncSpec {
    override class func spec() {
        describe("GIVEN an instance of AGIHistoryService") {
            var historyService: MockAGIHistoryService!
            
            beforeEach {
                historyService = MockAGIHistoryService()
            }
            
            context("WHEN setting the history with a list of ChatMessages") {
                let chatMessages = [
                    ChatMessage(id: "1", role: .user, content: "Hello", groupId: "1"),
                    ChatMessage(id: "2", role: .assistant, content: "Hi there!", groupId: "1")
                ]
                
                beforeEach {
                    await historyService.setHistory(messages: chatMessages)
                }
                
                it("THEN the history list should contain the corresponding GPTMessages") {
                    let list = await historyService.historyList
                    expect(list.count).to(equal(2))
                    expect(list[0].role).to(equal(GPTRole.user.rawValue))
                    expect(list[0].content).to(equal("Hello"))
                    expect(list[1].role).to(equal(GPTRole.assistant.rawValue))
                    expect(list[1].content).to(equal("Hi there!"))
                }
            }
            
            context("WHEN setting up the history with file content, selected rows, scopes, and messages") {
                let fileContent = "Line 1\nLine 2\nLine 3"
                let selectedRows: Set<Int> = [0, 2]
                let scopes: HistoryOptions = [.role, .code, .messages]
                let chatMessages = [
                    ChatMessage(id: "1", role: .user, content: "Hello", groupId: "1"),
                    ChatMessage(id: "2", role: .assistant, content: "Hi there!", groupId: "1")
                ]
                
                beforeEach {
                    await historyService.setupHistory(for: fileContent, selectedRows: selectedRows, scopes: scopes, messages: chatMessages, systemRole: "my role")
                }
                
                it("THEN the history list should contain the system prompt for code and selection") {
                    let list = await historyService.historyList
                    expect(list.count).to(equal(4))
                    expect(list[0].role).to(equal(GPTRole.system.rawValue))
                    expect(list[0].content).to(equal("my role"))
                    expect(list[1].role).to(equal(GPTRole.system.rawValue))
                    expect(list[1].content).to(equal("Line 1\nLine 2\nLine 3"))
                }
                
                it("THEN the history list should contain the user and assistant messages") {
                    let list = await historyService.historyList
                    expect(list[2].role).to(equal(GPTRole.user.rawValue))
                    expect(list[2].content).to(equal("Hello"))
                    expect(list[3].role).to(equal(GPTRole.assistant.rawValue))
                    expect(list[3].content).to(equal("Hi there!"))
                }
            }
            
            context("WHEN processing a selection from file content and selected rows") {
                let fileContent = "Line 1\nLine 2\nLine 3"
                let selectedRows: Set<Int> = [0, 2]
                
                var result: GPTMessage!
                
                beforeEach {
                    result = await historyService.processSelection(for: fileContent, selectedRows: selectedRows)
                }
                
                it("THEN the result should be a GPTMessage with the selected lines") {
                    expect(result.role).to(equal(GPTRole.system.rawValue))
                    expect(result.content).to(equal("Line 1\nLine 3"))
                }
            }
            
            context("WHEN getting the history") {
                let chatMessages = [
                    ChatMessage(id: "1", role: .user, content: "Hello", groupId: "1"),
                    ChatMessage(id: "2", role: .assistant, content: "Hi there!", groupId: "1")
                ]
                
                let gptHistory = [
                    GPTMessage(id: "1", role: GPTRole.user.rawValue, content: "Hello"),
                    GPTMessage(id: "2", role: GPTRole.assistant.rawValue, content: "Hi there!")
                ]
                
                beforeEach {
                    await historyService.setHistory(messages: chatMessages)
                }
                
                it("THEN the returned list should match the history list") {
                    let history = await historyService.getHistory()
                    let list = await historyService.historyList

                    expect(history.count).to(equal(2))
                    expect(list[0].role).to(equal(gptHistory[0].role))
                    expect(list[0].content).to(equal(gptHistory[0].content))
                    expect(list[1].role).to(equal(gptHistory[1].role))
                    expect(list[1].content).to(equal(gptHistory[1].content))
                }
            }
            
            context("WHEN adding a history item") {
                let chatMessage = ChatMessage(id: "1", role: .user, content: "Hello", groupId: "1")
                
                beforeEach {
                    await historyService.addHistoryItem(message: chatMessage)
                }
                
                it("THEN the history list should contain the new GPTMessage") {
                    let list = await historyService.historyList
                    expect(list.count).to(equal(1))
                    expect(list[0].role).to(equal(GPTRole.user.rawValue))
                    expect(list[0].content).to(equal("Hello"))
                }
            }
            
            context("WHEN removing a history item") {
                let chatMessages = [
                    ChatMessage(id: "1", role: .user, content: "Hello", groupId: "1"),
                    ChatMessage(id: "2", role: .assistant, content: "Hi there!", groupId: "1")
                ]
                
                beforeEach {
                    await historyService.setHistory(messages: chatMessages)
                    await historyService.removeHistoryItem(message: chatMessages[0])
                }
                
                it("THEN the history list should not contain the removed GPTMessage") {
                    let list = await historyService.historyList
                    expect(list.count).to(equal(1))
                    expect(list[0].role).to(equal(GPTRole.assistant.rawValue))
                    expect(list[0].content).to(equal("Hi there!"))
                }
            }
            
            context("WHEN deleting the history list") {
                let chatMessages = [
                    ChatMessage(id: "1", role: .user, content: "Hello", groupId: "1"),
                    ChatMessage(id: "2", role: .assistant, content: "Hi there!", groupId: "1")
                ]
                
                beforeEach {
                    await historyService.setHistory(messages: chatMessages)
                    await historyService.deleteHistoryList()
                }
                
                it("THEN the history list should be empty") {
                    let list = await historyService.historyList
                    expect(list.count).to(equal(0))
                }
            }
            
            context("WHEN appending to the history list with user and response text") {
                let userText = "Hello"
                let responseText = "Hi there!"
                
                beforeEach {
                    await historyService.appendToHistoryList(userText: userText, responseText: responseText)
                }
                
                it("THEN the history list should contain the new GPTMessages for user and assistant") {
                    let list = await historyService.historyList
                    expect(list.count).to(equal(2))
                    expect(list[0].role).to(equal(GPTRole.user.rawValue))
                    expect(list[0].content).to(equal(userText))
                    expect(list[1].role).to(equal(GPTRole.assistant.rawValue))
                    expect(list[1].content).to(equal(responseText))
                }
            }
        }
    }
}

// Mock implementation of AGIHistoryServiceProtocol for testing
actor MockAGIHistoryService: AGIHistoryServiceProtocol {
    var historyList: [GPTMessage] = []
}
