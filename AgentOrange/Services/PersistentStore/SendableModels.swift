//
//  SendableModels.swift
//  AgentOrange
//
//  Created by Paul Leo on 08/12/2024.
//
import Foundation

struct MessageGroupSendable {
    let groupId: String
    let timestamp: Date
    let title: String
    
    init(id: String = UUID().uuidString, timestamp: Date = Date.now, title: String) {
        self.groupId = id
        self.timestamp = timestamp
        self.title = title
    }
}

extension MessageGroupSendable: SendableModelProtocol {
    var persistentModel: CDMessageGroup {
        return CDMessageGroup(id: groupId, timestamp: timestamp, title: title)
    }
}

extension MessageGroupSendable: Identifiable, Hashable {
    var id: String {
        return groupId
    }
}

struct CodeSnippetSendable {
    let codeId: String
    let timestamp: Date
    let title: String
    let subTitle: String?
    let code: String
    let messageId: String?
    let isVisible: Bool
    let groupId: String
    
    init(codeId: String = UUID().uuidString, timestamp: Date = Date.now, title: String, code: String, messageId: String? = nil, subTitle: String? = nil, isVisible: Bool = true, groupId: String) {
        self.codeId = codeId
        self.timestamp = timestamp
        self.title = title
        self.code = code
        self.messageId = messageId
        self.subTitle = subTitle
        self.isVisible = isVisible
        self.groupId = groupId
    }
}

extension CodeSnippetSendable: Identifiable, Hashable {
    var id: String {
        return codeId
    }
}

extension CodeSnippetSendable: SendableModelProtocol {
    var persistentModel: CDCodeSnippet {
        return CDCodeSnippet(codeId: codeId, timestamp: timestamp, title: title, code: code, messageId: messageId, subTitle: subTitle, isVisible: isVisible, groupId: groupId)
    }
}

struct Workflow {
    var name: String
    var timestamp: Date
    var shortDescription: String
    var commandArrangement: String? // CommandArrangment struct JSON
}

extension Workflow: Identifiable, Hashable {
    var id: String {
        return name
    }
}

extension Workflow: SendableModelProtocol {
    var persistentModel: CDWorkflow {
        return CDWorkflow(name: name, timestamp: timestamp, shortDescription: shortDescription, commandIds: commandArrangement)
    }
    
    var commandNames: [String] {
        if let commandArrangement {
            let regex = try! NSRegularExpression(pattern: "\"(\\w+)\"")
            let matches = regex.matches(in: commandArrangement, options: [], range: NSRange(commandArrangement.startIndex..., in: commandArrangement))
            let words = matches.map {
                String(commandArrangement[Range($0.range(at: 1), in: commandArrangement)!])
            }
            return words
        }
        return []
    }
}

extension Workflow {
    static func mock() -> Workflow {
        var mock1 = ChatCommand.mock()
        mock1.host = "openai"
        var mock2 = ChatCommand.mock()
        mock2.host = "claude"
        return Workflow(name: UUID().uuidString, timestamp: Date.now, shortDescription: UUID().uuidString, commandArrangement: "\(mock1.name), \(mock2.name)")
    }
}
