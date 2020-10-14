//
//  Action.swift
//  homeClient WatchKit Extension
//
//  Created by Matthias Fischer on 03.10.20.
//

import SwiftUI

func doAction(_ urlString : String, userData : UserData, presentation : Binding<PresentationMode>) {
    
    func onError(){
        DispatchQueue.main.async() {
            userData.showAlert = true;
        }
    }
    
    func onSuccess(response : String){
        loadModel(userData: userData)
        DispatchQueue.main.async() {
            presentation.wrappedValue.dismiss()
        }
    }
    
    let authDict = ["appUserName": userData.homeUserName, "appUserToken": userData.homeUserToken, "appDevice" : userData.device]
    httpCall(urlString: userData.homeUrl + urlString, timeoutSeconds: 6.0, method: HttpMethod.GET, postParams: nil, authHeaderFields: authDict, errorHandler: onError, successHandler: onSuccess)
}
