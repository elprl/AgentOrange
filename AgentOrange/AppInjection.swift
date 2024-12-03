//
//  AppInjection.swift
//  LLMJsonTestHarness
//
//  Created by Paul Leo on 03/12/2024.
//

import Foundation
import Factory

// MARK: Services

extension Container {
    var codeService: Factory<CodeServiceProtocol> { self { CodeService() }.shared }
}
