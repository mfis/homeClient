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
            HomeLiveActivityView(model: context.state)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("ER.leading")
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text("ER.trailing")
                }
                
                DynamicIslandExpandedRegion(.center) {
                    Text("ER.center")
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    Text("ER.bottom")
                }
                
            } compactLeading: {
                Image(systemName: context.state.primary.val) // FIXME
                    .foregroundColor(.white)
            } compactTrailing: {
                Text(context.state.primary.val) // FIXME
            } minimal: {
                Text(context.state.primary.val).lineLimit(1)
                    .minimumScaleFactor(0.5) // FIXME
            }
        }
    }
}

struct HomeLiveActivityView: View {
    let model: HomeLiveActivityContentState
    var body: some View {
        ZStack{
            Color.black
            HStack(spacing: 0) {
                if(!model.primary.symbolName.isEmpty){
                    VStack {
                        Image(systemName: model.primary.symbolName) // FIXME
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                        Text("\(model.primary.label)").foregroundColor(.white) // FIXME
                        Text(model.primary.val)
                            .foregroundColor(Color.init(hexOrName: model.primary.color, darker: false))
                            .padding(.top, 5).font(.title)
                    }
                }else{
                    Text(model.primary.val)
                }
            }.activitySystemActionForegroundColor(.yellow)
                .activityBackgroundTint(.black)
        }
    }
}


struct HomeLiveActivity_Previews: PreviewProvider {
    static var previews: some View {

        let a = HomeLiveActivityContentStateValue(symbolName: "a.circle", symbolType: "sys", label: "prim", val: "1234", valShort: "1k", color: ".green")
        let b = HomeLiveActivityContentStateValue(symbolName: "b.circle", symbolType: "sys", label: "sec", val: "567", valShort: "2k", color: ".red")
        let c = HomeLiveActivityContentStateValue(symbolName: "", symbolType: "", label: "", val: "", valShort: "", color: "")
        
        let contentSingle = HomeLiveActivityContentState(contentId: "xy", primary: a, secondary: c, timestamp: "12:30")
        let contentBoth = HomeLiveActivityContentState(contentId: "yz", primary: a, secondary: b, timestamp: "12:30")
        
        Group {
            HomeLiveActivityAttributes().previewContext(contentSingle, viewKind: .content)
            HomeLiveActivityAttributes().previewContext(contentSingle, viewKind: .dynamicIsland(.expanded))
            HomeLiveActivityAttributes().previewContext(contentSingle, viewKind: .dynamicIsland(.compact))
            HomeLiveActivityAttributes().previewContext(contentSingle, viewKind: .dynamicIsland(.minimal))
            
            HomeLiveActivityAttributes().previewContext(contentBoth, viewKind: .content)
            HomeLiveActivityAttributes().previewContext(contentBoth, viewKind: .dynamicIsland(.expanded))
            HomeLiveActivityAttributes().previewContext(contentBoth, viewKind: .dynamicIsland(.compact))
            HomeLiveActivityAttributes().previewContext(contentBoth, viewKind: .dynamicIsland(.minimal))
        }
    }
}
