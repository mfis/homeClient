//
//  HomeLiveActivityttributes.swift
//  homeClient
//
//  Created by Matthias Fischer on 09.07.23.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct HomeLiveActivityAttributes: ActivityAttributes {
    
    public struct ContentState: Codable, Hashable {
        var valueLeading: String
        var valueTrailing: String
        var colorLeading: String
        var colorTrailing: String
    }

    var labelLeading: String
    var labelTrailing: String
    var symbolLeading: String
    var symbolTrailing: String
}
