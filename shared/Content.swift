//
//  Content.swift
//  watchHomeApp Extension
//
//  Created by Matthias Fischer on 13.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

import Foundation

func loadModel(userData : UserData) {
     
    func onError(){
        DispatchQueue.main.async() {
            userData.homeViewModel = HomeViewModel(timestamp: "Fehler!", places: [])
        }
    }
    
    func onSuccess(response : String){
        let decoder = JSONDecoder ()
        if let newModel = try? decoder.decode(HomeViewModel.self, from: response.data(using: .utf8)!) {
            DispatchQueue.main.async() {
                userData.homeViewModel = newModel
            }
        }else{
            onError()
        }
    }
    
    if(userData.homeUrl.isEmpty){
        let signInMsg = HomeViewPlaceModel(id: "signInMsg" , name: "Bitte anmelden.", values: [])
        userData.homeViewModel = HomeViewModel(timestamp: "-", places: [signInMsg])
    }else{
        let authDict = ["appUserName": userData.homeUserName, "appUserToken": userData.homeUserToken, "appDevice" : userData.device]
        httpCall(urlString: userData.homeUrl + "getAppModel?viewTarget=watch", timeoutSeconds: 6.0, method: HttpMethod.GET, postParams: nil, authHeaderFields: authDict, errorHandler: onError, successHandler: onSuccess)
    }
}

