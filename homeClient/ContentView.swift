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
    }
    
}

struct Content : View {
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont.systemFont(ofSize: 20.0, weight: .light)]
    }
    
    @StateObject var model = WebViewModel()
    
    var body: some View {
        
        LoadingView(isShowing: self.$model.isLoading) {
            WebViewComponent(viewModel: self.model)
        }
        .navigationBarTitle(Text("Zuhause"), displayMode: .inline)
        .navigationBarItems(
            leading:  NavIconLeft(),
            trailing: NavIconRight()
        ).edgesIgnoringSafeArea(.bottom)
    }
}

struct NavIconLeft : View {
    
    @EnvironmentObject private var userData : UserData
    @State var showRefreshPendingPopover = false
    
    var body: some View {
        HStack(){
            NavigationLink(destination: PushMessageHistoryView().environmentObject(userData).preferredColorScheme(.dark)) {
                Image(systemName: "envelope.badge")
            }.buttonStyle(PlainButtonStyle())
            if(userData.webViewRefreshPending){
                Button(action: { self.showRefreshPendingPopover.toggle() }) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange).padding(.leading, 25)
                }.popover(isPresented: $showRefreshPendingPopover, arrowEdge: .top) {
                    Text("Das Laden der aktuellen Daten ist fehlgeschlagen.")
                        .font(.headline)
                        .padding()
                }
            }
        }
    }
}

struct NavIconRight : View {
    
    @EnvironmentObject private var userData : UserData
    
    var body: some View {
        HStack{
            Button(action: {
                HomeWebView.shared.loadWebView()
            }) {
                Image(systemName: "backward.frame")
                    .renderingMode(.template)
                    .foregroundColor(Color.init(hexOrName: ".white", darker: true))
            }.padding()
            Spacer()
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
