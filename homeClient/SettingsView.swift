//
//  SettingsView.swift
//  iOSHomeApp
//
//  Created by Matthias Fischer on 01.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

import SwiftUI
import CoreLocation

struct SettingsView: View {
    
    @EnvironmentObject private var userData : UserData
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Adresse der Anwendung"), footer: Text("Installation siehe: https://github.com/mfis/Home")){
                    TextField("URL", text: $userData.settingsUrl).keyboardType(.URL).disableAutocorrection(true).autocapitalization(.none)
                }
                
                if(!loadUrl().isEmpty && !loadUserToken().isEmpty && userData.webViewPath == "/"){
                    LogoutView()
                    LocationView()
                    PushView()
                }else{
                    LoginView()
                }
                
                Section(header: Text("Build: \(userData.build)").foregroundColor(.gray)){}
            }.navigationBarTitle(Text("Einstellungen"))
        } .onDisappear(){
            self.userData.settingsStateName = ""
            self.userData.settingsLoginMessage = ""
        } .onAppear(){
            userData.pushSettingsSaveInProgress = false
            userData.resetPushSettingsModel()
            readPushSettings(userData: userData)
        }
    }
}

struct LoginView: View {
    
    @EnvironmentObject private var userData : UserData
    
    var body: some View {
        Section(footer: Text(self.userData.settingsLoginMessage)){
            HStack{
                Button(action: {
                    validateClientInstallation(urlString: userData.settingsUrl, userData : userData, doLogin: false)
                }) {
                    Text("Übernehmen")
                }
                Spacer()
                if(!self.userData.settingsStateName.isEmpty){
                    Image(systemName: self.userData.settingsStateName).imageScale(.medium)
                }
            }
        }
    }
}

struct LogoutView: View {
    
    @EnvironmentObject private var userData : UserData
    
    var body: some View {
        Section(header: Text("Angemeldet als " + loadUserName())){
            Button(action: {
                userData.prepareWebViewLogout()
                userData.resetPushSettingsModel()
            }) {
                Text("Abmelden")
            }
        }
    }
}

struct PushView: View {
    
    @EnvironmentObject private var userData : UserData
    
    var body: some View {
        if(!userData.pushSettingsModel.settings.isEmpty){
            Section(header: Text("Push-Mitteilungen")){
                ForEach($userData.pushSettingsModel.settings) { (model: Binding<PushSettingModel>) in
                    Toggle(isOn: model.value) {
                        Text("" + model.text.wrappedValue)
                    }.onChange(of: model.wrappedValue) { model in
                        writePushSettings(id: model.id, value: model.value, userData: userData)
                    }.disabled(userData.pushSettingsSaveInProgress)
                }
            }
        }
    }
}

struct LocationView: View {
    
    @State private var showGeofencingNotSupportedAlert = false
    @State private var showGeofencingNotTurnedOffAlert = false
    @EnvironmentObject private var userData : UserData
    let location = Location.shared
    
    var body: some View {
        Section(header: Text("Anwesenheit"), footer: Text("Entfernung: " + formatDistance(location.getDistanceFromHome()))){
            
            if(location.authorizationStatus == .restricted || location.authorizationStatus == .denied){
                Text("Lokalisierung wurde abgelehnt. Zur Nutzung bitte in den Systemeinstellungen der Zuhause-App erlauben.")
            } else if (location.authorizationStatus == .notDetermined){
                Button(action: {
                    location.requestPermission()
                }, label: {
                    Label("Lokalisierung erlauben", systemImage: "location")
                })
            }else{
                Toggle(isOn: $userData.settingsIsGeofencingOn) {
                    Text("Anwesenheitserkennung")
                }.onChange(of: userData.settingsIsGeofencingOn) { model in
                    saveIsGeofencingOn(newValue: userData.settingsIsGeofencingOn)
                    if(userData.settingsIsGeofencingOn){
                        NSLog("switch geofencing on")
                        showGeofencingNotSupportedAlert = !location.geofencingForHome()
                    }else{
                        NSLog("switch geofencing off")
                        showGeofencingNotTurnedOffAlert = !location.stopGeofencing()
                    }
                }.disabled(location.authorizationStatus != .authorizedAlways && location.authorizationStatus != .authorizedWhenInUse)
                .alert("Anwesenheitserkennung nicht möglich.", isPresented: $showGeofencingNotSupportedAlert) {
                    Button("Schade :-(") { userData.settingsIsGeofencingOn = false }
                }
                .alert("Leider ist ein Fehler aufgetreten.", isPresented: $showGeofencingNotTurnedOffAlert) {
                    Button("Schade :-(") { userData.settingsIsGeofencingOn = true }
                }
            }
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            SettingsView().environmentObject({ () -> UserData in
                saveUserToken(newUserToken: "x")
                saveUrl(newUrl: "x")
                let userData = UserData()
                userData.settingsUrl = "http://localhost:8080"
                userData.pushSettingsModel = PushSettingsModel(settings: [PushSettingModel(id: "k1", text: "Name1", value: true), PushSettingModel(id: "k2", text: "Name2", value: false)], attributes: [])
                return userData
            }())
        }
    }
}
#endif

