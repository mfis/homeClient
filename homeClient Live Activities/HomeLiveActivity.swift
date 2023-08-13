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
                        if(!context.state.tertiary.val.isEmpty){
                            Spacer()
                            SecondaryContentView(stateValue: context.state.tertiary)
                                .padding(.top, 40)
                        }
                    }.padding([.leading, .trailing], 10)

                }
                DynamicIslandExpandedRegion(.bottom) {}
            } compactLeading: {
                Text(context.state.primary.valShort).lineLimit(1)
                    .minimumScaleFactor(0.5).foregroundColor(Color.init(hexOrName: context.state.primary.color, darker: false))
            } compactTrailing: {
                if(context.state.secondary.val.isEmpty){
                    SymbolOrLabelView(stateValue: context.state.primary, size: 18)
                        .padding(0)
                }else{
                    Text(context.state.secondary.valShort).lineLimit(1)
                        .foregroundColor(Color.init(hexOrName: context.state.secondary.color, darker: false))
                        .minimumScaleFactor(0.5)
                }
            } minimal: {
                ZStack{
                    Color.black
                    Text(context.state.primary.valShort).lineLimit(1)
                        .foregroundColor(Color.init(hexOrName: context.state.primary.color, darker: false))
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
                if(model.primary.val.isEmpty && model.secondary.val.isEmpty && model.tertiary.val.isEmpty){
                    Image("zuhause")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .foregroundColor(Color.init(hexOrName: ".green", darker: false))
                }else{
                    PrimaryContentView(stateValue: model.primary)
                    if(!model.secondary.val.isEmpty){
                        Spacer()
                        SecondaryContentView(stateValue: model.secondary)
                    }
                    if(!model.tertiary.val.isEmpty){
                        Spacer()
                        SecondaryContentView(stateValue: model.tertiary)
                    }
                }
            }.activitySystemActionForegroundColor(.yellow)
                //.activityBackgroundTint(.gray)
                .padding([.top, .bottom], 8).padding([.leading, .trailing], model.tertiary.val.isEmpty ? 30 : 20)
        }
    }
}

struct PrimaryContentView: View {
    let stateValue: HomeLiveActivityContentStateValue
    var body: some View {
        HStack() {
            SymbolOrLabelView(stateValue: stateValue, size: 35)
            Text(stateValue.val)
                .foregroundColor(Color.init(hexOrName: stateValue.color, darker: false))
                .padding(.leading, 0).font(.largeTitle)
        }
    }
}

struct SecondaryContentView: View {
    let stateValue: HomeLiveActivityContentStateValue
    var body: some View {
        VStack() {
            SymbolOrLabelView(stateValue: stateValue, size: 30)
                .padding(.bottom, 0)
            Text(stateValue.val)
                .foregroundColor(Color.init(hexOrName: stateValue.color, darker: false))
                .padding(.top, 0).font(.title2)
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
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .foregroundColor(.white)
            }else{
                Image(stateValue.symbolName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .foregroundColor(.white)
            }
        }
    }
}

struct HomeLiveActivity_Previews: PreviewProvider {
    static var previews: some View {

        let a = HomeLiveActivityContentStateValue(symbolName: "energygrid", symbolType: "app", label: "prim", val: "123456", valShort: "1k", color: ".green")
        let b = HomeLiveActivityContentStateValue(symbolName: "solarpanel", symbolType: "app", label: "sec", val: "5678", valShort: "2k", color: ".red")
        let c = HomeLiveActivityContentStateValue(symbolName: "c.circle", symbolType: "sys", label: "ter", val: "ABCD", valShort: "3k", color: ".orange")
        let empty = HomeLiveActivityContentStateValue(symbolName: "", symbolType: "", label: "", val: "", valShort: "", color: "")

        let contentZero = HomeLiveActivityContentState(contentId: "xy", timestamp: "12:30", dismissSeconds: "600", primary: empty, secondary: empty, tertiary: empty)
        let contentOne = HomeLiveActivityContentState(contentId: "xy", timestamp: "12:30", dismissSeconds: "600", primary: a, secondary: empty, tertiary: empty)
        let contentTwo = HomeLiveActivityContentState(contentId: "yz", timestamp: "12:30", dismissSeconds: "600", primary: a, secondary: b, tertiary: empty)
        let contentThree = HomeLiveActivityContentState(contentId: "yz", timestamp: "12:30", dismissSeconds: "600", primary: a, secondary: b, tertiary: c)
        
        Group {
            HomeLiveActivityAttributes().previewContext(contentZero, viewKind: .content)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
                .previewDisplayName("14 Pro 0x")
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
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
                .previewDisplayName("Expanded 1x")
            HomeLiveActivityAttributes().previewContext(contentThree, viewKind: .dynamicIsland(.expanded))
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
                .previewDisplayName("Expanded 3x")
            
            HomeLiveActivityAttributes().previewContext(contentOne, viewKind: .dynamicIsland(.compact))
                .previewDisplayName("Compact 1x")
            HomeLiveActivityAttributes().previewContext(contentTwo, viewKind: .dynamicIsland(.compact))
                .previewDisplayName("Compact 2x")
            
            HomeLiveActivityAttributes().previewContext(contentOne, viewKind: .dynamicIsland(.minimal))
                .previewDisplayName("minimal")

        }
    }
}
