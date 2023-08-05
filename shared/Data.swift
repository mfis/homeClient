//
//  Data.swift
//  iOSHomeApp
//
//  Created by Matthias Fischer on 01.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

import Foundation

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
