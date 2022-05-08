//
//  PushSettings.swift
//  homeClient
//
//  Created by Matthias Fischer on 08.05.22.
//

import Foundation


func readPushSettings(userData : UserData) {
    
    func onError(msg : String, rc : Int){
        DispatchQueue.main.async() {
            userData.resetPushSettingsModel()
        }
    }
    
    func onSuccess(response : String, newToken : String?){
        parseResponse(userData: userData, response: response)
    }
    
    if(loadUserToken().isEmpty){
        userData.pushSettingsModel = newEmptyPushSettings()
        return
    }
    
    httpCall(urlString: loadUrl() + "getPushSettings?token=" + loadPushToken(), pin: nil, timeoutSeconds: 5.0, method: HttpMethod.GET, postParams: nil, authHeaderFields: getAuth(), errorHandler: onError, successHandler: onSuccess)
}

func writePushSettings(id: String, value: Bool, userData : UserData) {
    
    func onError(msg : String, rc : Int){
        DispatchQueue.main.async() {
            userData.resetPushSettingsModel()
        }
    }
    
    func onSuccess(response : String, newToken : String?){
        parseResponse(userData: userData, response: response)
    }
    
    if(loadUserToken().isEmpty){
        userData.pushSettingsModel = newEmptyPushSettings()
        return
    }
    
    DispatchQueue.main.async() {
        userData.pushSettingsSaveInProgress = true
    }
    
    let postParams = ["token": loadPushToken(), "key" : id, "value": value.description]
    
    httpCall(urlString: loadUrl() + "setPushSetting", pin: nil, timeoutSeconds: 5.0, method: HttpMethod.POST, postParams: postParams, authHeaderFields: getAuth(), errorHandler: onError, successHandler: onSuccess)
}

fileprivate func parseResponse(userData : UserData, response: String) {
    
    do{
        let model = try JSONDecoder().decode(PushSettingsModel.self, from: response.data(using: .utf8)!)
        DispatchQueue.main.async() {
            userData.pushSettingsModel = model
            userData.pushSettingsSaveInProgress = false
        }
    } catch let jsonError as NSError {
        DispatchQueue.main.async() {
            userData.resetPushSettingsModel()
        }
        #if DEBUG
            NSLog("error parsing json document. \(jsonError.localizedDescription)")
            NSLog("json response: " + response)
        #endif
    }
}

fileprivate func getAuth() -> [String: String]? {
    return ["appUserName": loadUserName(), "appUserToken": loadUserToken(), "appDevice" : CONST_WEBVIEW_USERAGENT]
}
