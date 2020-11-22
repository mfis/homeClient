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
    validateClientInstallation(urlString, userData : userData, doLogin: true)
    
    DispatchQueue.main.async() {
        userData.settingsStateName = "circle"
    }
}

func validateClientInstallation(_ urlString : String, userData : UserData, doLogin : Bool) {
    
    func onError(msg : String, rc : Int){
        showLoginResult(state: false, userData : userData)
        DispatchQueue.main.async() {
            showLoginResult(state: false, userData : userData)
            userData.settingsLoginMessage = "Keine Home-Client Installation unter URL vorhanden."
        }
    }
    
    func onSuccess(response : String, newToken : String?){
        if(response == "de_fimatas_homeclient"){
            if(doLogin){
                auth(urlString, userData : userData)
            }else{
                DispatchQueue.main.async() {
                    showLoginResult(state: true, userData : userData)
                    userData.settingsLoginMessage = "Verbindung erfolgreich."
                    userData.homeUrl = urlString
                    userData.settingsUrl = urlString
                    userData.lastCalledUrl = ""
                    saveUrl(newUrl: urlString)
                }
            }
        }
    }
    
    httpCall(urlString: urlString + "whoami", timeoutSeconds: 3.0, method: HttpMethod.GET, postParams: nil, authHeaderFields: nil, errorHandler: onError, successHandler: onSuccess)
}

func auth(_ urlString : String, userData : UserData){
    
    func onError(msg : String, rc : Int){
        showLoginResult(state: false, userData : userData)
        DispatchQueue.main.async() {
            userData.settingsLoginMessage = "Verbindungsfehler!"
            userData.settingsUserPassword = ""
        }
    }
    
    func onSuccess(response : String, newToken : String?){
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
                    
                    #if os(watchOS)
                        _ = userData.initHomeViewModel()
                    #endif
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

func logout(userData : UserData) {
    userData.homeUrl = "";
    userData.settingsUrl = ""
    userData.homeUserName = ""
    userData.settingsUserName = ""
    userData.homeUserToken = ""
    saveUrl(newUrl: "")
    saveUserName(newUserName: "")
    saveUserToken(newUserToken: "")
}
