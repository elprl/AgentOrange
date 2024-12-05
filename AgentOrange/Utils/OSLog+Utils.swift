//
//  OSLog+Utils.swift
//  bluefuel
//
//  Created by Paul Leo on 14/03/2022.
//  Copyright © 2022 tapdigital Ltd. All rights reserved.
//

import Foundation
import os.log

typealias Log = Logger

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs main operations.
    static let main = Logger(subsystem: subsystem, category: "main")
    /// Logs view operations.
    static let view = Logger(subsystem: subsystem, category: "view")
    /// Logs presenter operations.
    static let pres = Logger(subsystem: subsystem, category: "presenter")
    /// Logs interactor operations.
    static let itr = Logger(subsystem: subsystem, category: "interactor")
    /// Logs entity operations.
    static let ent = Logger(subsystem: subsystem, category: "entity")
    /// Logs router operations.
    static let rtr = Logger(subsystem: subsystem, category: "router")
    /// Logs the network API operations.
    static let api = Logger(subsystem: subsystem, category: "api")
    /// Logs math operations.
    static let math = Logger(subsystem: subsystem, category: "math")
    /// Logs Machine Learning operations.
    static let agi = Logger(subsystem: subsystem, category: "ai")
    /// Logs Core Data operations.
    static let core = Logger(subsystem: subsystem, category: "core")
    /// Logs Database operations.
    static let data = Logger(subsystem: subsystem, category: "data")
}
