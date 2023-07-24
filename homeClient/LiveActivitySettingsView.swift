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
    @State private var selected = "Test"
    let theme = ["Test"]

    var body: some View {

        VStack(spacing: 30) {
            
            Text("Live-Aktivität").font(Font.title).padding(.top, 30).foregroundColor(Color.init(hexOrName: liveActivityViewModel.isActive ? ".green" : ".white", darker: true))
            
                Section {
                    Picker("Strength", selection: $selected) {
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

            #if DEBUG
            Section {
                Text("ContentState: \(liveActivityViewModel.contentState.debugDescription)")
            }
            #endif

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
