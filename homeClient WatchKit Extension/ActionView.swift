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
        }.navigationBarTitle("Aktion")
    }
    
}

