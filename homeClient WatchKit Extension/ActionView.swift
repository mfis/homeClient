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
            Button("Show Modal") {
                self.showModal.toggle()
            }.sheet(isPresented: $showModal, onDismiss: {print("MODAL DISMISSED: " + pin)}) {
                PinView(length : pinLength, pin: $pin, showModal: self.$showModal)
            }
            List(place.actions) { action in
                HStack {
                    Spacer()
                    if(action.link == "#"){
                        Text(action.name).foregroundColor(.gray)
                    }else{
                        Text(action.name)
                    }
                    Spacer()
                }.contentShape(Rectangle()).onTapGesture {
                    if(action.link != "#"){
                        doAction(action.link, userData: self.userData, presentation: presentation)
                    }
                }
            }
        }.navigationBarTitle("Aktion").onDisappear(perform: {
            pin = ""
        })
    }
    
}


struct ActionView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
