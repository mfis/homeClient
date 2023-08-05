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
    typealias ContentState = HomeLiveActivityContentState
}

public struct HomeLiveActivityContentState: Codable, Hashable {
    var contentId : String
    var timestamp : String
    var dismissSeconds : String
    var primary : HomeLiveActivityContentStateValue
    var secondary : HomeLiveActivityContentStateValue
    var tertiary : HomeLiveActivityContentStateValue
}

public struct HomeLiveActivityContentStateValue: Codable, Hashable {
    var symbolName: String
    var symbolType: String
    var label: String
    var val: String
    var valShort: String
    var color: String
}
