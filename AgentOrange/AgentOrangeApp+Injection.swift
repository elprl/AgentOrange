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
    var parserService: Factory<any CodeParserServiceProtocol> { self { CodeParserService() }.shared }
    var agiService: Factory<any AGIStreamingServiceProtocol & AGIHistoryServiceProtocol> { self { LMStudioAPIService() }.shared }
    var dataService: ParameterFactory<ModelContainer, any PersistentDataManagerProtocol> {
        self { PersistentDataManager(container: $0) }.shared
    }
    var commandService: ParameterFactory<ModelContainer, any CommandServiceProtocol> {
        self { CommandService(container: $0) }.shared
    }
    var keychainService: Factory<any KeychainProtocol> { self { KeychainService() }.shared }
    var workflowManager: ParameterFactory<ModelContainer, any WorkflowManagerProtocol> {
        self { WorkflowManager(container: $0) }.shared
    }
}
