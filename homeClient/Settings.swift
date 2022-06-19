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

func writePresenceState(presenceState: String) {
    
    func onError(msg : String, rc : Int){
        NSLog("Error writing presence state: " + rc.description + " - " + msg)
        // TODO: save error flag, so we can write again while next app activation
    }
    
    func onSuccess(response : String, newToken : String?){
        // noop
    }
    
    if(loadUserToken().isEmpty){
        return
    }
    
    let postParams = ["value": presenceState]
    
    httpCall(urlString: loadUrl() + "setPresence", pin: nil, timeoutSeconds: 10.0, method: HttpMethod.POST, postParams: postParams, authHeaderFields: getAuth(), errorHandler: onError, successHandler: onSuccess)
}

fileprivate func parseResponse(userData : UserData, response: String) {
    
    do{
        let model = try JSONDecoder().decode(PushSettingsModel.self, from: response.data(using: .utf8)!)
        DispatchQueue.main.async() {
            userData.pushSettingsModel = model
            userData.pushSettingsSaveInProgress = false
        }
        if let lat = model.attributes.first(where: {$0.id == "LAT"})?.value, let d = Double(lat){
            saveGeofencingLat(newVal: d)
        }
        if let lon = model.attributes.first(where: {$0.id == "LON"})?.value, let d = Double(lon){
            saveGeofencingLon(newVal: d)
        }
        if let radius = model.attributes.first(where: {$0.id == "RADIUS"})?.value, let d = Double(radius){
            saveGeofencingRadius(newVal: d)
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
