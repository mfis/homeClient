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
                Circle().fill(Color.init(hexOrName: data.accent, darker: false))
            }else{
                Circle().fill(Color.init(hexOrName: ".grey", darker: false))
            }
            ZStack{
                if let data = complicationData.valueModel {
                        ZStack {
                            Image("zuhause").resizable()
                                .frame(width: 18.0, height: 18.0)
                                .offset(y: -11)
                                .foregroundColor(.black)
                            HStack(spacing: 1){
                                Text(data.valueShort)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.black)
                                    .offset(y: 4)
                                if(data.symbol.isEmpty){
                                    Text(String.init(shortTendency: data.tendency))
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(.black)
                                        .offset(y: 4)
                                } else {
                                    Image(systemName: data.symbol)
                                        .resizable()
                                        .scaledToFit()
                                        .offset(y: 4)
                                        .foregroundColor(.black)
                                        .frame(width: 14, height: 14)
                                        .padding(0)
                                }
                            }
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
        
        let value = HomeViewValueModel(id:"test", key: "Test", symbol: "arrow.forward.circle", value: "-22,5°C", valueShort: "-13°", accent: ".purple", tendency: "RISE", valueDirectives: [])
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
