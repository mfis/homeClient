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
                Circle().fill(Color.init(hexOrName: ".grey", darker: true))
            }
            ZStack{
                if let data = complicationData.valueModel {
                        ZStack {
                            Image("zuhause").resizable()
                                .frame(width: 22.0, height: 22.0)
                                .offset(y: -8)
                                .foregroundColor(.black)
                            Text(data.valueShort + String.init(shortTendency: data.tendency))
                                .font(.footnote)
                                .foregroundColor(.black)
                                .offset(y: 7)
                        }
                }else{
                    Image("zuhause").resizable().resizable()
                        .frame(width: 28.0, height: 28.0)
                }
            }
        }
    }
}

struct ProgressSample_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let value = HomeViewValueModel(id:"test", key: "Test", value: "-22,5°C", valueShort: "-23°", accent: ".purple", tendency: "RISE_SLIGHT", valueDirectives: [])
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
