//
//  AppInjection.swift
//  AgentOrange
//
//  Created by Paul Leo on 03/12/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.

import Foundation
import Factory

// MARK: Services

extension Container {
    var codeService: Factory<CodeServiceProtocol> { self { CodeService() }.shared }
    var agiService: Factory<AGIServiceProtocol> { self { OpenSourceLLMAPIService() } }
    var cacheService: Factory<FileCachingServiceProtocol> { self { CachingService() } }
}
