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

struct LoadingView<Content>: View where Content: View {
    @Binding var isShowing: Bool
    var content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.content()
                    .disabled(self.isShowing)
                VStack {
                    Image("zuhause")
                        .renderingMode(.template)
                        .foregroundColor(Color.init(hexOrName: ".green", darker: true))
                    ActivityIndicatorView(isAnimating: .constant(true), style: .large)
                }
                .background(.black)
                .opacity(self.isShowing ? 1 : 0)
            }
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

class WebViewModel: ObservableObject {
    @Published var isLoading: Bool = true
}

class Coordinator: NSObject, WKNavigationDelegate {
    private var viewModel: WebViewModel
    
    init(_ viewModel: WebViewModel) {
        self.viewModel = viewModel
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.viewModel.isLoading = false
    }
}