//
//  FileViewerModels.swift
//  AgentOrange
//
//  Created by Paul Leo on 04/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import Foundation
import Factory

struct CodeVersion: Identifiable, Hashable {
    let id: String = UUID().uuidString
    let timestamp: Date = Date.now
    let code: String
    let rows: [AttributedString]
    let tag: String
}
