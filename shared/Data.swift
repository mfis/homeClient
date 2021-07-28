//
//  Data.swift
//  iOSHomeApp
//
//  Created by Matthias Fischer on 01.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

import Foundation

fileprivate let userDefaults = UserDefaults.init(suiteName: "group.de.fimatas.homeClient")!

func migrateUserDefaults() {
    
    let old = UserDefaults.standard
    
    if let x = old.string(forKey: "userDefaultKeyUrl") {
        if(loadUrl().isEmpty){
            saveUrl(newUrl: x)
            old.removeObject(forKey: "userDefaultKeyUrl")
        }
    }

    if let x = old.string(forKey: "userDefaultKeyUserName") {
        if(loadUserName().isEmpty){
            saveUserName(newUserName: x)
            old.removeObject(forKey: "userDefaultKeyUserName")
        }
    }

    if let x = old.string(forKey: "userDefaultKeyUserToken") {
        if(loadUserToken().isEmpty){
            saveUserToken(newUserToken: x)
            old.removeObject(forKey: "userDefaultKeyUserToken")
        }
    }

    if let x = old.string(forKey: "userDefaultKeyPushToken") {
        if(loadPushToken().isEmpty){
            savePushToken(newPushToken: x)
            old.removeObject(forKey: "userDefaultKeyPushToken")
        }
    }
    
}

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
        #if DEBUG
            NSLog("### loadUserToken(): \(x.prefix(50))")
        #endif
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

func currentTimeMillis() -> Int64{
   let nowDouble = NSDate().timeIntervalSince1970
   return Int64(nowDouble*1000)
}
