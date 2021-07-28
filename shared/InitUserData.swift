//
//  InitUserData.swift
//  homeClient
//
//  Created by Matthias Fischer on 20.07.21.
//

import Foundation

func initHomeViewModel(deviceName : String?, isLoadWatchModel : Bool) -> UserData {
    
    migrateUserDefaults()
    
    let userData = UserData()
    
    if let infoPath = Bundle.main.path(forResource: "Info.plist", ofType: nil),
       let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
       let infoDate : Date = infoAttr[FileAttributeKey(rawValue: "NSFileCreationDate")] as? Date
     {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        userData.build = formatter.string(from: infoDate)
    }
    
    if let deviceName = deviceName{
        userData.device = deviceName.replacingOccurrences( of:"[^0-9A-Za-z]", with: "", options: .regularExpression)
    }
    if(isLoadWatchModel){
        loadWatchModel(userData: userData, from: "init")
    }
    return userData
}

func lookupPushToken(userData : UserData) -> String {
    if(userData.pushToken.isEmpty){
        userData.pushToken = loadPushToken()
        if(userData.pushToken.isEmpty){
            userData.pushToken = "n/a"
        }
    }
    return userData.pushToken
}
