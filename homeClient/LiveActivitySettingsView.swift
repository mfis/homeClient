//
//  LiveActivitySettingsView.swift
//  homeClient
//
//  Created by Matthias Fischer on 22.07.23.
//

import Foundation
import SwiftUI

struct LiveActivitySettingsContentView: View {
    
    @StateObject var liveActivityViewModel : LiveActivityViewModel

    var body: some View {
        VStack(spacing: 30) {
            Text("Live Aktivität").font(Font.title)
            
            Button{
                liveActivityViewModel.start()
            } label: {
                Text("Start")
                    .padding(.horizontal, 40)
                    .padding(.vertical, 8)
                    .foregroundColor(.black)
                    .background(.green)
                    .cornerRadius(28)
            }
            
            Button("Stop") {
                Task {
                    await liveActivityViewModel.end()
                }
            }.background(Color.red)
            #if DEBUG
                Section("-- DEBUG / DEVELOPMENT --") {
                    Text("ContentState: \(liveActivityViewModel.contentState.debugDescription)")
                }
            #endif
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
