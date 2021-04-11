//
//  ContentView.swift
//  iOSHomeApp
//
//  Created by Matthias Fischer on 01.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

import SwiftUI
import WebKit

struct ContentView: View {
    
    @EnvironmentObject private var userData : UserData
    
    @ViewBuilder
    var body: some View {
        NavigationView{
            if(userData.isInBackground==true){
                BackgroundView()
            }else{
                Content()
            }
        }
    }
    
}

struct BackgroundView : View {
    
    var body: some View {
        Image(systemName: "house.fill").imageScale(.medium)
    }
    
}

struct Content : View {
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont.systemFont(ofSize: 20.0, weight: .light)]
    }
    
    var body: some View {
        WebViewComponent()
            .navigationBarTitle(Text("Zuhause"), displayMode: .inline)
            .navigationBarItems(
                leading:  NavIconLeft(),
                trailing: NavIconRight()
            ).edgesIgnoringSafeArea(.bottom)
    }
}

struct NavIconLeft : View {
    
    @EnvironmentObject private var userData : UserData
    
    var body: some View {
        HStack{
            Image(systemName: "arrow.clockwise.circle").foregroundColor(Color.gray)
            Text(userData.webViewTitle).frame(width: 70, alignment: .leading).foregroundColor(Color.gray).font(.caption)
        }
    }
} 

struct NavIconRight : View {
    
    @EnvironmentObject private var userData : UserData
    
    var body: some View {
        NavigationLink(destination: SettingsView().environmentObject(userData)) {
            Image(systemName: "slider.horizontal.3")
        }.buttonStyle(PlainButtonStyle())
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    
    @State static var userData = UserData()
    
    static var previews: some View {
        ContentView().environmentObject(self.userData)
    }
}
#endif
