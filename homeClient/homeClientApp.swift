//
//  homeClientApp.swift
//  homeClient
//
//  Created by Matthias Fischer on 19.09.20.
//

import SwiftUI

@main
struct homeClientApp: App {
    
    @Environment(\.scenePhase) private var phase
    @StateObject private var userData = UserData()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(userData)
        }.onChange(of: phase) { newPhase in
            switch newPhase {
            case .active:
                userData.device = "CookieBased_" + UIDevice.current.name
                userData.isInBackground = false
            case .inactive:
                break
            case .background:
                userData.isInBackground = true
                userData.webViewTitle = ""
            @unknown default:
                break
            }
        }
    }
}
