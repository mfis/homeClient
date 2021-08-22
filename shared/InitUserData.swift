//
//  InitUserData.swift
//  homeClient
//
//  Created by Matthias Fischer on 20.07.21.
//

import Foundation

func initHomeViewModel(deviceName : String?) -> UserData {
    
    NSLog("### initHomeViewModel")
    
    migrateUserDefaults()
    
    let userData = UserData()
    
    saveTimerState(newState: false)
    
    if let infoPath = Bundle.main.path(forResource: "Info.plist", ofType: nil),
       let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
       let infoDate : Date = infoAttr[FileAttributeKey(rawValue: "NSFileCreationDate")] as? Date
     {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        userData.build = formatter.string(from: infoDate)
    }
    
    if let deviceName = deviceName{
        userData.device = deviceName.replacingOccurrences( of:"[^0-9A-Za-z]", with: "", options: .regularExpression)
    }
    return userData
}

func lookupPushToken(userData : UserData) -> String {
    if(loadPushToken().isEmpty){
        return "n/a"
    }
    return loadPushToken()
}
