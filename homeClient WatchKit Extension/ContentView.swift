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
    @State var isActive = false
    
    var body: some View {
        Form {
            HStack{
                HStack {
                    Text(userData.homeViewModel.timestamp).frame(maxWidth: .infinity).frame(height: 1).font(.footnote)
                }.onTapGesture {
                    clearModel(&self.userData.homeViewModel)
                    loadModel(userData: self.userData)
                }
                NavigationLink(destination: SettingsViewWatch().environmentObject(userData)) {
                    Image(systemName: "slider.horizontal.3").frame(maxWidth: .infinity).imageScale(.small)
                }.padding(0)
            }
            List(userData.homeViewModel.places) { place in
                VStack{
                    Text(place.name).foregroundColor(.white).font(Font.headline)
                    ForEach(place.values) { entry in
                        HStack(spacing: 2){
                            Text(entry.key).foregroundColor(Color.init(hexString: entry.accent)).font(.footnote)
                            Spacer()
                            Text(entry.value + String.init(tendency:entry.tendency)).foregroundColor(Color.init(hexString: entry.accent))
                        }
                    }
                }
            }
        }.navigationBarTitle("Zuhause")
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
