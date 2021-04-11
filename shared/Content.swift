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
        
        if(userData.isInBackground){
            return
        }
        
        let actualTime : Int64 = currentTimeMillis()
        if(from != "action" && (actualTime - lastLoadModelStart < MIN_TIME_DIFF || actualTime - lastLoadModelEnd < MIN_TIME_DIFF)){
            return
        }

        if(userData.homeUserToken.isEmpty){
            DispatchQueue.main.async() {
                userData.homeViewModel = newEmptyModel(state: "👉", msg: "Bitte anmelden")
            }
            return
        }
        
        lastLoadModelStart = actualTime
        #if DEBUG
            NSLog("loadModel... STARTING update=" + userData.doTokenRefresh.description)
        #endif
        
        loadModelInternal(userData: userData, from: from)
    }
}

fileprivate func loadModelInternal(userData : UserData, from : String) {
    
    func onError(msg : String, rc : Int){
        
        if(rc == 401){
            DispatchQueue.main.async() {
                userData.doTimer = false
            }
        }
        
        DispatchQueue.main.async() {
            userData.homeViewModel = userData.clearHomeViewModel
            userData.lastErrorMsg = "load_\(from):" + msg
        }
    }
    
    func onSuccess(response : String, newToken : String?){
        
        lastLoadModelEnd = currentTimeMillis()
        
        if let token = newToken{
            DispatchQueue.main.async() {
                userData.doTokenRefresh = false
                userData.homeUserToken = token
            }
            saveUserToken(newUserToken: token)
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
                    }
                    clearModel.places[i] = place
                }
                DispatchQueue.main.async() {
                    userData.clearHomeViewModel = clearModel
                }
            
            DispatchQueue.main.async() {
                userData.modelTimestamp = newModel.timestamp
                newModel.timestamp = "OK"
                userData.homeViewModel = newModel
            }

        // } catch DecodingError.keyNotFound(let key, let context) {
        //    Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
        //} catch DecodingError.valueNotFound(let type, let context) {
        //    Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
        //} catch DecodingError.typeMismatch(let type, let context) {
        //    Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
        //} catch DecodingError.dataCorrupted(let context) {
        //    Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
        //} catch let error as NSError {
        //    NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
        } catch let jsonError as NSError {
            onError(msg : "error parsing json document. \(jsonError.localizedDescription)", rc : -2)
            // NSLog("response: " + response)
        }
    }
    
    let authDict = ["appUserName": userData.homeUserName, "appUserToken": userData.homeUserToken, "appDevice" : userData.device, "refreshToken" : userData.doTokenRefresh.description]
    httpCall(urlString: userData.homeUrl + "getAppModel?viewTarget=watch", pin: nil, timeoutSeconds: 6.0, method: HttpMethod.GET, postParams: nil, authHeaderFields: authDict, errorHandler: onError, successHandler: onSuccess)
}

