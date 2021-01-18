//
//  SettingsView.swift
//  iOSHomeApp
//
//  Created by Matthias Fischer on 01.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject private var userData : UserData
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Adresse der Client Anwendung"), footer: Text("Installation siehe: https://github.com/mfis/Home")){
                    TextField("URL", text: $userData.settingsUrl).keyboardType(.URL).disableAutocorrection(true).autocapitalization(.none)
                }
                
                Section(footer: Text(self.userData.settingsLoginMessage)){
                    HStack{
                        Button(action: {
                            validateClientInstallation(urlString: userData.settingsUrl, userData : userData, doLogin: false)
                        }) {
                            Text("Übernehmen")
                        }
                        Spacer()
                        Image(systemName: self.userData.settingsStateName).imageScale(.medium)
                    }
                }
                
            }.navigationBarTitle(Text("Einstellungen"))
        }            .onDisappear(){
            self.userData.settingsStateName = "circle"
            self.userData.settingsLoginMessage = ""
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    
    @State static var userData = UserData()
    
    static var previews: some View {
        SettingsView().environmentObject(self.userData)
    }
}
#endif

