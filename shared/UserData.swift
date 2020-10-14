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
    
    func initHomeViewModel() -> UserData {
        
        if let infoPath = Bundle.main.path(forResource: "Info.plist", ofType: nil),
           let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
           let infoDate : Date = infoAttr[FileAttributeKey(rawValue: "NSFileCreationDate")] as? Date
         {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmm"
            build = formatter.string(from: infoDate)
        }
        
        loadModel(userData: self)
        return self
    } 
    
    @Published var device = "GenericDevice"
    
    @Published var homeUrl = loadUrl()
    @Published var settingsUrl = loadUrl()
    @Published var lastCalledUrl = ""
    
    @Published var homeUserName = loadUserName()
    @Published var settingsUserName = loadUserName()
    
    @Published var homeUserToken = loadUserToken()
    
    @Published var settingsUserPassword = ""
    
    @Published var loginState = ""
    
    @Published var webViewTitle = ""
    
    @Published var isInBackground = false
    @Published var showAlert = false
    
    @Published var settingsStateName = "circle"
    @Published var settingsLoginMessage = ""
    
    @Published var homeViewModel = newEmptyModel(state: "", msg: "")
    @Published var clearHomeViewModel = newEmptyModel(state: "", msg: "")
    @Published var modelTimestamp = "n/a"
    
    @Published var build : String = "n/a"
}
