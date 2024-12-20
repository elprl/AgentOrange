//
//  KeychainService.swift
//  TDCodeReview
//
//  Created by Paul Leo on 26/07/2022.
//  Copyright © 2022 tapdigital Ltd. All rights reserved.
//

import Foundation

protocol KeychainProtocol {
    subscript(key: String) -> String? { get set }
}

extension KeychainProtocol {
        
    subscript(key: String) -> String? {
        get {
            return load(withKey: key)
        } set {
            DispatchQueue.global(qos: .background).sync(flags: .barrier) {
                self.save(newValue, forKey: key)
            }
        }
    }
    
    private func save(_ string: String?, forKey key: String) {
        let query = keychainQuery(withKey: key)
        let objectData: Data? = string?.data(using: .utf8, allowLossyConversion: false)

        if SecItemCopyMatching(query, nil) == noErr {
            if let dictData = objectData {
                let status = SecItemUpdate(query, NSDictionary(dictionary: [kSecValueData: dictData]))
                Log.api.debug("KeychainService Update status: \(String(status))")
            } else {
                let status = SecItemDelete(query)
                Log.api.debug("KeychainService Delete status: \(String(status))")
            }
        } else {
            if let dictData = objectData {
                query.setValue(dictData, forKey: kSecValueData as String)
                let status = SecItemAdd(query, nil)
                Log.api.debug("KeychainService Update status: \(String(status))")
            }
        }
    }
    
    private func load(withKey key: String) -> String? {
        let query = keychainQuery(withKey: key)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnAttributes as String)
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)
        
        guard
            let resultsDict = result as? NSDictionary,
            let resultsData = resultsDict.value(forKey: kSecValueData as String) as? Data,
            status == noErr
            else {
                Log.api.debug("KeychainService Load status: \(String(status))")
                return nil
        }
        return String(data: resultsData, encoding: .utf8)
    }
    
    private func keychainQuery(withKey key: String) -> NSMutableDictionary {
        let result = NSMutableDictionary()
        result.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        result.setValue(key, forKey: kSecAttrService as String)
        result.setValue(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, forKey: kSecAttrAccessible as String)
        return result
    }
}

final class KeychainService: KeychainProtocol {}
