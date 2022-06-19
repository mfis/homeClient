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
            ContentView().environmentObject(userData)
        }.onChange(of: phase) { newPhase in
            // #if DEBUG
                NSLog("### iOS App onChange: \(newPhase)")
            // #endif
            switch newPhase {
            case .active:
                userData.isInBackground = false
                break
            case .inactive:
                userData.isInBackground = true
                break
            case .background:
                userData.isInBackground = true
                userData.webViewTitle = ""
                UIApplication.shared.applicationIconBadgeNumber = 0
                WidgetCenter.shared.reloadAllTimelines()
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
        // print("Notification settings: \(settings)")
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
                                    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            let userInfo = notification.request.content.userInfo
            print(userInfo) // the payload that is attached to the push notification
            // you can customize the notification presentation options. Below code will show notification banner as well as play a sound. If you want to add a badge too, add .badge in the array.
            completionHandler([UNNotificationPresentationOptions.banner])
            WidgetCenter.shared.reloadAllTimelines()
    }
}



