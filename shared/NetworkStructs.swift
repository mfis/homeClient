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
    var value : String
    var accent : String = "ffffff"
    var tendency : String
}

struct HomeViewPlaceModel: Hashable, Codable, Identifiable {
    var id : String
    var name : String
    var values : [HomeViewValueModel]
}

struct HomeViewModel: Codable {
    var timestamp : String
    var defaultAccent : String
    var places : [HomeViewPlaceModel]
}

func clearModel(_ model : inout HomeViewModel){
    model.timestamp = ". . ."
    for (i, var place) in model.places.enumerated() {
        for (j, var kv) in place.values.enumerated() {
            kv.value = ". . ."
            kv.tendency = ""
            kv.accent = model.defaultAccent
            place.values[j] = kv
        }
        model.places[i] = place
    }
}
