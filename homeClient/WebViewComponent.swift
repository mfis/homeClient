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
        
        if(!userData.homeUrl.isEmpty && userData.lastCalledUrl != userData.homeUrl){
            loadWebView(webView)
            return
        }
        
        // Workaround for cookie refresh bug
        readLoginTokenCookie(webView.configuration.websiteDataStore)
    }
    
    func loadWebView(_ webView: WKWebView) {
        
        if userData.homeUrl.isEmpty {
            let fileUrl = Bundle.main.url(forResource: "signInFirst", withExtension: "html")!
            webView.loadFileURL(fileUrl, allowingReadAccessTo: fileUrl.deletingLastPathComponent())
            userData.lastCalledUrl = fileUrl.absoluteString
        }else{
            var request = URLRequest.init(url: URL.init(string: userData.homeUrl)!)
            request.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
            request.addValue(userData.homeUserToken, forHTTPHeaderField: "appAdditionalCookieHeader")
            webView.load(request)
            userData.lastCalledUrl = userData.homeUrl
        }
    }
    
    func dismantleUIView(_ uiView: Self.UIViewType, coordinator: Self.Coordinator){
        uiView.removeObserver(webViewObserver, forKeyPath: #keyPath(WKWebView.title))
    }
    
    func readLoginTokenCookie(_ store : WKWebsiteDataStore) {
        store.httpCookieStore.getAllCookies { (cookies) in
            for cookie in cookies {
                if(cookie.name == "HomeLoginCookie"){
                    if(userData.homeUserToken != cookie.value){
                        userData.homeUserToken = cookie.value
                        saveUserToken(newUserToken: cookie.value)
                    }
                }
            }
        }
    }
    
}
