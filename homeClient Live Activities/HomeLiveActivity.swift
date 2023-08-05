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
                DynamicIslandExpandedRegion(.leading) {}
                DynamicIslandExpandedRegion(.trailing) {}
                DynamicIslandExpandedRegion(.center) {
                    HStack{
                        PrimaryContentView(stateValue: context.state.primary)
                            .padding(.top, 20)
                        if(!context.state.secondary.val.isEmpty){
                            Spacer()
                            SecondaryContentView(stateValue: context.state.secondary)
                                .padding(.top, 40)
                        }
                    }.padding([.leading, .trailing], 30)

                }
                DynamicIslandExpandedRegion(.bottom) {}
            } compactLeading: {
                Text(context.state.primary.valShort).lineLimit(1)
                    .minimumScaleFactor(0.5)
            } compactTrailing: {
                Text(context.state.secondary.valShort).lineLimit(1)
                    .minimumScaleFactor(0.5)
            } minimal: {
                ZStack{
                    Color.black
                    Text(context.state.primary.valShort).lineLimit(1)
                        .minimumScaleFactor(0.9).padding(4)
                }
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
                if(!model.tertiary.val.isEmpty){
                    Spacer()
                    TertiaryContentView(stateValue: model.tertiary)
                }
            }.activitySystemActionForegroundColor(.yellow)
                .activityBackgroundTint(.gray)
                .padding([.top, .bottom], 8).padding([.leading, .trailing], 20)
        }
    }
}

struct PrimaryContentView: View {
    let stateValue: HomeLiveActivityContentStateValue
    var body: some View {
        HStack() {
            SymbolOrLabelView(stateValue: stateValue, size: 45)
            Text(stateValue.val)
                .foregroundColor(Color.init(hexOrName: stateValue.color, darker: false))
                .padding(.leading, 4).font(.largeTitle)
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

struct TertiaryContentView: View {
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

        let a = HomeLiveActivityContentStateValue(symbolName: "a.circle", symbolType: "sys", label: "prim", val: "123456", valShort: "1k", color: ".green")
        let b = HomeLiveActivityContentStateValue(symbolName: "b.circle", symbolType: "sys", label: "sec", val: "5678", valShort: "2k", color: ".red")
        let c = HomeLiveActivityContentStateValue(symbolName: "c.circle", symbolType: "sys", label: "ter", val: "ABCD", valShort: "3k", color: ".orange")
        let empty = HomeLiveActivityContentStateValue(symbolName: "", symbolType: "", label: "", val: "", valShort: "", color: "")
        
        let contentOne = HomeLiveActivityContentState(contentId: "xy", timestamp: "12:30", dismissSeconds: "600", primary: a, secondary: empty, tertiary: empty)
        let contentTwo = HomeLiveActivityContentState(contentId: "yz", timestamp: "12:30", dismissSeconds: "600", primary: a, secondary: b, tertiary: empty)
        let contentThree = HomeLiveActivityContentState(contentId: "yz", timestamp: "12:30", dismissSeconds: "600", primary: a, secondary: b, tertiary: c)
        
        Group {
            HomeLiveActivityAttributes().previewContext(contentOne, viewKind: .content)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
                .previewDisplayName("14 Pro 1x")

            HomeLiveActivityAttributes().previewContext(contentTwo, viewKind: .content)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
                .previewDisplayName("14 Pro 2x")

            HomeLiveActivityAttributes().previewContext(contentThree, viewKind: .content)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
                .previewDisplayName("14 Pro 3x")
            
            HomeLiveActivityAttributes().previewContext(contentOne, viewKind: .dynamicIsland(.expanded))
            HomeLiveActivityAttributes().previewContext(contentOne, viewKind: .dynamicIsland(.compact))
            HomeLiveActivityAttributes().previewContext(contentOne, viewKind: .dynamicIsland(.minimal))
            
            HomeLiveActivityAttributes().previewContext(contentTwo, viewKind: .dynamicIsland(.expanded))
            HomeLiveActivityAttributes().previewContext(contentTwo, viewKind: .dynamicIsland(.compact))
            HomeLiveActivityAttributes().previewContext(contentTwo, viewKind: .dynamicIsland(.minimal))
        }
    }
}
