//
//  Content.swift
//  watchHomeApp Extension
//
//  Created by Matthias Fischer on 13.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

import Foundation

let CONST_APP_STARTED = "started"
let CONST_APP_ACTIVATED = "activated"
let CONST_APP_TIMER = "timer"
let TIMER_INTERVAL_SECONDS : Double = 4.0

fileprivate let dispatchQueueLoadModel = DispatchQueue(label: "DispatchQueueLoadModel", attributes: .concurrent)

func initWatchModel(deviceName : String?) -> UserData {
    let userData =  initHomeViewModel(deviceName:  deviceName)
    userData.isInBackground = false
    
    #if targetEnvironment(simulator)
        userData.settingsUrl = "http://192.168.2.111:8099"
        userData.settingsUserName = "test"
        userData.settingsUserPassword = "abc"
    #endif
    
    loadWatchModel(userData: userData, from : CONST_APP_STARTED)
    return userData
}

func loadWatchModel(userData : UserData, from : String) {
    
    DispatchQueue.main.async() {
        userData.lastTimerTs = formattedTS()
    }
        
    if((from == CONST_APP_TIMER && !loadTimerState()) || userData.isInBackground){
        return
    }

    if(loadUserToken().isEmpty){
        DispatchQueue.main.async() {
            userData.watchModel = newEmptyModel(state: "👉", msg: "Bitte anmelden")
        }
        return
    }
    
    loadModelInternal(userData: userData, from: from, target: "watch")
}

fileprivate func loadModelInternal(userData : UserData, from : String, target : String) {
    
    func onError(msg : String, rc : Int){
        
        setTimerOn(userData: userData, rc : rc)
        
        DispatchQueue.main.async() {
            userData.watchModel = userData.clearwatchModel
            userData.lastErrorMsg = "load_\(from):" + msg
            userData.lastErrorTs = formattedTS()
        }
    }
    
    func onSuccess(response : String, newToken : String?){

        if let token = newToken{
            saveUserToken(newUserToken: token)
        }
        setTimerOn(userData: userData, rc: 200)
        
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
                userData.lastSuccessTs = formattedTS()
            }
            if(from == CONST_APP_STARTED || from == CONST_APP_ACTIVATED){
                refreshComplicationData(model: newModel)
            }

        } catch let jsonError as NSError {
            onError(msg : "error parsing json document. \(jsonError.localizedDescription)", rc : -2)
            #if DEBUG
                NSLog("json response: " + response)
            #endif
        }
    }
    
    let timeout : Double = from == CONST_APP_TIMER ? TIMER_INTERVAL_SECONDS : TIMER_INTERVAL_SECONDS * 2.0;
    let refreshToken : String = from == CONST_APP_ACTIVATED || from == CONST_APP_STARTED ? "true" : "false"
    
    let authDict = ["appUserName": loadUserName(), "appUserToken": loadUserToken(), "appDevice" : userData.device, "refreshToken" : refreshToken]
    
    httpCall(urlString: loadUrl() + "getAppModel?viewTarget=" + target, pin: nil, timeoutSeconds: timeout, method: HttpMethod.GET, postParams: nil, authHeaderFields: authDict, errorHandler: onError, successHandler: onSuccess)
}

fileprivate func setTimerOn(userData : UserData, rc : Int) {
    if(userData.isInBackground || rc == 401){
        saveTimerState(newState: false)
    }else{
        saveTimerState(newState: true)
    }
}

