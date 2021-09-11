//
//  CircularView.swift
//  homeClient WatchKit Extension
//
//  Created by Matthias Fischer on 20.09.20.
//

import SwiftUI
import ClockKit

struct CircularView: View {
    
    var complicationData: ComplicationData
    
    var body: some View {
        ZStack{
            if let data = complicationData.valueModel {
                Circle().fill(Color.init(hexOrName: data.accent, darker: true))
            }else{
                Circle().fill(Color.init(hexOrName: ".green", darker: true))
            }
            ZStack{
                if let data = complicationData.valueModel {
                        ZStack {
                            if(Bool.init(isFallingTendency: data.tendency)){
                                Circle()
                                    .fill(Color.init(hexOrName: ".blue", darker: true))
                                    .brightness(Bool.init(isSlightlyTendency: data.tendency) ? -0.2 : -0.5)
                                    .frame(width: 6.0, height: 6.0)
                                    .offset(x: -14, y: -5)
                            }
                            Image("zuhause").resizable()
                                .frame(width: 22.0, height: 22.0)
                                .offset(y: -8)
                                .foregroundColor(.black)
                            if(Bool.init(isRisingTendency: data.tendency)){
                                Circle()
                                    .fill(Color.init(hexOrName: ".red", darker: true))
                                    .brightness(Bool.init(isSlightlyTendency: data.tendency) ? -0.2 : -0.5)
                                    .frame(width: 6.0, height: 6.0)
                                    .offset(x: 14, y: -5)
                            }
                            Text(data.value.replacingOccurrences(of: "C", with: ""))
                                .font(.footnote)
                                .foregroundColor(.black)
                                .offset(y: 7)
                        }
                }else{
                    Image("zuhause").resizable().resizable()
                        .frame(width: 33.0, height: 33.0)
                }
            }
        }
    }
}

struct ProgressSample_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let value = HomeViewValueModel(id:"test", key: "Test", value: "-22,5°C", accent: ".blue", tendency: "SLIGHT_RISE", valueDirectives: [])
        let data = ComplicationData(vm: value);
        let empty = ComplicationData(vm: nil);
        
        Group{
        CLKComplicationTemplateGraphicCircularView(CircularView(complicationData: data))
            .previewContext()
        CLKComplicationTemplateGraphicCircularView(CircularView(complicationData: empty))
            .previewContext()
        }
    }
}
