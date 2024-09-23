//
//  UserData.swift
//  iOSHomeApp
//
//  Created by Matthias Fischer on 01.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

// import Combine
import SwiftUI

final class UserData: ObservableObject {
    
    init(){}
    
    @Published var device = "GenericDevice"
    
    @Published var settingsUrl = loadUrl()
    @Published var settingsUserName = loadUserName()
    @Published var settingsUserPassword = ""
    @Published var settingsStateName = "" 
    @Published var settingsLoginMessage = ""
    @Published var settingsIsGeofencingOn = loadIsGeofencingOn();
    
    @Published var lastCalledUrl = ""

    @Published var loginState = ""
    
    @Published var webViewTitle = ""
    @Published var webViewUserName = ""
    
    @Published var webViewFastLink = ""
    @Published var webViewFastLinkIsUsed = true
    
    @Published var isInBackground = false
    @Published var webViewRefreshPending = false
    
    @Published var showAlert = false
    
    @Published var doWebViewLogout = false
    
    func prepareWebViewLogout(){
        doWebViewLogout = true
        saveUserToken(newUserToken: "")
        saveUserName(newUserName: "")
    }
    
    func prepareBackground(){
        #if os(iOS)
            webViewFastLink = ""
            webViewFastLinkIsUsed = true;
        #endif
    }
    
    @Published var watchModel = newEmptyModel(state: "", msg: "")
    @Published var clearwatchModel = newEmptyModel(state: "", msg: "")
    @Published var modelTimestamp = "n/a"
    
    @Published var pushSettingsModel = newEmptyPushSettings()
    func resetPushSettingsModel(){
        pushSettingsModel = newEmptyPushSettings()
        pushSettingsSaveInProgress = false
    }
    
    @Published var pushSettingsSaveInProgress = false

    @Published var pushHistoryListModel = newEmptyPushMessageHistoryModel()
    func resetPushHistoryListModel(){
        pushHistoryListModel = newEmptyPushMessageHistoryModel()
    }
    
    @Published var build : String = CONST_NOT_AVAILABLE
    
    @Published var lastTimerTs : String = CONST_NOT_AVAILABLE
    @Published var lastSuccessTs : String = CONST_NOT_AVAILABLE
    @Published var lastErrorTs : String = CONST_NOT_AVAILABLE
    @Published var lastErrorMsg : String = CONST_NOT_AVAILABLE
    
    func isDebugMode() -> Bool{
        #if DEBUG
        if("" == ""){
            return true
        }
        #endif
        return false
    }
}
