//
//  WebViewComponent.swift
//  homeClient
//
//  Created by Matthias Fischer on 01.04.21.
//

import SwiftUI
import WebKit

struct WebViewComponent : UIViewRepresentable {
    
    @EnvironmentObject private var userData : UserData
    
    var webViewObserver = WebViewObserver();
    
    func makeUIView(context: Context) -> WKWebView  {
        
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.customUserAgent = "HomeClientAppWebView"
        webViewObserver.userData = userData
        webViewObserver.webView = webView
        webView.addObserver(webViewObserver, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        webView.addObserver(webViewObserver, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)
        
        loadWebView(webView)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        
        if(userData.doWebViewLogout){
            userData.doWebViewLogout = false
            DispatchQueue.main.async {
                webView.evaluateJavaScript("window.location.href = '/logoff';") { (result, error) in
                    if let error = error {
                        print("logout JS error: \(error)")
                    }
                }
            }
        }
        
        if(!loadUrl().isEmpty && userData.lastCalledUrl != loadUrl()){
            loadWebView(webView)
            return
        }
        
        // Workaround for cookie refresh bug
        readLoginTokenCookie(webView.configuration.websiteDataStore)
        saveRefreshState(newState: false)
    }
    
    func loadWebView(_ webView: WKWebView) {
        
        if loadUrl().isEmpty {
            let fileUrl = Bundle.main.url(forResource: "signInFirst", withExtension: "html")!
            webView.loadFileURL(fileUrl, allowingReadAccessTo: fileUrl.deletingLastPathComponent())
            userData.lastCalledUrl = fileUrl.absoluteString
        }else{
            saveRefreshState(newState: true)
            var request = URLRequest.init(url: URL.init(string: loadUrl())!)
            request.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
            request.addValue(loadUserToken(), forHTTPHeaderField: "appAdditionalCookieHeader")
            webView.load(request)
            userData.lastCalledUrl = loadUrl()
        }
    }
    
    func dismantleUIView(_ uiView: Self.UIViewType, coordinator: Self.Coordinator){
        uiView.removeObserver(webViewObserver, forKeyPath: #keyPath(WKWebView.title))
    }
    
    func readLoginTokenCookie(_ store : WKWebsiteDataStore) {
        store.httpCookieStore.getAllCookies { (cookies) in
            for cookie in cookies {
                if(cookie.name == "HomeLoginCookie"){
                    if(loadUserToken() != cookie.value){
                        saveUserToken(newUserToken: cookie.value)
                        saveUserName(newUserName: cookie.value.components(separatedBy: "*")[0])
                    }
                }
            }
        }
    }
    
}
