//
//  SettingsViewModel.swift
//  AgentOrange
//
//  Created by Paul Leo on 06/01/2025.
//

import Foundation
import Combine
import Factory

final class SettingsViewModel: ObservableObject {
    @Injected(\.keychainService) private var keychainService
    @Published var openAIAPIKey: String = ""
    @Published var claudeAPIKey: String = ""
    @Published var geminiAPIKey: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadKeys()
        registerListeners()
    }
    
    private func registerListeners() {
        $openAIAPIKey
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] key in
                guard let self else { return }
                if isValidKey(key) {
                    saveAccessToken(id: AGIServiceChoice.openai.rawValue, actualToken: key)
                }
            }
            .store(in: &cancellables)
        $claudeAPIKey
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] key in
                guard let self else { return }
                if isValidKey(key) {
                    saveAccessToken(id: AGIServiceChoice.claude.rawValue, actualToken: key)
                }
            }
            .store(in: &cancellables)
        $geminiAPIKey
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] key in
                guard let self else { return }
                if isValidKey(key) {
                    saveAccessToken(id: AGIServiceChoice.gemini.rawValue, actualToken: key)
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadKeys() {
        if let keychainStore = self.keychainService[AGIServiceChoice.openai.rawValue] {
            openAIAPIKey = keychainStore
        }
        if let keychainStore = self.keychainService[AGIServiceChoice.claude.rawValue] {
            claudeAPIKey = keychainStore
        }
        if let keychainStore = self.keychainService[AGIServiceChoice.gemini.rawValue] {
            geminiAPIKey = keychainStore
        }
    }
        
    private func saveAccessToken(id: String, actualToken: String) {
        self.keychainService[id] = actualToken
    }
    
    private func isValidKey(_ key: String) -> Bool {
        return key.count > 5 && key.count < 200
    }
}
