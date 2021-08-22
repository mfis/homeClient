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
    
    @Published var device = "GenericDevice"
    
    @Published var settingsUrl = loadUrl()
    @Published var settingsUserName = loadUserName()
    @Published var settingsUserPassword = ""
    @Published var settingsStateName = "circle"
    @Published var settingsLoginMessage = ""
    
    @Published var lastCalledUrl = ""

    @Published var loginState = ""
    
    @Published var webViewTitle = ""
    @Published var webViewPath = ""
    
    @Published var isInBackground = false
    
    @Published var showAlert = false
    @Published var doWebViewLogout = false
    
    @Published var watchModel = newEmptyModel(state: "", msg: "")
    @Published var clearwatchModel = newEmptyModel(state: "", msg: "")
    @Published var modelTimestamp = "n/a"
    
    @Published var build : String = "n/a"
    
    @Published var lastTimerTs : String = "n/a"
    @Published var lastSuccessTs : String = "n/a"
    @Published var lastErrorTs : String = "n/a"
    @Published var lastErrorMsg : String = "n/a"
}
