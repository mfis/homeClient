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

@main
struct homeClientApp: App {
    
    @Environment(\.scenePhase) private var phase
    @StateObject private var userData = UserData()
    // @StateObject var notificationCenter = NotificationCenter()
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(userData)
        }.onChange(of: phase) { newPhase in
            switch newPhase {
            case .active:
                // registerForPushNotifications()
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

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerForPushNotifications()
        // check if launched from notofication
        let notificationOption = launchOptions?[.remoteNotification]
        if
          let notification = notificationOption as? [String: AnyObject],
          let _ = notification["aps"] as? [String: AnyObject] {
            // launched from push notification
        }
        return true
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    /*func application(
      _ application: UIApplication,
      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
      fetchCompletionHandler completionHandler:
      @escaping (UIBackgroundFetchResult) -> Void
    ) {
      guard let _ = userInfo["aps"] as? [String: AnyObject] else {
        completionHandler(.failed)
        return
      }
      // recieved push notification while running the app
    } */
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
          .requestAuthorization(
            options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self?.getNotificationSettings()
          }
    }
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
}



