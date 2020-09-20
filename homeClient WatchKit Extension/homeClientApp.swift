//
//  homeClientApp.swift
//  homeClient WatchKit Extension
//
//  Created by Matthias Fischer on 19.09.20.
//

import SwiftUI

@main
struct homeClientApp: App {
    
    @Environment(\.scenePhase) private var phase
    @StateObject private var userData = UserData().initHomeViewModel()
    
    // @SceneBuilder var body: some Scene {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView().environmentObject(userData)
            }
        }.onChange(of: phase) { newPhase in
            switch newPhase {
            case .active:
                print("*** ACTIVE phase ***")
                loadModel(userData: userData)
            case .inactive:
                print("*** INACTIVE phase ***")
                break
            case .background:
                print("*** BACKGROUND phase ***") 
                break
            @unknown default:
                print("*** DEFAULT phase ***")
                break
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

struct homeClientApp_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
