//
//  AppInjection.swift
//  AgentOrange
//
//  Created by Paul Leo on 03/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import Foundation
import Factory
import SwiftData

// MARK: Services

extension Container {
    var parserService: Factory<CodeParserServiceProtocol> { self { CodeParserService() }.shared }
    var agiService: Factory<AGIStreamingServiceProtocol & AGIHistoryServiceProtocol> { self { LMStudioAPIService() }.shared }
    var dataService: ParameterFactory<ModelContainer, PersistentDataManagerProtocol> {
        self { PersistentDataManager(container: $0) }.shared
    }
    var commandService: Factory<CommandServiceProtocol> { self { CommandService() }.shared }
    var keychainService: Factory<KeychainProtocol> { self { KeychainService() }.shared }
}
