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
        
        let attr = HomeLiveActivityAttributes(labelLeading: "Test", labelTrailing: "", symbolLeading: "plus.app", symbolTrailing: "")
        let state = HomeLiveActivityAttributes.ContentState(valueLeading: "init", valueTrailing: "", colorLeading: ".green", colorTrailing: "")
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
                if let token = self.token {
                    sendStartToServer(token)
                }
            }
        }
        Task {
            for await contentUpdate in activity.contentUpdates {
                NSLog("UPDATE Live Activity \(contentUpdate.state.valueLeading) \(contentUpdate.staleDate)")
                self.contentState = contentUpdate.state
                await homeLiveActivity?.update(contentUpdate)
                #warning("manually set stale date !!")
            }
        }
        Task {
            for await stateUpdate in activity.activityStateUpdates {
                if stateUpdate == .active {
                    NSLog("activityStateUpdates: ACTIVE")
                }
                if stateUpdate == .stale {
                    NSLog("activityStateUpdates: STALE")
                    let state = HomeLiveActivityAttributes.ContentState(valueLeading: "STALE", valueTrailing: "", colorLeading: ".green", colorTrailing: "")
                    self.contentState = state
                    let content = ActivityContent(state: state, staleDate: Calendar.current.date(byAdding: .minute, value: 10, to: Date())!)
                    await homeLiveActivity?.update(content)
                    // await activity?.update(using: content)
                }
                if stateUpdate == .dismissed {
                    NSLog("activityStateUpdates: DISMISSED")
                    await end()
                }
                if stateUpdate == .ended {
                    NSLog("activityStateUpdates: ENDED")
                }
            }
        }
    }

    
    func end() async {
        
        let state = HomeLiveActivityAttributes.ContentState(valueLeading: "--", valueTrailing: "", colorLeading: "green", colorTrailing: "")
        let content = ActivityContent(state: state, staleDate: .now)
        await homeLiveActivity?.end(content, dismissalPolicy: .immediate)
        
        if let token = self.token {
            sendEndToServer(token)
        }
    }
    
    fileprivate func sendStartToServer(_ token: String) {
        
        func onError(msg : String, rc : Int){
            NSLog("sendStartToServer ERROR: \(rc) - ˜(msg)")
        }
        
        func onSuccess(response : String, newToken : String?){
            NSLog("sendStartToServer OK - \(token)")
        }
        
        if(loadUserToken().isEmpty){
            return
        }
        
        let postParams = ["token": token]
        
        httpCall(urlString: loadUrl() + "liveActivityStart", pin: nil, timeoutSeconds: 10.0, method: HttpMethod.POST, postParams: postParams, authHeaderFields: getAuth(), errorHandler: onError, successHandler: onSuccess)
    }
    
    #warning("handling end from lock screen")
    fileprivate func sendEndToServer(_ token: String) {
        
        func onError(msg : String, rc : Int){
            NSLog("sendEndToServer ERROR: \(rc) - ˜(msg)")
        }
        
        func onSuccess(response : String, newToken : String?){
            NSLog("sendEndToServer OK - \(token)")
        }
        
        if(loadUserToken().isEmpty){
            return
        }
        
        let postParams = ["token": token]
        
        httpCall(urlString: loadUrl() + "liveActivityEnd", pin: nil, timeoutSeconds: 10.0, method: HttpMethod.POST, postParams: postParams, authHeaderFields: getAuth(), errorHandler: onError, successHandler: onSuccess)
    }
}
