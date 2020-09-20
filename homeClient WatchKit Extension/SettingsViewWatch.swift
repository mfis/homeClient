//
//  SettingsViewWatch.swift
//  watchHomeApp Extension
//
//  Created by Matthias Fischer on 09.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

import SwiftUI

struct SettingsViewWatch: View {
    
    @EnvironmentObject private var userData : UserData
    
    var body: some View {
        Form {
            TextField("URL", text: $userData.settingsUrl)
            TextField("Anmeldename", text: $userData.settingsUserName)
            SecureField("Passwort", text: $userData.settingsUserPassword)
            
            HStack{
                Button(action: {
                    signIn(userData : self.userData)
                }) {
                    Text("Anmelden")
                }
                Spacer()
                Image(systemName: self.userData.settingsStateName).imageScale(.medium)
            }
            
            
        }.navigationBarTitle(Text("Einstellungen"))
            .onDisappear(){
                self.userData.settingsStateName = "circle"
                self.userData.settingsLoginMessage = ""
        }
    }
    
}

#if DEBUG
struct SettingsViewWatch_Previews: PreviewProvider {
    @State static var userData = UserData()
    static var previews: some View {
        SettingsViewWatch().environmentObject(self.userData)
    }
}
#endif
