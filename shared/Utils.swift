//
//  Utils.swift
//  homeClient WatchKit Extension
//
//  Created by Matthias Fischer on 20.09.20.
//

import SwiftUI
import Foundation

let CONST_PLACE_DIRECTIVE_WATCH_LABEL = "WATCH_LABEL"
let CONST_PLACE_DIRECTIVE_WATCH_SYMBOL = "WATCH_SYMBOL"
let CONST_PLACE_DIRECTIVE_WIDGET_LABEL_SMALL = "WIDGET_LABEL_SMALL"
let CONST_PLACE_DIRECTIVE_WIDGET_LABEL_MEDIUM = "WIDGET_LABEL_MEDIUM"
let CONST_PLACE_DIRECTIVE_WIDGET_LABEL_LARGE = "WIDGET_LABEL_LARGE"
let CONST_PLACE_DIRECTIVE_WIDGET_SYMBOL = "WIDGET_SYMBOL"
let CONST_PLACE_DIRECTIVE_WIDGET_LOCKSCREEN_CIRCULAR = "WIDGET_LOCKSCREEN_CIRCULAR"
let CONST_VALUE_DIRECTIVE_SYMBOL_SKIP = "SYMBOL_SKIP"
let CONST_VALUE_DIRECTIVE_WIDGET_SKIP = "WIDGET_SKIP"
let CONST_VALUE_DIRECTIVE_LOCKSCREEN_SKIP = "LOCKSCREEN_SKIP"

extension String {
    init(tendency: String){
        switch(tendency){
        case "RISE":
            self.init(" ↑")
        case "RISE_SLIGHT":
            self.init(" ↗")
        case "EQUAL":
            self.init(" →")
        case "FALL_SLIGHT":
            self.init(" ↘")
        case "FALL":
            self.init(" ↓")
        default:
            self.init("")
        }
    }
}

extension String {
    init(shortTendency: String){
        switch(shortTendency){
        case "RISE":
            self.init("↑")
        case "RISE_SLIGHT":
            self.init("↑")
        case "EQUAL":
            self.init("≈")
        case "FALL_SLIGHT":
            self.init("↓")
        case "FALL":
            self.init("↓")
        default:
            self.init("")
        }
    }
}

extension Bool {
    init(isRisingTendency: String){
        self.init(isRisingTendency.contains("RISE"))
    }
    init(isFallingTendency: String){
        self.init(isFallingTendency.contains("FALL"))
    }
    init(isSlightlyTendency: String){
        self.init(isSlightlyTendency.contains("SLIGHT"))
    }
}

fileprivate var colorNameDictDefault = [
    "green" : "66ff66",
    "olive" : "285028",
    "orange" : "ffb84d",
    "red" : "ff6666",
    "blue" : "66b3ff",
    "black" : "111111",
    "white" : "ffffff",
    "purple" : "f4beee",
    "grey" : "969696",
]

fileprivate var colorHexDictDark = [
    "66ff66" : "5cb85c", // green
    "111111" : "000000", // black
    "ffb84d" : "c16b00", // orange
]

extension Color {
    
    init(hexOrName: String, defaultHexOrName: String = "", darker: Bool = false) {
        
        var input: String
        if(hexOrName.isEmpty){
            input = defaultHexOrName
        }else{
            input = hexOrName
        }
        
        var hex: String
        if(input.starts(with: ".")){
            if let x = colorNameDictDefault[input.replacingOccurrences(of: ".", with: "")] {
                hex = x
            } else {
                hex = "969696" // grey
            }
        }else{
            hex = input.replacingOccurrences(of: "#", with: "")
        }
        
        if(darker){
            if let darker = colorHexDictDark[hex] {
                hex = darker
            }
        }
        
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: 1
        )
    }
}

func formatDistance(_ d: Double?) -> String {
    if let d = d {
        if d.isLessThanOrEqualTo(1000.0){
            return "\(String(format:"%.0f", d)) m"
        }else{
            return "\(String(format:"%.0f", (d / 1000))) km"
        }
    }else{
        return "Unbekannt"
    }
}

func formattedTS() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd_HHmmss"
    return formatter.string(from: Date())
}
