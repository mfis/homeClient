//
//  Settings.swift
//  iOSHomeApp
//
//  Created by Matthias Fischer on 10.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

import Foundation

func signIn(userData : UserData){
    
    var urlString = userData.settingsUrl
    urlString = cleanupUrl(forUrl: urlString)
    validateLogin(urlString, userData : userData)
    
    DispatchQueue.main.async() {
        userData.settingsStateName = "circle"
    }
}

func validateLogin(_ urlString : String, userData : UserData) {
    
    func onError(){
        showLoginResult(state: false, userData : userData)
        DispatchQueue.main.async() {
            userData.settingsLoginMessage = "Keine Home-Client Installation unter URL vorhanden."
        }
    }
    
    func onSuccess(response : String){
        if(response == "de.fimatas.home.client"){
            auth(urlString, userData : userData)
        }
    }
    
    httpCall(urlString: urlString + "whoami", timeoutSeconds: 3.0, method: HttpMethod.GET, postParams: nil, authHeaderFields: nil, errorHandler: onError, successHandler: onSuccess)
}

func auth(_ urlString : String, userData : UserData){
    
    func onError(){
        showLoginResult(state: false, userData : userData)
        DispatchQueue.main.async() {
            userData.settingsLoginMessage = "Verbindungsfehler!"
            userData.settingsUserPassword = ""
        }
    }
    
    func onSuccess(response : String){
        do{
            let model = try JSONDecoder().decode(TokenCreationResponseModel.self, from: response.data(using: .utf8)!)
            
            if(model.success){
                DispatchQueue.main.async() {
                    userData.homeUrl = urlString
                    userData.settingsUrl = urlString
                    userData.lastCalledUrl = ""
                    saveUrl(newUrl: urlString)
                    
                    userData.homeUserName = userData.settingsUserName
                    saveUserName(newUserName: userData.homeUserName)
                    
                    userData.homeUserToken = model.token
                    saveUserToken(newUserToken: model.token)
                    
                    showLoginResult(state: true, userData : userData)
                    userData.settingsLoginMessage = "Die Anmeldung war erfolgreich."
                    
                    userData.settingsUserPassword = ""
                }
            }else{
                DispatchQueue.main.async() {
                    showLoginResult(state: false, userData : userData)
                    userData.settingsLoginMessage = "Die Anmeldung war nicht erfolgreich."
                }
            }
            return
            
        }catch _{}
        
        showLoginResult(state: false, userData : userData)
        DispatchQueue.main.async() {
            userData.settingsLoginMessage = "Bei der Anmeldung ist ein Fehler aufgetreten."
            userData.settingsUserPassword = ""
        }
    }
    
    let paramDict = ["user": userData.settingsUserName, "pass": userData.settingsUserPassword, "device" : userData.device]
    
    httpCall(urlString: urlString + "createAuthToken", timeoutSeconds: 5.0, method: HttpMethod.POST, postParams: paramDict, authHeaderFields: nil, errorHandler: onError, successHandler: onSuccess)
}

func showLoginResult(state : Bool, userData : UserData){
    DispatchQueue.main.async() {
        if(state==true){
            userData.settingsStateName = "checkmark.circle.fill"
        }else{
            userData.settingsStateName = "bolt.horizontal.circle.fill"
        }
    }
}
