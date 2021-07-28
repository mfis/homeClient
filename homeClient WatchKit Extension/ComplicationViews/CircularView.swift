//
//  CircularView.swift
//  homeClient WatchKit Extension
//
//  Created by Matthias Fischer on 20.09.20.
//

import SwiftUI
import ClockKit

struct CircularView: View {
    var body: some View {
        ZStack{
            Circle().fill(Color.init(hexString: "5cb85c", defaultHexString: ""))
            Image("zuhause").foregroundColor(.black)
        }
    }
}

struct ProgressSample_Previews: PreviewProvider {
    static var previews: some View {
        CLKComplicationTemplateGraphicCircularView(CircularView())
            .previewContext()
    }
}
