//
//  Utils.swift
//  homeClient WatchKit Extension
//
//  Created by Matthias Fischer on 20.09.20.
//

import SwiftUI
import Foundation

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

extension Color {
    init(hexString: String) {
        var int: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&int)
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
