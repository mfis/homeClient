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
    @State private var showModal = false
    @State var pin = ""
    let pinLength = 6
    
    var body: some View {
        Form {
            ForEach(place.actions, id: \.self) { section in
                Section(){
                    List(section) { action in
                        if(action.link == "#"){
                            Text(action.name).foregroundColor(.black)
                        }else{
                            if(action.link.contains("&securityPin=")){
                                Button(action.name) {
                                    self.showModal.toggle()
                                }.sheet(isPresented: $showModal, onDismiss: {
                                    if(pin.count==pinLength){
                                        doAction(action.link + pin, userData: self.userData, presentation: presentation)
                                    }
                                    pin = ""
                                }) {
                                    PinView(length : pinLength, pin: $pin, showModal: self.$showModal)
                                }
                            }else{
                                Button(action.name) {
                                    doAction(action.link, userData: self.userData, presentation: presentation)
                                }
                            }
                        }
                    }
                }
            }
        }.navigationBarTitle("Aktion")
    }
}


struct ActionView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
