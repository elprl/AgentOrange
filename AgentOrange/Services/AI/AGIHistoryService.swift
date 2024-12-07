//
//  AGIHistoryService.swift
//  AgentOrange
//
//  Created by Paul Leo on 07/12/2024.
//
import Foundation

protocol AGIHistoryServiceProtocol: Actor {
    var historyList: [GPTMessage] { get set }
    func setHistory(messages: [ChatMessage])
    func setupHistory(for fileContent: String, selectedRows: Set<Int>, scopes: HistoryOptions, messages: [ChatMessage], systemRole: String?)
    func processSelection(for fileContent: String, selectedRows: Set<Int>) -> GPTMessage
    func getHistory() -> [GPTMessage]
    func addHistoryItem(message: ChatMessage)
    func removeHistoryItem(message: ChatMessage)
    func deleteHistoryList()
    func appendToHistoryList(userText: String, responseText: String)
}

extension AGIHistoryServiceProtocol {
    func setHistory(messages: [ChatMessage]) {
        deleteHistoryList()
        let oldMessages = messages.compactMap { message -> GPTMessage? in
            return GPTMessage(id: message.id.uuidString, role: message.role.rawValue, content: message.content)
        }
        historyList.append(contentsOf: oldMessages)
    }
    
    func setupHistory(for fileContent: String, selectedRows: Set<Int>, scopes: HistoryOptions, messages: [ChatMessage], systemRole: String? = nil) {
        deleteHistoryList()
        
        if let role = systemRole, scopes.contains(.role) {
            let systemPrompt = GPTMessage(role: GPTRole.system.rawValue, content: role)
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
        let mess = GPTMessage(id: message.id.uuidString, role: message.role.rawValue, content: message.content)
        historyList.append(mess)
    }
    
    func removeHistoryItem(message: ChatMessage) {
        if let index = historyList.firstIndex(where: { mess in
            mess.id == message.id.uuidString
        }) {
            historyList.remove(at: index)
        }
    }
    
    func deleteHistoryList() {
        self.historyList.removeAll()
    }
    
    func appendToHistoryList(userText: String, responseText: String) {
        self.historyList.append(GPTMessage(role: GPTRole.user.rawValue, content: userText))
        self.historyList.append(GPTMessage(role: GPTRole.assistant.rawValue, content: responseText))
    }
}
