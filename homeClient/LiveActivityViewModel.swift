//
//  LiveActivityViewModel.swift
//  homeClient
//
//  Created by Matthias Fischer on 09.07.23.
//

import ActivityKit
import SwiftUI

@MainActor
class LiveActivityViewModel: ObservableObject {
    
    @Published private var token: String?
    @Published private(set) var contentState: HomeLiveActivityAttributes.ContentState?
    
    private let activityInfo = ActivityAuthorizationInfo()
    private var homeLiveActivity: Activity<HomeLiveActivityAttributes>?
    init() {}
    
    func start() {
        
        guard activityInfo.areActivitiesEnabled else {
            return
        }
        
        let attr = HomeLiveActivityAttributes(labelLeading: "Photovoltaik", labelTrailing: "", symbolLeading: "window.ceiling", symbolTrailing: "")
        let state = HomeLiveActivityAttributes.ContentState(valueLeading: "4200 W", valueTrailing: "", colorLeading: "green", colorTrailing: "")
        let content = ActivityContent(state: state, staleDate: Calendar.current.date(byAdding: .hour, value: 4, to: Date())!)
        
        do {
            let activity = try Activity<HomeLiveActivityAttributes>.request(
                attributes: attr,
                content: content,
                pushType: .token
            )
            homeLiveActivity = activity
            aquirePushTokenUpdates(activity: activity)
        } catch {
            NSLog("LiveActivity could not be started: \(error)")
        }
    }
    
    func aquirePushTokenUpdates(activity: Activity<HomeLiveActivityAttributes>) {
        
        Task {
            for await data in activity.pushTokenUpdates {
                let token = data.map { String(format: "%02x", $0) }.joined()
                self.token = token
                #if targetEnvironment(simulator)
                    UIPasteboard.general.string = token
                #endif
            }
        }
        Task {
            for await contentUpdate in activity.contentUpdates {
                self.contentState = contentUpdate.state
            }
        }
    }

    
    func end() async {
        
        let state = HomeLiveActivityAttributes.ContentState(valueLeading: "--", valueTrailing: "", colorLeading: "green", colorTrailing: "")
        let content = ActivityContent(state: state, staleDate: .now)
        await homeLiveActivity?.end(content, dismissalPolicy: .immediate)
    }
    
}
