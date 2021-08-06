//
//  Content.swift
//  watchHomeApp Extension
//
//  Created by Matthias Fischer on 13.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

import Foundation

let CONST_APP_ACTIVATED = "activated"
let CONST_APP_TIMER = "timer"
let TIMER_INTERVAL_SECONDS : Double = 4.0

fileprivate let dispatchQueueLoadModel = DispatchQueue(label: "DispatchQueueLoadModel", attributes: .concurrent)

func loadWatchModel(userData : UserData, from : String) { 
    
    DispatchQueue.main.async() {
        userData.lastTimerTs = formattedTS()
    }
        
    if(from == CONST_APP_TIMER && !userData.doTimer){
        return
    }

    if(userData.homeUserToken.isEmpty){
        DispatchQueue.main.async() {
            userData.watchModel = newEmptyModel(state: "👉", msg: "Bitte anmelden")
        }
        return
    }
    
    loadModelInternal(userData: userData, from: from, target: "watch")
}

fileprivate func loadModelInternal(userData : UserData, from : String, target : String) {
    
    func onError(msg : String, rc : Int){
        
        if(rc == 401){
            DispatchQueue.main.async() {
                userData.doTimer = false
            }
        }
        
        DispatchQueue.main.async() {
            userData.watchModel = userData.clearwatchModel
            userData.lastErrorMsg = "load_\(from):" + msg
            userData.lastErrorTs = formattedTS()
            setTimerOn(userData: userData)
        }
    }
    
    func onSuccess(response : String, newToken : String?){
        
        DispatchQueue.main.async() {
            userData.lastSuccessTs = formattedTS()
        }
        
        let decoder = JSONDecoder ()
        do{
        var newModel = try decoder.decode(HomeViewModel.self, from: response.data(using: .utf8)!)
            var clearModel = newModel
                clearModel.timestamp = ". . ."
                for (i, var place) in clearModel.places.enumerated() {
                    for (j, var kv) in place.values.enumerated() {
                        kv.value = ". . ."
                        kv.tendency = ""
                        kv.accent = clearModel.defaultAccent
                        place.values[j] = kv
                        place.actions = []
                    }
                    clearModel.places[i] = place
                }
                DispatchQueue.main.async() {
                    userData.clearwatchModel = clearModel
                }
            
            DispatchQueue.main.async() {
                userData.modelTimestamp = newModel.timestamp
                newModel.timestamp = "OK"
                userData.watchModel = newModel
            }

        } catch let jsonError as NSError {
            onError(msg : "error parsing json document. \(jsonError.localizedDescription)", rc : -2)
            #if DEBUG
                NSLog("json response: " + response)
            #endif
        }
        
        DispatchQueue.main.async() {
            if let token = newToken{
                userData.homeUserToken = token
                saveUserToken(newUserToken: token)
            }
            setTimerOn(userData: userData)
        }
    }
    
    let timeout : Double = from == CONST_APP_TIMER ? TIMER_INTERVAL_SECONDS : TIMER_INTERVAL_SECONDS * 2.0;
    let refreshToken : String = from == CONST_APP_ACTIVATED ? "true" : "false"
    
    let authDict = ["appUserName": userData.homeUserName, "appUserToken": userData.homeUserToken, "appDevice" : userData.device, "refreshToken" : refreshToken]
    
    httpCall(urlString: userData.homeUrl + "getAppModel?viewTarget=" + target, pin: nil, timeoutSeconds: timeout, method: HttpMethod.GET, postParams: nil, authHeaderFields: authDict, errorHandler: onError, successHandler: onSuccess)
}

fileprivate func setTimerOn(userData : UserData) {
    if(userData.isInBackground){
        userData.doTimer = false
    }else{
        userData.doTimer = true
    }
}

fileprivate func formattedTS() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd_HHmmss"
    return formatter.string(from: Date())
}
