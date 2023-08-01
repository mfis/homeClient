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
            Content()
        }.navigationViewStyle(StackNavigationViewStyle())
            .persistentSystemOverlays(.hidden)
    }
    
}

struct Content : View {
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont.systemFont(ofSize: 20.0, weight: .light)]
    }
    
    @StateObject var model = WebViewModel()
    @StateObject var liveActivityViewModel = LiveActivityViewModel()
    
    var body: some View {
        
        LoadingView(isShowing: self.$model.isLoading) {
            WebViewComponent(viewModel: self.model)
        }
        .navigationBarTitle(Text("Zuhause"), displayMode: .inline)
        .navigationBarItems(
            leading:  NavIconLeft(liveActivityViewModel: liveActivityViewModel),
            trailing: NavIconRight()
        ).edgesIgnoringSafeArea(.bottom)
    }
}

struct NavIconLeft : View {
    
    @EnvironmentObject private var userData : UserData
    @State var showLiveActivityPopover = false
    @StateObject var liveActivityViewModel = LiveActivityViewModel.shared
    
    var body: some View {
        HStack(){
            
            NavigationLink(destination: PushMessageHistoryView().environmentObject(userData).preferredColorScheme(.dark)) {
                Image(systemName: "envelope")
            }.buttonStyle(PlainButtonStyle())
            
            if(userData.settingsUserName=="test" || userData.settingsUserName=="Matthias"){
                Button(action: { self.showLiveActivityPopover.toggle() }) {
                    Image(systemName: "clock")
                        .foregroundColor(Color.init(hexOrName: liveActivityViewModel.isActive ? ".green" : ".white", darker: true)).padding(.leading, 20)
                }.popover(isPresented: $showLiveActivityPopover, arrowEdge: .top) {
                    LiveActivitySettingsContentView(liveActivityViewModel: liveActivityViewModel)
                }
            }
        }
    }
}

struct NavIconRight : View {
    
    @EnvironmentObject private var userData : UserData
    @State var showRefreshPendingPopover = false
    
    var body: some View {
        HStack{
            Button(action: {
                HomeWebView.shared.loadWebView()
            }) {
                Image(systemName: "backward.end")
                    .renderingMode(.template)
                    .foregroundColor(Color.init(hexOrName: ".white", darker: true))
            }.padding()
            
            NavigationLink(destination: SettingsView().environmentObject(userData).preferredColorScheme(.dark)) {
                Image(systemName: "gearshape")
            }.buttonStyle(PlainButtonStyle())
        }
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
