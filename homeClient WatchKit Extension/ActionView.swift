//
//  ActionView.swift
//  homeClient WatchKit Extension
//
//  Created by Matthias Fischer on 03.10.20.
//

import SwiftUI

struct ActionView: View {
    
    @State var place : HomeViewPlaceModel
    @EnvironmentObject private var userData : UserData
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        Form {
            ForEach(place.actions, id: \.self) { section in
                Section(){
                    List(section) { action in
                        ActionListEntry(action: action)
                    }
                }
            }
        }.navigationBarTitle("Aktion")
    }
}

struct ActionListEntry : View {
    
    var action : HomeViewActionModel
    
    var body: some View {
        if(action.link == "#"){
            Text(action.name).foregroundColor(.black)
        }else{
            if(action.link.contains("needsPin")){
                SecureActionButton(action: action)
            }else{
                DefaultActionButton(action: action)
            }
        }
    }
}

struct DefaultActionButton : View {
    
    var action : HomeViewActionModel
    @EnvironmentObject private var userData : UserData
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        Button(action.name) {
            doAction(action.link, pin: nil, userData: self.userData, presentation: presentation)
        }
    }
}

struct SecureActionButton : View {
    
    var action : HomeViewActionModel
    @EnvironmentObject private var userData : UserData
    @Environment(\.presentationMode) var presentation
    @State var pin = ""
    @State private var showModal = false
    let pinLength = 6
    
    var body: some View {
        Button(action.name) {
            self.showModal.toggle()
        }.sheet(isPresented: $showModal, onDismiss: {
            if(pin.count==pinLength){
                doAction(action.link, pin: pin, userData: self.userData, presentation: presentation)
            }
            pin = ""
        }) {
            PinView(pin: $pin, showModal: self.$showModal)
        }.alert(isPresented: $userData.showAlert) {
            Alert(title: Text("Fehler"), message: Text("Aktion konnte nicht ausgeführt werden"),
                  dismissButton: .default (Text("Na gut")) {
                    self.userData.showAlert = false // Test #1
                    DispatchQueue.main.async {
                        userData.showAlert = false // Test #2
                    }
                  }
              )
        }
    }
}
