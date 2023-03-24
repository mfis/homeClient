//
//  PushMessageHistory.swift
//  homeClient
//
//  Created by Matthias Fischer on 19.03.23.
//

import Foundation

func readPushMessageHistory(userData : UserData) {
    
    func onError(msg : String, rc : Int){
        DispatchQueue.main.async() {
            userData.resetPushSettingsModel()
        }
    }
    
    func onSuccess(response : String, newToken : String?){
        do{
            let model = try JSONDecoder().decode(PushMessageHistoryListModel.self, from: response.data(using: .utf8)!)
            DispatchQueue.main.async() {
                userData.pushHistoryListModel = model
            }
        } catch let jsonError as NSError {
            DispatchQueue.main.async() {
                userData.resetPushHistoryListModel()
            }
            #if DEBUG
                NSLog("error parsing json document. \(jsonError.localizedDescription)")
                NSLog("json response: " + response)
            #endif
        }
    }
    
    if(loadUserToken().isEmpty){
        userData.pushHistoryListModel = newEmptyPushMessageHistoryModel()
        return
    }
    
    httpCall(urlString: loadUrl() + "getPushMessageModel", pin: nil, timeoutSeconds: 5.0, method: HttpMethod.GET, postParams: nil, authHeaderFields: getAuth(), errorHandler: onError, successHandler: onSuccess)
}
