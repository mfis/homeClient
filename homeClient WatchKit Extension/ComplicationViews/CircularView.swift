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
                    VStack {
                        Text(data.value.replacingOccurrences(of: "C", with: "") + String.init(tendency:data.tendency).trimmingCharacters(in: .whitespaces)).foregroundColor(.black).padding(.top, 2)
                        Image("zuhause").resizable()
                            .frame(width: 22.0, height: 22.0)
                            .padding(.top, -8).foregroundColor(.black)
                    }
                }else{
                    Image("zuhause").resizable()
                }
            }
        }
    }
}

struct ProgressSample_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let value = HomeViewValueModel(id:"test", key: "Test", value: "-21,5°C", accent: ".blue", tendency: "RISE", valueDirectives: [])
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
