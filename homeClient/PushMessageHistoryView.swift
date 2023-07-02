//
//  PushHistoryView.swift
//  homeClient
//
//  Created by Matthias Fischer on 19.03.23.
//

import SwiftUI
import CoreLocation

struct PushMessageHistoryView: View {
    
    @EnvironmentObject private var userData : UserData
    
    var body: some View {
        NavigationView {
            Form {
                ListView()
            }.navigationBarTitle(Text("Benachrichtigungen"))
        } .onDisappear(){
            self.userData.resetPushHistoryListModel()
        } .onAppear(){
            self.userData.resetPushHistoryListModel()
            readPushMessageHistory(userData: userData)
        }.navigationViewStyle(StackNavigationViewStyle())
            .persistentSystemOverlays(.hidden)
    }
}

struct ListView: View {
    
    @EnvironmentObject private var userData : UserData
    
    var body: some View {
        List(userData.pushHistoryListModel.list, id: \.id) { model in
            Section {
                VStack(alignment: .leading) {
                    Text("\(model.title)").multilineTextAlignment(.leading).font(.title2).padding(.bottom, 1)
                    Text("\(model.timestamp)").multilineTextAlignment(.leading).font(.headline).padding(.bottom, 1).foregroundColor(.gray)
                    Text("\(model.message)").multilineTextAlignment(.leading).font(.body).padding(.bottom, 1)
                }
            }
        }
    }
}

#if DEBUG
struct PushMessageHistoryView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            PushMessageHistoryView().environmentObject({ () -> UserData in
                let userData = UserData()
                userData.pushHistoryListModel = PushMessageHistoryListModel(list: [PushMessageHistoryModel(id: "1", timestamp: "Heute", title: "Überschrift 1", message: "Text 1"), PushMessageHistoryModel(id: "2", timestamp: "Gestern", title: "Überschrift 2", message: "Text 2")])
                return userData
            }())
        }
    }
}
#endif
