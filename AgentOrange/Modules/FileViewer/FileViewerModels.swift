//
//  FileViewerModels.swift
//  AgentOrange
//
//  Created by Paul Leo on 04/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

//import Foundation
//
//struct CodeVersion: Identifiable, Hashable {
//    let id: String = UUID().uuidString
//    let timestamp: Date = Date.now
//    let code: String
//    let rows: [AttributedString]
//    let tag: String
//}
//
//#if DEBUG
//
//extension CodeVersion {
//    static func mock() -> CodeVersion {
//        let code = """
//struct CodeVersion: Identifiable, Hashable {
//    let id: String = UUID().uuidString
//    let timestamp: Date = Date.now
//    let code: String
//    let rows: [AttributedString]
//    let tag: String
//}
//"""
//        let service = CodeService()
//        service.cacheCode(code: code)
//        return service.codeVersions.first!
//    }
//}
//
//#endif
