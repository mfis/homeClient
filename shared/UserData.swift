//
//  UserData.swift
//  iOSHomeApp
//
//  Created by Matthias Fischer on 01.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

import Combine
import SwiftUI

final class UserData: ObservableObject {
    
    func initHomeViewModel(deviceName : String?, loadWatchModel : Bool) -> UserData {
        
        if let infoPath = Bundle.main.path(forResource: "Info.plist", ofType: nil),
           let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
           let infoDate : Date = infoAttr[FileAttributeKey(rawValue: "NSFileCreationDate")] as? Date
         {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmm"
            build = formatter.string(from: infoDate)
        }
        
        if let deviceName = deviceName{
            device = deviceName.replacingOccurrences( of:"[^0-9A-Za-z]", with: "", options: .regularExpression)
        }
        if(loadWatchModel){
            loadModel(userData: self, from: "init")
        }
        return self
    } 
    
    @Published var device = "GenericDevice"
    
    @Published var homeUrl = loadUrl()
    @Published var settingsUrl = loadUrl()
    @Published var lastCalledUrl = ""
    
    @Published var homeUserName = loadUserName()
    @Published var settingsUserName = loadUserName()
    
    @Published var homeUserToken = loadUserToken()
    
    @Published var pushToken = loadPushToken()
    func lookupPushToken() -> String {
        if(pushToken.isEmpty){
            pushToken = loadPushToken()
            if(pushToken.isEmpty){
                pushToken = "n/a"
            }
        }
        return pushToken
    }
    
    @Published var settingsUserPassword = ""
    
    @Published var loginState = ""
    
    @Published var webViewTitle = ""
    
    @Published var webViewPath = ""
    
    @Published var isInBackground = false
    @Published var showAlert = false
    @Published var doWebViewLogout = false
    
    @Published var settingsStateName = "circle"
    @Published var settingsLoginMessage = ""
    
    @Published var homeViewModel = newEmptyModel(state: "", msg: "")
    @Published var clearHomeViewModel = newEmptyModel(state: "", msg: "")
    @Published var modelTimestamp = "n/a"
    
    @Published var doTimer = true
    @Published var doTokenRefresh = true
    
    @Published var build : String = "n/a"
    @Published var lastErrorMsg : String = ""
}
