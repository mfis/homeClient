//
//  Content.swift
//  watchHomeApp Extension
//
//  Created by Matthias Fischer on 13.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

import Foundation

fileprivate var lastLoadModelStart : Int64 = 0
fileprivate var lastLoadModelEnd : Int64 = 0
fileprivate let MIN_TIME_DIFF : Int64 = 4900
fileprivate let dispatchQueueLoadModel = DispatchQueue(label: "DispatchQueueLoadModel", attributes: .concurrent)

func loadModel(userData : UserData, from : String) {
    
    dispatchQueueLoadModel.async(flags: .barrier) {
        
        let actualTime : Int64 = currentTimeMillis()
        if(actualTime - lastLoadModelStart < MIN_TIME_DIFF || actualTime - lastLoadModelEnd < MIN_TIME_DIFF){
            print("loadModel... still actual update=" + userData.doTokenRefresh.description)
            return
        }

        if(userData.homeUrl.isEmpty){
            DispatchQueue.main.async() {
                userData.homeViewModel = newEmptyModel(state: "👉", msg: "Bitte anmelden")
            }
            return
        }
        
        lastLoadModelStart = actualTime
        print("loadModel... STARTING update=" + userData.doTokenRefresh.description)
        
        loadModelInternal(userData: userData, from: from)
    }
}

fileprivate func loadModelInternal(userData : UserData, from : String) {
    
    func onError(msg : String, rc : Int){
        
        if(rc == 401){
            userData.doTimer = false
        }
        
        DispatchQueue.main.async() {
            userData.homeViewModel = userData.clearHomeViewModel
            userData.lastErrorMsg = "load_\(from):" + msg
        }
    }
    
    func onSuccess(response : String, newToken : String?){
        
        lastLoadModelEnd = currentTimeMillis()
        
        if let token = newToken{
            userData.doTokenRefresh = false
            userData.homeUserToken = token
            saveUserToken(newUserToken: token)
        }
        
        let decoder = JSONDecoder ()
        if var newModel = try? decoder.decode(HomeViewModel.self, from: response.data(using: .utf8)!) {
            var clearModel = newModel
            clearModel.timestamp = ". . ."
            for (i, var place) in clearModel.places.enumerated() {
                for (j, var kv) in place.values.enumerated() {
                    kv.value = ". . ."
                    kv.tendency = ""
                    kv.accent = clearModel.defaultAccent
                    place.values[j] = kv
                }
                clearModel.places[i] = place
            }
            DispatchQueue.main.async() {
                userData.clearHomeViewModel = clearModel
                userData.modelTimestamp = newModel.timestamp
                newModel.timestamp = "OK"
                userData.homeViewModel = newModel
            }
            
        }else{
            onError(msg : "error parsing json document", rc : -2)
        }
    }
    
    let authDict = ["appUserName": userData.homeUserName, "appUserToken": userData.homeUserToken, "appDevice" : userData.device, "refreshToken" : userData.doTokenRefresh.description]
    httpCall(urlString: userData.homeUrl + "getAppModel?viewTarget=watch", timeoutSeconds: 6.0, method: HttpMethod.GET, postParams: nil, authHeaderFields: authDict, errorHandler: onError, successHandler: onSuccess)
}

