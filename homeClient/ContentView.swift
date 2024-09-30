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
    
    @EnvironmentObject private var userData : UserData
    
    @StateObject var liveActivityViewModel = LiveActivityViewModel()
    var body: some View {
        
        ZStack{
            WebViewComponent()
            if userData.showLoadingIndicator {
                LoadingView().transition(.opacity).zIndex(1).allowsHitTesting(false)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: userData.showLoadingIndicator)
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
    @State var showPushMessagesPopover = false
    @StateObject var liveActivityViewModel = LiveActivityViewModel.shared
    
    var body: some View {
        HStack(){

            Button(action: { self.showPushMessagesPopover.toggle() }) {
                Image(systemName: "envelope")
                    .foregroundColor(Color.init(hexOrName: ".white", darker: true))
            }.popover(isPresented: $showPushMessagesPopover, arrowEdge: .top) {
                PushMessageHistoryView().environmentObject(userData);
            }
            
            Button(action: { self.showLiveActivityPopover.toggle() }) {
                Image(systemName: "clock")
                    .foregroundColor(Color.init(hexOrName: liveActivityViewModel.isActive ? ".green" : ".white", darker: true)).padding(.leading, 8)
            }.popover(isPresented: $showLiveActivityPopover, arrowEdge: .top) {
                LiveActivitySettingsContentView(liveActivityViewModel: liveActivityViewModel)
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
                DispatchQueue.main.async {
                    userData.showLoadingIndicator = true
                    HomeWebView.shared.loadWebView()
                }
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
