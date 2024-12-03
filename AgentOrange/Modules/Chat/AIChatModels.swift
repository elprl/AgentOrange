//
//  Models.swift
//  LLMJsonTestHarness
//
//  Created by Paul Leo on 03/12/2024.
//
import Foundation

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let timestamp = Date.now
    let role: Role
    var content: String
}
