//
//  WebViewLoadingIndicator.swift
//  homeClient
//
//  Created by Matthias Fischer on 25.06.23.
//
//  Attribution to Stackoverflow question/answer used for this code:
//  https://stackoverflow.com/users/264802/gotnull
//  https://stackoverflow.com/users/12053724/nickreps
//  https://stackoverflow.com/questions/60051231/swiftui-how-can-i-add-an-activity-indicator-in-wkwebview

import SwiftUI
import WebKit

struct LoadingView : View {
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack {
                Image("zuhause")
                    .renderingMode(.template)
                    .foregroundColor(Color.init(hexOrName: ".green", darker: true)).padding(.bottom, 10)
                ActivityIndicatorView(isAnimating: .constant(true), style: .large)
            }.frame(width: 100, height: 150)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(Color.init(hexOrName: "242424"), lineWidth: 0)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(Color.init(hexOrName: "242424"))
                        )
                )
        }
    }
}

struct ActivityIndicatorView: UIViewRepresentable {
    
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorView>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorView>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
