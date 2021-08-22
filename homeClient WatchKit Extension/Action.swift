//
//  Action.swift
//  homeClient WatchKit Extension
//
//  Created by Matthias Fischer on 03.10.20.
//

import SwiftUI

func doAction(_ urlString : String, pin : String?, userData : UserData, presentation : Binding<PresentationMode>) {
    
    func onError(msg : String, rc : Int){
        DispatchQueue.main.async() {
            userData.showAlert = true
            userData.lastErrorMsg = msg
        }
    }
    
    func onSuccess(response : String, newToken : String?){
        loadWatchModel(userData: userData, from : "action")
        DispatchQueue.main.async() {
            presentation.wrappedValue.dismiss()
        }
    }
    
    let authDict = ["appUserName": loadUserName(), "appUserToken": loadUserToken(), "appDevice" : userData.device]
    httpCall(urlString: loadUrl() + urlString, pin : pin, timeoutSeconds: 6.0, method: HttpMethod.GET, postParams: nil, authHeaderFields: authDict, errorHandler: onError, successHandler: onSuccess)
}
