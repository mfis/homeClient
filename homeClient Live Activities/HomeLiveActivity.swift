//
//  HomeLiveActivity.swift
//  homeClient
//
//  Created by Matthias Fischer on 09.07.23.
//

import WidgetKit
import SwiftUI

@main
struct HomeLiveActivity: Widget {
    
    var body: some WidgetConfiguration {
        
        ActivityConfiguration(for: HomeLiveActivityAttributes.self) { context in
            HomeLiveActivityView(model: HomeLiveActivityModel(
                valueLeading: context.state.valueLeading,
                valueTrailing: context.state.valueTrailing,
                labelLeading: context.attributes.labelLeading,
                labelTrailing: context.attributes.labelTrailing,
                colorLeading: context.state.colorLeading,
                colorTrailing: context.state.colorTrailing,
                symbolLeading: context.attributes.symbolLeading,
                symbolTrailing: context.attributes.symbolTrailing
            ))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("ExpandedRegion.leading")
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text("ExpandedRegion.trailing")
                }
                
                DynamicIslandExpandedRegion(.center) {
                    Text("ExpandedRegion.center")
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    Text("ExpandedRegion.bottom")
                }
                
            } compactLeading: {
                Text("compactLeading")
            } compactTrailing: {
                Text("compactTrailing")
            } minimal: {
                Text("minimal")
            }
        }
    }
}

struct HomeLiveActivityModel {
    var valueLeading: String
    var valueTrailing: String
    var labelLeading: String
    var labelTrailing: String
    var colorLeading: String
    var colorTrailing: String
    var symbolLeading: String
    var symbolTrailing: String
}

struct HomeLiveActivityView: View {
    let model: HomeLiveActivityModel
    var body: some View {
        ZStack{
            Color.black
            HStack(spacing: 0) {
                if(!model.labelLeading.isEmpty){
                    VStack {
                        Image(systemName: model.symbolLeading)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                        Text("\(model.labelLeading)").foregroundColor(.white)
                        Text(model.valueLeading)
                            .foregroundColor(Color.init(hexOrName: model.colorLeading, darker: false))
                            .padding(.top, 5).font(.title)
                    }
                }
                if(!model.labelTrailing.isEmpty){
                    // TODO
                }
            }.activitySystemActionForegroundColor(.yellow)
                .activityBackgroundTint(.black)
        }
    }
}


struct HomeLiveActivity_Previews: PreviewProvider {
    static var previews: some View {
        HomeLiveActivityView(model: HomeLiveActivityModel(valueLeading: "1000 W", valueTrailing: "", labelLeading: "Photovoltaik", labelTrailing: "", colorLeading: ".green", colorTrailing: "", symbolLeading: "window.ceiling", symbolTrailing: ""))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

