//
//  NetworkStructs.swift
//  iOSHomeApp
//
//  Created by Matthias Fischer on 04.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

import Foundation

struct TokenCreationResponseModel: Codable {
    var success : Bool
    var token : String
}

struct HomeViewValueModel:  Hashable, Codable, Identifiable  {
    var id : String
    var key : String
    var symbol: String = ""
    var value : String
    var valueShort : String = ""
    var accent : String = ""
    var tendency : String
    var valueDirectives : [String]
}

struct HomeViewActionModel:  Hashable, Codable, Identifiable  {
    var id : String
    var name : String
    var link : String
}

struct HomeViewPlaceModel: Hashable, Codable, Identifiable {
    var id : String
    var name : String
    var values : [HomeViewValueModel]
    var actions : [[HomeViewActionModel]]
    var placeDirectives : [String]
}

struct HomeViewModel: Codable {
    var timestamp : String
    var defaultAccent : String
    var places : [HomeViewPlaceModel]
}

func newEmptyModel(state: String, msg : String) -> HomeViewModel {
    return HomeViewModel(timestamp: state, defaultAccent: "ffffff", places: [HomeViewPlaceModel(id: "msg" , name: msg, values: [], actions: [], placeDirectives: [])])
}

struct PushSettingsModel: Codable {
    var settings: [PushSettingModel]
}

struct PushSettingModel: Hashable, Codable, Identifiable, Equatable {
    let id : String
    var text : String
    var value : Bool
}

func newEmptyPushSettings() -> PushSettingsModel {
    return PushSettingsModel(settings: [])
}
