//
//  UserDefaults+Utils.swift
//  TDCodeReview
//
//  Created by Paul Leo on 04/04/2022.
//  Copyright © 2022 tapdigital Ltd. All rights reserved.
//

import Foundation

extension UserDefaults {

    enum Keys {
        static let reviewRequestId = "reviewRequestId"
        static let bookmarks = "bookmarks"
        static let defaultBranches = "defaultBranches"
        static let githubOwner = "githubOwner"
        static let lightCodeTheme = "lightCodeTheme"
        static let darkCodeTheme = "darkCodeTheme"
        static let showSplash = "showSplash"
        static let showAnnotations = "showAnnotations"
        static let authProviderIndex = "authProviderIndex"
        static let darkLightAutoMode = "darkLightAutoMode"
        static let agiRole = "agiRole"
        static let agiReviewQ = "agiReviewQ"
        static let agiAbuseQ = "agiAbuseQ"
        static let agiOutput = "agiOutput"
        static let agiModel = "agiModel"
        static let agiReflectionQ = "agiReflectionQ"
        static let agiUnitTests = "agiUnitTests"
        static let agiRefactor = "agiRefactor"
        static let agiSummarise = "agiSummarise"
        static let agiComments = "agiComments"
        static let hasAgiKey = "hasAgiKey"
        static let wrapText = "wrapText"
        static let hasShownLeakWarning = "hasShownLeakWarning"
        static let hasGithubKey = "hasGithubKey"
        static let geminiModel = "geminiModel"
        static let hasGeminiKey = "hasGeminiKey"
        static let openAiModel = "openAiModel"
        static let customAIModel = "customAIModel"
        static let customAIHost = "customAIHost"
        static let hasCustomAIHost = "hasCustomAIHost"
        static let claudeModel = "claudeModel"
        static let hasClaudeKey = "hasClaudeKey"
        static let defaultCredits = "defaultCredits"
        static let hasLoadedTags = "hasLoadedTags"
        static let repoSortMode = "repoSortMode"
        static let repoFilterMode = "repoFilterMode"
        static let selectedAGI = "selectedAGI"
    }
    
    @objc var bookmarks: Set<String>? {
        get {
            guard let data = data(forKey: Keys.bookmarks) else { return nil }
            guard let bookmarks = try? JSONDecoder().decode(Set<String>.self, from: data) else { return nil }
            return bookmarks
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            setValue(data, forKey: Keys.bookmarks)
        }
    }
    
    @objc var defaultBranches: [String: String]? {
        get {
            guard let data = data(forKey: Keys.defaultBranches) else { return nil }
            guard let branches = try? JSONDecoder().decode([String: String].self, from: data) else { return nil }
            return branches
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            setValue(data, forKey: Keys.defaultBranches)
        }
    }
    
    @objc var githubOwner: String? {
        get {
            return string(forKey: Keys.githubOwner)
        }
        set {
            setValue(newValue, forKey: Keys.githubOwner)
        }
    }
    
    @objc var reviewRequestId: String? {
        get {
            return string(forKey: Keys.reviewRequestId)
        }
        set {
            setValue(newValue, forKey: Keys.reviewRequestId)
        }
    }
    
    @objc var lightCodeTheme: String? {
        get {
            return string(forKey: Keys.lightCodeTheme)
        }
        set {
            setValue(newValue, forKey: Keys.lightCodeTheme)
        }
    }
    
    @objc var darkCodeTheme: String? {
        get {
            return string(forKey: Keys.darkCodeTheme)
        }
        set {
            setValue(newValue, forKey: Keys.darkCodeTheme)
        }
    }
    
    @objc var agiRole: String? {
        get {
            return string(forKey: Keys.agiRole)
        }
        set {
            setValue(newValue, forKey: Keys.agiRole)
        }
    }
    
    @objc var agiReviewQ: String? {
        get {
            return string(forKey: Keys.agiReviewQ)
        }
        set {
            setValue(newValue, forKey: Keys.agiReviewQ)
        }
    }
    
    @objc var agiUnitTests: String? {
        get {
            return string(forKey: Keys.agiUnitTests)
        }
        set {
            setValue(newValue, forKey: Keys.agiUnitTests)
        }
    }
    
    @objc var agiRefactor: String? {
        get {
            return string(forKey: Keys.agiRefactor)
        }
        set {
            setValue(newValue, forKey: Keys.agiRefactor)
        }
    }
    
    @objc var agiSummarise: String? {
        get {
            return string(forKey: Keys.agiSummarise)
        }
        set {
            setValue(newValue, forKey: Keys.agiSummarise)
        }
    }
    
    @objc var agiComments: String? {
        get {
            return string(forKey: Keys.agiComments)
        }
        set {
            setValue(newValue, forKey: Keys.agiComments)
        }
    }
    
    @objc var agiOutput: String? {
        get {
            return string(forKey: Keys.agiOutput)
        }
        set {
            setValue(newValue, forKey: Keys.agiOutput)
        }
    }
    
    @objc var agiModel: String? {
        get {
            return string(forKey: Keys.agiModel)
        }
        set {
            setValue(newValue, forKey: Keys.agiModel)
        }
    }
    
    @objc var agiAbuseQ: String? {
        get {
            return string(forKey: Keys.agiAbuseQ)
        }
        set {
            setValue(newValue, forKey: Keys.agiAbuseQ)
        }
    }
    
    @objc var agiReflectionQ: String? {
        get {
            return string(forKey: Keys.agiReflectionQ)
        }
        set {
            setValue(newValue, forKey: Keys.agiReflectionQ)
        }
    }
    
    var hasAgiKey: Bool? {
        get {
            return bool(forKey: Keys.hasAgiKey)
        }
        set {
            setValue(newValue, forKey: Keys.hasAgiKey)
        }
    }
    
    var hasGithubKey: Bool? {
        get {
            return bool(forKey: Keys.hasGithubKey)
        }
        set {
            setValue(newValue, forKey: Keys.hasGithubKey)
        }
    }
    
    var hasGeminiKey: Bool? {
        get {
            return bool(forKey: Keys.hasGeminiKey)
        }
        set {
            setValue(newValue, forKey: Keys.hasGeminiKey)
        }
    }
    
    var hasClaudeKey: Bool? {
        get {
            return bool(forKey: Keys.hasClaudeKey)
        }
        set {
            setValue(newValue, forKey: Keys.hasClaudeKey)
        }
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    @objc var openAiModel: String? {
        get {
            return string(forKey: Keys.openAiModel)
        }
        set {
            setValue(newValue, forKey: Keys.openAiModel)
        }
    }
    
    @objc var claudeModel: String? {
        get {
            return string(forKey: Keys.claudeModel)
        }
        set {
            setValue(newValue, forKey: Keys.claudeModel)
        }
    }
    
    @objc var geminiModel: String? {
        get {
            return string(forKey: Keys.geminiModel)
        }
        set {
            setValue(newValue, forKey: Keys.geminiModel)
        }
    }
    
    @objc var customAIModel: String? {
        get {
            return string(forKey: Keys.customAIModel)
        }
        set {
            setValue(newValue, forKey: Keys.customAIModel)
        }
    }
    
    @objc var customAIHost: String? {
        get {
            return string(forKey: Keys.customAIHost)
        }
        set {
            setValue(newValue, forKey: Keys.customAIHost)
        }
    }
    
    var defaultCredits: Int? {
        get {
            return integer(forKey: Keys.defaultCredits)
        }
        set {
            setValue(newValue, forKey: Keys.defaultCredits)
        }
    }
    
    var hasLoadedTags: Bool? {
        get {
            return bool(forKey: Keys.hasLoadedTags)
        }
        set {
            setValue(newValue, forKey: Keys.hasLoadedTags)
        }
    }
    
    var scopeHistory: Bool {
        get {
            return bool(forKey: Scope.history.rawValue)
        }
        set {
            setValue(newValue, forKey: Scope.history.rawValue)
        }
    }
    
    var scopeCode: Bool {
        get {
            return bool(forKey: Scope.code.rawValue)
        }
        set {
            setValue(newValue, forKey: Scope.code.rawValue)
        }
    }
    
    var scopeGenCode: Bool {
        get {
            return bool(forKey: Scope.genCode.rawValue)
        }
        set {
            setValue(newValue, forKey: Scope.genCode.rawValue)
        }
    }
    
    var scopeRole: Bool {
        get {
            return bool(forKey: Scope.role.rawValue)
        }
        set {
            setValue(newValue, forKey: Scope.role.rawValue)
        }
    }
}
