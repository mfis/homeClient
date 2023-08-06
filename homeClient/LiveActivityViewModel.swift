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
    @Published var isActive = false
    @Published var isStartIssueFrequentPushedSetting = false
    @Published var isStartIssueContactingServer = false
    
    private let activityInfo = ActivityAuthorizationInfo()
    private var homeLiveActivity: Activity<HomeLiveActivityAttributes>?
    private var idQueue = FixedSizeFiFoQueue(maxSize: 10)
    
    init() {}
    
    func start() {
        
        isStartIssueContactingServer = false
        
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
                content: emptyContentState(isStale: false),
                pushType: .token
            )
            homeLiveActivity = activity
            isActive = true
            aquirePushTokenUpdates(activity: activity)
        } catch {
            logInSimulator("LiveActivity could not be started: \(error)")
        }
    }
    
    func aquirePushTokenUpdates(activity: Activity<HomeLiveActivityAttributes>) {
        
        // MARK: Token
        Task {
            for await data in activity.pushTokenUpdates {
                let token = data.map { String(format: "%02x", $0) }.joined()
                self.token = token
                if let token = self.token {
                    sendStartToServer(token)
                }
            }
        }
        
        // MARK: Update
        Task {
            for await contentUpdate in activity.contentUpdates {
                logInSimulator("UPDATE Live Activity \(contentUpdate.state.contentId)")
                if(!idQueue.contains(searchElement: contentUpdate.state.contentId)){
                    idQueue.add(contentUpdate.state.contentId)
                    let stale = Calendar.current.date(byAdding: .second, value: Int(contentUpdate.state.dismissSeconds) ?? 0, to: Date())!
                    logInSimulator("UPDATE Live Activity WITH STALE \(contentUpdate.state.contentId) - \(stale)")
                    let content = ActivityContent(state: contentUpdate.state, staleDate: stale)
                    await homeLiveActivity?.update(content)
                }
            }
        }
        
        // MARK: State
        Task {
            for await stateUpdate in activity.activityStateUpdates {
                if stateUpdate == .active {
                    logInSimulator("activityStateUpdates: ACTIVE")
                }
                if stateUpdate == .stale {
                    logInSimulator("activityStateUpdates: STALE")
                    await homeLiveActivity?.update(emptyContentState(isStale: true))
                }
                if stateUpdate == .dismissed {
                    logInSimulator("activityStateUpdates: DISMISSED")
                    await dismissOrEnd()
                }
                if stateUpdate == .ended {
                    logInSimulator("activityStateUpdates: ENDED")
                    await dismissOrEnd()
                }
            }
        }
    }
    
    fileprivate func dismissOrEnd() async {
        
        if let token = self.token {
            sendEndToServer(token, successHandler: onSendEndToServerSuccess)
        }

        let content = ActivityContent(state: emptyContentState(isStale: true).state, staleDate: .now)
        Task {
            await self.homeLiveActivity?.end(content, dismissalPolicy: .immediate)
            self.isActive = false
        }
        
        func onSendEndToServerSuccess(response : String, newToken : String?) {
            logInSimulator("sendEndToServer OK")
        }
    }

    
    func end() async {
        await homeLiveActivity?.end(emptyContentState(isStale: false), dismissalPolicy: .immediate)
    }
    
    fileprivate func emptyContentState(isStale : Bool) -> ActivityContent<HomeLiveActivityAttributes.ContentState> {
        
        let singleState = HomeLiveActivityContentStateValue(symbolName: "", symbolType: "", label: "", val: "", valShort: "", color: "")
        
        let state = HomeLiveActivityContentState(contentId: UUID().uuidString, timestamp: "--:--", dismissSeconds: isStale ? "0" : "60", primary: singleState, secondary: singleState, tertiary: singleState)
        
        let content = ActivityContent(state: state, staleDate: Calendar.current.date(byAdding: .second, value: Int(state.dismissSeconds) ?? 0, to: Date())!)
        return content
    }
    
    fileprivate func sendStartToServer(_ token: String) {
        
        func onError(msg : String, rc : Int) {
            DispatchQueue.main.async {
                self.isStartIssueContactingServer = true
            }
            Task {
                await end()
            }
            logInSimulator("sendStartToServer ERROR: \(rc) - ˜(msg)")
        }
        
        func onSuccess(response : String, newToken : String?){
            logInSimulator("sendStartToServer OK - \(token)")
        }
        
        if(loadUserToken().isEmpty){
            return
        }
        
        let postParams = ["token": token]
        
        httpCall(urlString: loadUrl() + "liveActivityStart", pin: nil, timeoutSeconds: 10.0, method: HttpMethod.POST, postParams: postParams, authHeaderFields: getAuth(), errorHandler: onError, successHandler: onSuccess)
    }
    
    fileprivate func sendEndToServer(_ token: String, successHandler : @escaping HttpSuccessHandler) {
        
        func onError(msg : String, rc : Int){
            logInSimulator("sendEndToServer ERROR: \(rc) - ˜(msg)")
        }
        
        if(loadUserToken().isEmpty){
            return
        }
        
        let postParams = ["token": token]
        
        httpCall(urlString: loadUrl() + "liveActivityEnd", pin: nil, timeoutSeconds: 10.0, method: HttpMethod.POST, postParams: postParams, authHeaderFields: getAuth(), errorHandler: onError, successHandler: successHandler)
    }
    
    fileprivate func logInSimulator(_ msg : String){
        #if targetEnvironment(simulator)
            NSLog(msg)
        #endif
    }
}
