//
//  homeClientApp.swift
//  homeClient
//
//  Created by Matthias Fischer on 19.09.20.
//

import SwiftUI
import UserNotifications
import CoreData
import os
import WidgetKit

@main
struct homeClientApp: App {
    
    @Environment(\.scenePhase) private var phase
    @StateObject private var userData = initHomeViewModel(deviceName: UIDevice.current.name)
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject var location = Location.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(userData).preferredColorScheme(.dark).onOpenURL { url in
                if let idRange = url.absoluteString.range(of: "?id=") { // FIXME
                    let id = url.absoluteString.suffix(from: idRange.upperBound)
                    userData.webViewFastLink = id.description
                    userData.webViewFastLinkIsUsed = false
                }
            }
        }.onChange(of: phase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                userData.isInBackground = false
                userData.showLoadingIndicator = true
                HomeWebView.shared.handleAppInForeground()
                break
            case .inactive:
                userData.isInBackground = false
                break
            case .background:
                userData.isInBackground = true
                userData.webViewTitle = ""
                userData.prepareBackground()
                UNUserNotificationCenter.current().setBadgeCount(0, withCompletionHandler: nil)
                WidgetCenter.shared.reloadAllTimelines()
                userData.webViewRefreshPending = true
                HomeWebView.shared.handleAppInBackround()
                break
            @unknown default:
                break
            }
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerForPushNotifications()
        // check if launched from notification
        let notificationOption = launchOptions?[.remoteNotification]
        if
          let notification = notificationOption as? [String: AnyObject],
          let _ = notification["aps"] as? [String: AnyObject] {
            // launched from push notification
        }
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        savePushToken(newPushToken: token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
          .requestAuthorization(
            options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            // print("Permission granted: \(granted)")
            guard granted else { return }
            self?.getNotificationSettings()
          }
    }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
            willPresent notification: UNNotification,
            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            // let userInfo = notification.request.content.userInfo
            // NSLog("userInfo = \(userInfo)")
            completionHandler([UNNotificationPresentationOptions.banner])
            WidgetCenter.shared.reloadAllTimelines()
    }
}



