//
//  Content.swift
//  watchHomeApp Extension
//
//  Created by Matthias Fischer on 13.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

import Foundation

func loadModel(userData : UserData, from : String) {
     
    func onError(msg : String){
        DispatchQueue.main.async() {
            userData.homeViewModel = userData.clearHomeViewModel
            userData.lastErrorMsg = "load_\(from):" + msg
        }
    }
    
    func onSuccess(response : String){
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
            onError(msg : "error parsing json document")
        }
    }
    
    if(userData.homeUrl.isEmpty){
        userData.homeViewModel = newEmptyModel(state: "👉", msg: "Bitte anmelden")
    }else{
        let authDict = ["appUserName": userData.homeUserName, "appUserToken": userData.homeUserToken, "appDevice" : userData.device]
        httpCall(urlString: userData.homeUrl + "getAppModel?viewTarget=watch", timeoutSeconds: 6.0, method: HttpMethod.GET, postParams: nil, authHeaderFields: authDict, errorHandler: onError, successHandler: onSuccess)
    }
}

