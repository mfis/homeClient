//
//  LiveActivitySettingsView.swift
//  homeClient
//
//  Created by Matthias Fischer on 22.07.23.
//

import Foundation
import SwiftUI

struct LiveActivitySettingsContentView: View {
    
    @StateObject var liveActivityViewModel = LiveActivityViewModel.shared
    @State private var selected = "Strom"
    let theme = ["Strom"]
    
    var body: some View {
        
        VStack(spacing: 30) {
            
            Text("Live-Aktivität").font(Font.title).padding(.top, 30).foregroundColor(Color.init(hexOrName: liveActivityViewModel.isActive ? ".green" : ".white", darker: true))
            
            Circle()
                .fill(Color.init(hexOrName: liveActivityViewModel.isActive ? ".green" : ".grey", darker: true))
                .frame(width: 30, height: 30, alignment: .center)
                .scaleEffect(liveActivityViewModel.isActive ? 1 : 0.5)
            
            Section {
                Picker("LiveActivityType", selection: $selected) {
                    ForEach(theme, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.wheel).disabled(liveActivityViewModel.isActive)
            }.background(Color(hexOrName: "161616")).cornerRadius(16).padding(10)
            
            Section {
                HStack {
                    Button{
                        liveActivityViewModel.start()
                    } label: {
                        Text("Start")
                            .padding(.horizontal, 40)
                            .padding(.vertical, 8)
                            .foregroundColor(liveActivityViewModel.isActive ? .black : .white)
                            .background(Color(hexOrName: ".green", darker: true))
                            .cornerRadius(28)
                    }.disabled(liveActivityViewModel.isActive)
                        .opacity(liveActivityViewModel.isActive ? 0.4 : 1.0)
                        .alert(isPresented: $liveActivityViewModel.isStartIssueFrequentPushedSetting) {
                            Alert(title: Text("Start nicht möglich."), message: Text("Bitte aktiviere zunächst 'Häufigere Updates' in den Systemeinstellungen für diese App."),
                                  dismissButton: .default (Text("Na gut")) {
                                liveActivityViewModel.isStartIssueFrequentPushedSetting = false
                            }
                            )
                        }
                        .alert(isPresented: $liveActivityViewModel.isStartIssueContactingServer) {
                            Alert(title: Text("Start nicht möglich."), message: Text("Server konnte nicht kontaktiert werden."),
                                  dismissButton: .default (Text("Na gut")) {
                                liveActivityViewModel.isStartIssueContactingServer = false
                            }
                            )
                        }
                    Spacer()
                    Button{
                        Task {
                            await liveActivityViewModel.end()
                        }
                    } label: {
                        Text("Stop")
                            .padding(.horizontal, 40)
                            .padding(.vertical, 8)
                            .foregroundColor(!liveActivityViewModel.isActive ? .black : .white)
                            .background(Color(hexOrName: ".red", darker: true))
                            .cornerRadius(28)
                    }.disabled(!liveActivityViewModel.isActive)
                        .opacity(!liveActivityViewModel.isActive ? 0.4 : 1.0)
                }.background(Color(hexOrName: "161616")).cornerRadius(16).padding(30)
            }
            
            Spacer()
            
        }
    }
}

#if DEBUG
struct LiveActivitySettingsContentView_Previews: PreviewProvider {
    
    @State static var model = LiveActivityViewModel()
    
    static var previews: some View {
        LiveActivitySettingsContentView(liveActivityViewModel: model)
            .preferredColorScheme(.dark)
    }
}
#endif
