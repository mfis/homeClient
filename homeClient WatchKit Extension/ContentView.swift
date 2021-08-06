//
//  ContentView.swift
//  watchHomeApp Extension
//
//  Created by Matthias Fischer on 04.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var userData : UserData
    let timer = Timer.publish(every: TIMER_INTERVAL_SECONDS, on: .main, in: .common).autoconnect() 
        
    var body: some View {
        Form {
            List(userData.watchModel.places) { place in
                if(place.actions.isEmpty){
                    VStack{
                        Text(place.name).foregroundColor(.white).font(Font.headline)
                        ForEach(place.values) { entry in
                            HStack(spacing: 2){
                                Text(entry.key).foregroundColor(Color.init(hexString: entry.accent, defaultHexString: "ffffff")).font(.footnote)
                                Spacer()
                                Text(entry.value + String.init(tendency:entry.tendency)).foregroundColor(Color.init(hexString: entry.accent, defaultHexString: "ffffff"))
                            }
                        }
                    }
                }else{
                    NavigationLink(destination: ActionView(place: place).environmentObject(userData)) {
                        VStack{
                            Text(place.name + " ⇨").foregroundColor(.white).font(Font.headline)
                            ForEach(place.values) { entry in
                                HStack(spacing: 2){
                                    Text(entry.key).foregroundColor(Color.init(hexString: entry.accent, defaultHexString: "ffffff")).font(.footnote)
                                    Spacer()
                                    Text(entry.value + String.init(tendency:entry.tendency)).foregroundColor(Color.init(hexString: entry.accent, defaultHexString: "ffffff"))
                                }
                            }
                        }
                    }
                }
            }
            NavigationLink(destination: SettingsViewWatch().environmentObject(userData)) {
                Image(systemName: "slider.horizontal.3").frame(maxWidth: .infinity)
            }.buttonStyle(PinButton())
        }.navigationBarTitle("Zuhause")
        .onReceive(timer) { _ in
            loadWatchModel(userData: userData, from : CONST_APP_TIMER)
         }
    }
    
}

#if DEBUG
enum MyDeviceNames: String, CaseIterable {
    case small = "Apple Watch Series 5 - 40mm"
    case large = "Apple Watch Series 5 - 44mm"
    
    static var all: [String] {
        return MyDeviceNames.allCases.map { $0.rawValue }
    }
}
struct SampleView_Previews_MyDevices: PreviewProvider {
    static var previews: some View {
        ForEach(MyDeviceNames.all, id: \.self) { devicesName in
            ContentView()
                .previewDevice(PreviewDevice(rawValue: devicesName))
                .previewDisplayName(devicesName)
        }
    }
}
#endif
