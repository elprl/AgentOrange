//
//  CustomAISettingsViewModel.swift
//  TDCodeReview
//
//  Created by Paul Leo on 14/06/2023.
//  Copyright © 2023 tapdigital Ltd. All rights reserved.
//

import Foundation
import Combine
import Factory
import SwiftUI

final class CustomAISettingsViewModel: ObservableObject {
    @Published var shouldShowHostDialog = false
    @Published var shouldShowModelDialog = false
    @Published var errorMessage: String = ""
    @Published var newHostText: String = UserDefaults.standard.customAIHost ?? "http://localhost:1234"
    @Published var newModelText: String = UserDefaults.standard.customAIModel ?? "qwen2.5-coder-32b-instruct"
    @AppStorage(UserDefaults.Keys.customAIModel) var customAIModel: String = "qwen2.5-coder-32b-instruct"
    @AppStorage(UserDefaults.Keys.customAIHost) var customAIHost: String = "http://localhost:1234"
    @AppStorage(UserDefaults.Keys.hasCustomAIHost) var hasCustomAIHost: Bool = false
    
    private var hostValidationIssues: String? {
        let string = newHostText.trimmingCharacters(in: .whitespacesAndNewlines)
        if string.isEmpty {
            return "Host URL was empty"
        }
        
        if string.count > 1000 {
            return "Host URL was too large"
        }
        
        if isValidURL(string) {
            return "Host needs to be a valid URL (beginning with http:// or https://)"
        }
        
        return nil
    }
    
    private var modelValidationIssues: String? {
        let string = newModelText.trimmingCharacters(in: .whitespacesAndNewlines)
        if string.isEmpty {
            return "Model name was empty"
        }
        
        if string.count > 100 {
            return "Modal name was too large"
        }
        
        return nil
    }
    
    private func isValidURL(_ urlString: String) -> Bool {
        let pattern = "^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        return regex?.firstMatch(in: urlString, options: [], range: NSRange(urlString.startIndex..., in: urlString)) != nil
    }
}

extension CustomAISettingsViewModel {
    @MainActor
    func onEditHost() {
        shouldShowHostDialog = true
    }
    
    @MainActor
    func onEditModel() {
        shouldShowModelDialog = true
    }
    
    @MainActor
    func onSaveNewHost() {
        shouldShowHostDialog = false
        if let validationIssue = hostValidationIssues {
            errorMessage = validationIssue
            hasCustomAIHost = false
        } else {
            customAIHost = newHostText.trimmingCharacters(in: .whitespacesAndNewlines)
            hasCustomAIHost = true
            errorMessage = ""
        }
    }
    
    @MainActor
    func onSaveNewModel() {
        shouldShowModelDialog = false
        if let validationIssue = modelValidationIssues {
            errorMessage = validationIssue
        } else {
            customAIModel = newModelText.trimmingCharacters(in: .whitespacesAndNewlines)
            errorMessage = ""
        }
    }
    
    @MainActor
    func onCancelNewHost() {
        errorMessage = ""
        shouldShowHostDialog = false
        newHostText = ""
    }
    
    @MainActor
    func onCancelNewModel() {
        errorMessage = ""
        shouldShowModelDialog = false
        newModelText = ""
    }
}
