//
//  homeClientApp.swift
//  homeClient WatchKit Extension
//
//  Created by Matthias Fischer on 19.09.20.
//

import SwiftUI

@main
struct homeClientApp: App {
    
    @WKExtensionDelegateAdaptor private var appDelegate: ExtensionDelegate
    @Environment(\.scenePhase) private var phase
    @StateObject private var userData = initWatchModel(deviceName:  WKInterfaceDevice.current().name)
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView().environmentObject(userData)
            }
        }.onChange(of: phase) { oldPhase, newPhase in
            // #if DEBUG
                NSLog("### watch App onChange: \(newPhase)")
            // #endif
            switch newPhase {
            case .active:
                userData.isInBackground = false
                loadWatchModel(userData: userData, from : CONST_APP_ACTIVATED)
                break
            case .inactive:
                userData.isInBackground = true
                saveTimerState(newState: false)
                userData.watchModel = userData.clearwatchModel
                break
            case .background:
                userData.isInBackground = true
                saveTimerState(newState: false)
                userData.watchModel = userData.clearwatchModel
                scheduleComplicationBackgroundRefresh()
                loadComplicationData()
                userData.prepareBackground()
                break
            @unknown default:
                break
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

