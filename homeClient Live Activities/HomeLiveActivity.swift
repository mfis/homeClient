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
            Color(hexOrName: "161616")
            HStack(spacing: 0) {
                PrimaryContentView(stateValue: model.primary)
                if(!model.secondary.val.isEmpty){
                    Spacer()
                    SecondaryContentView(stateValue: model.secondary)
                }
            }.activitySystemActionForegroundColor(.yellow)
                .activityBackgroundTint(.gray)
                .padding(.top, 8).padding(.bottom, 8).padding(.leading, 30).padding(.trailing, 30)
        }
    }
}

struct PrimaryContentView: View {
    let stateValue: HomeLiveActivityContentStateValue
    var body: some View {
        HStack() {
            SymbolOrLabelView(stateValue: stateValue, size: 50)
            Text(stateValue.val)
                .foregroundColor(Color.init(hexOrName: stateValue.color, darker: false))
                .padding(.leading, 8).font(.largeTitle)
        }
    }
}

struct SecondaryContentView: View {
    let stateValue: HomeLiveActivityContentStateValue
    var body: some View {
        VStack() {
            SymbolOrLabelView(stateValue: stateValue, size: 30)
            Text(stateValue.val)
                .foregroundColor(Color.init(hexOrName: stateValue.color, darker: false))
                .padding(.top, 2).font(.title2)
        }
    }
}

struct SymbolOrLabelView: View {
    let stateValue: HomeLiveActivityContentStateValue
    let size: CGFloat
    var body: some View {
        if(stateValue.symbolName.isEmpty){
            Text("\(stateValue.label)").foregroundColor(.white)
        }else{
            if(stateValue.symbolType=="sys"){
                Image(systemName: stateValue.symbolName)
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundColor(.white)
            }else{
                Image(stateValue.symbolName)
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundColor(.white)
            }
        }
    }
}

struct HomeLiveActivity_Previews: PreviewProvider {
    static var previews: some View {

        let a = HomeLiveActivityContentStateValue(symbolName: "a.circle", symbolType: "sys", label: "prim", val: "1234", valShort: "1k", color: ".green")
        let b = HomeLiveActivityContentStateValue(symbolName: "b.circle", symbolType: "sys", label: "sec", val: "567", valShort: "2k", color: ".red")
        let c = HomeLiveActivityContentStateValue(symbolName: "", symbolType: "", label: "", val: "", valShort: "", color: "")
        
        let contentSingle = HomeLiveActivityContentState(contentId: "xy", timestamp: "12:30", dismissSeconds: "600", primary: a, secondary: c)
        let contentBoth = HomeLiveActivityContentState(contentId: "yz", timestamp: "12:30", dismissSeconds: "600", primary: a, secondary: b)
        
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
