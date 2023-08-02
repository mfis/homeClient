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
    
    static let shared = LiveActivityViewModel()
    
    @Published private var token: String?
    @Published private(set) var contentState: HomeLiveActivityAttributes.ContentState?
    @Published var isActive = false
    @Published var isStartIssueFrequentPushedSetting = false
    
    private let activityInfo = ActivityAuthorizationInfo()
    private var homeLiveActivity: Activity<HomeLiveActivityAttributes>?
    private var idQueue = FixedSizeFiFoQueue(maxSize: 10)
    
    init() {}
    
    func start() {
        
        guard ActivityAuthorizationInfo().frequentPushesEnabled else {
            isStartIssueFrequentPushedSetting = true
            return
        }
        
        guard activityInfo.areActivitiesEnabled else {
            return
        }
        
        let attr = HomeLiveActivityAttributes()
        
        do {
            let activity = try Activity<HomeLiveActivityAttributes>.request(
                attributes: attr,
                content: emptyContentState(),
                pushType: .token
            )
            homeLiveActivity = activity
            isActive = true
            aquirePushTokenUpdates(activity: activity)
        } catch {
            NSLog("LiveActivity could not be started: \(error)")
        }
    }
    
    func aquirePushTokenUpdates(activity: Activity<HomeLiveActivityAttributes>) {
        
        // MARK: Token
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
        
        // MARK: Update
        Task {
            for await contentUpdate in activity.contentUpdates {
                NSLog("UPDATE Live Activity \(contentUpdate.state.contentId)")
                if(!idQueue.contains(searchElement: contentUpdate.state.contentId)){
                    idQueue.add(contentUpdate.state.contentId)
                    let stale = contentUpdate.staleDate == nil ? Calendar.current.date(byAdding: .minute, value: 10, to: Date())! : contentUpdate.staleDate
                    let content = ActivityContent(state: contentUpdate.state, staleDate: stale)
                    self.contentState = content.state
                    await homeLiveActivity?.update(content)
                }
            }
        }
        
        // MARK: State
        Task {
            for await stateUpdate in activity.activityStateUpdates {
                if stateUpdate == .active {
                    NSLog("activityStateUpdates: ACTIVE")
                }
                if stateUpdate == .stale {
                    NSLog("activityStateUpdates: STALE")
                    await homeLiveActivity?.update(emptyContentState())
                }
                if stateUpdate == .dismissed {
                    NSLog("activityStateUpdates: DISMISSED")
                    await dismissOrEnd()
                }
                if stateUpdate == .ended {
                    NSLog("activityStateUpdates: ENDED")
                    await dismissOrEnd()
                }
            }
        }
    }
    
    fileprivate func dismissOrEnd() async {
        
        if let token = self.token {
            sendEndToServer(token, successHandler: onSendEndToServerSuccess)
        }
        
        func onSendEndToServerSuccess(response : String, newToken : String?) {
            NSLog("sendEndToServer OK")
            let content = ActivityContent(state: emptyContentState().state, staleDate: .now)
            DispatchQueue.main.async{
                self.contentState = content.state
                Task {
                    await self.homeLiveActivity?.end(content, dismissalPolicy: .immediate)
                    self.isActive = false
                }
            }
            
 
        }
    }

    
    func end() async {
        await homeLiveActivity?.end(emptyContentState(), dismissalPolicy: .immediate)
    }
    
    fileprivate func emptyContentState() -> ActivityContent<HomeLiveActivityAttributes.ContentState> {
        
        let primary = HomeLiveActivityContentStateValue(symbolName: "square.dashed", symbolType: "sys", label: "--", val: "--", valShort: "-", color: ".white")
        let secondary = HomeLiveActivityContentStateValue(symbolName: "square.dashed", symbolType: "sys", label: "--", val: "--", valShort: "-", color: ".white")
        
        let state = HomeLiveActivityContentState(contentId: "0", timestamp: "--:--", primary: primary, secondary: secondary)
        
        let content = ActivityContent(state: state, staleDate: Calendar.current.date(byAdding: .minute, value: 10, to: Date())!)
        return content
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
    
    fileprivate func sendEndToServer(_ token: String, successHandler : @escaping HttpSuccessHandler) {
        
        func onError(msg : String, rc : Int){
            NSLog("sendEndToServer ERROR: \(rc) - ˜(msg)")
        }
        
        if(loadUserToken().isEmpty){
            return
        }
        
        let postParams = ["token": token]
        
        httpCall(urlString: loadUrl() + "liveActivityEnd", pin: nil, timeoutSeconds: 10.0, method: HttpMethod.POST, postParams: postParams, authHeaderFields: getAuth(), errorHandler: onError, successHandler: successHandler)
    }
}
