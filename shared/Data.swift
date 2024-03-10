//
//  Data.swift
//  iOSHomeApp
//
//  Created by Matthias Fischer on 01.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

import Foundation
import AuthenticationServices

fileprivate let userDefaults = UserDefaults.init(suiteName: "group.de.fimatas.homeClient")!

func loadUrl() -> String {
    if let x = userDefaults.string(forKey: "userDefaultKeyUrl") {
        return x
    }else{
        return ""
    }
}

func saveUrl(newUrl : String) {
    userDefaults.setValue(newUrl, forKey: "userDefaultKeyUrl")
}

func loadUserName() -> String {
    if let x = userDefaults.string(forKey: "userDefaultKeyUserName") {
        return x
    }else{
        return ""
    }
}

func saveUserName(newUserName : String) {
    userDefaults.setValue(newUserName, forKey: "userDefaultKeyUserName")
}

func loadUserToken() -> String {
    if let x = userDefaults.string(forKey: "userDefaultKeyUserToken") {
        return x
    }else{
        return ""
    }
}

func saveUserToken(newUserToken : String) {
    #if DEBUG
        NSLog("### saveUserToken(): \(newUserToken.prefix(50))")
    #endif
    userDefaults.setValue(newUserToken, forKey: "userDefaultKeyUserToken")
}

func loadPushToken() -> String {
    if let x = userDefaults.string(forKey: "userDefaultKeyPushToken") {
        return x
    }else{
        return ""
    }
}

func savePushToken(newPushToken : String) {
    userDefaults.setValue(newPushToken, forKey: "userDefaultKeyPushToken")
}

func loadRefreshState() -> Bool {
    if let x = userDefaults.string(forKey: "userDefaultRefreshState") {
        return x == "true" ? true : false
    }else{
        return true
    }
}

func saveRefreshState(newState : Bool) {
    userDefaults.setValue(newState==true ? "true" : "false", forKey: "userDefaultRefreshState")
}

func loadTimerState() -> Bool {
    if let x = userDefaults.string(forKey: "userDefaultTimerState") {
        return x == "true" ? true : false
    }else{
        return true
    }
}

func saveTimerState(newState : Bool) {
    userDefaults.setValue(newState==true ? "true" : "false", forKey: "userDefaultTimerState")
}

func loadDeviceName() -> String {
    if let x = userDefaults.string(forKey: "userDefaultKeyDeviceName") {
        return x
    }else{
        return ""
    }
}

func saveDeviceName(newUrl : String) {
    userDefaults.setValue(newUrl, forKey: "userDefaultKeyDeviceName")
}

func loadComplicationError() -> String {
    if let x = userDefaults.string(forKey: "userDefaultKeyComplicationError") {
        return x
    }else{
        return ""
    }
}

func saveComplicationError(newString : String) {
    userDefaults.setValue(newString, forKey: "userDefaultKeyComplicationError")
}

func loadIsGeofencingOn() -> Bool {
    if let x = userDefaults.string(forKey: "isGeofencingOn") {
        return x == "true" ? true : false
    }else{
        return false // default
    }
}

func saveIsGeofencingOn(newValue : Bool) {
    userDefaults.setValue(newValue==true ? "true" : "false", forKey: "isGeofencingOn")
}

func loadGeofencingRadius() -> Double? {
    if let x = userDefaults.string(forKey: "userDefaultKeyGeofencingRadius") {
        return Double(x)
    }else{
        return nil
    }
}

func saveGeofencingRadius(newVal : Double) {
    userDefaults.setValue(newVal, forKey: "userDefaultKeyGeofencingRadius")
}

func loadGeofencingLon() -> Double? {
    if let x = userDefaults.string(forKey: "userDefaultKeyGeofencingLon") {
        return Double(x)
    }else{
        return nil
    }
}

func saveGeofencingLon(newVal : Double) {
    userDefaults.setValue(newVal, forKey: "userDefaultKeyGeofencingLon")
}

func loadGeofencingLat() -> Double? {
    if let x = userDefaults.string(forKey: "userDefaultKeyGeofencingLat") {
        return Double(x)
    }else{
        return nil
    }
}

func saveGeofencingLat(newVal : Double) {
    userDefaults.setValue(newVal, forKey: "userDefaultKeyGeofencingLat")
}

func loadIsWebViewTerminated() -> Bool {
    if let x = userDefaults.string(forKey: "userDefaultIsWebViewTerminated") {
        return x == "true" ? true : false
    }else{
        return false
    }
}

func saveIsWebViewTerminated(newState : Bool) {
    userDefaults.setValue(newState==true ? "true" : "false", forKey: "userDefaultIsWebViewTerminated")
}

func keychainSave(serviceName : String, value : String) {
    if keychainRead(serviceName: serviceName) != nil{
        keychainUpdate(serviceName: serviceName, value: value)
    }else {
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: loadUserName().sanitized,
            kSecValueData as String: value.data(using: .utf8)!,
            kSecAttrService as String: serviceName.sanitized
        ]
        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status == noErr {
            return
        } else {
            NSLog("keychain: could not write \(serviceName) : \(status.description)")
        }
    }
}

func keychainRead(serviceName : String) -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: loadUserName().sanitized,
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnAttributes as String: true,
        kSecReturnData as String: true,
        kSecAttrService as String: serviceName.sanitized
    ]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    if status == noErr {
        if let existingItem = item as? [String: Any],
           let passwordData = existingItem[kSecValueData as String] as? Data,
           let password = String(data: passwordData, encoding: .utf8) {
               return password
        } else {
            NSLog("keychain: unexpected item")
            return nil
        }
    } else if (status == errSecItemNotFound){
        return nil
    } else {
        NSLog("keychain: could not read \(serviceName) : \(status.description)")
        return nil
    }
}

func keychainUpdate(serviceName : String, value : String) {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: loadUserName().sanitized,
        kSecAttrService as String: serviceName.sanitized
    ]
    let attributes: [String: Any] = [kSecValueData as String: value.data(using: .utf8)!]
    let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    if status == noErr {
        return
    } else {
        NSLog("keychain: could not update \(serviceName) : \(status.description)")
    }
}

func keychainDelete(serviceName : String) {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: loadUserName().sanitized,
        kSecAttrService as String: serviceName.sanitized
    ]
    let status = SecItemDelete(query as CFDictionary)
    if status == noErr {
        return
    } else {
        NSLog("keychain: could not delete \(serviceName) : \(status.description)")
    }
}
