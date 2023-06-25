//
//  WebViewComponent.swift
//  homeClient
//
//  Created by Matthias Fischer on 01.04.21.
//

import SwiftUI
import WebKit

class HomeWebView {
    
    static let shared = HomeWebView()
    
    let webView : WKWebView
    let webViewMessageHandler : WebViewMessageHandler
    
    init(){
        webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.customUserAgent = CONST_WEBVIEW_USERAGENT
        webViewMessageHandler = WebViewMessageHandler();
        webView.configuration.userContentController.add(webViewMessageHandler, name: "homeMessageHandler")
    }
    
    func setNavigationDelegate(navigationDelegate : WKNavigationDelegate){
        webView.navigationDelegate = navigationDelegate
    }
    
    func setUserData(userData : UserData){
        webViewMessageHandler.userData = userData
    }
    
    func executeScript(script : String){
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript(script){ (result, error) in
                if let error = error {
                    NSLog("Script error: \(error) executing: \(script)")
                }
            }
        }
    }
}

struct WebViewComponent : UIViewRepresentable {
    
    @EnvironmentObject private var userData : UserData
    @ObservedObject var viewModel: WebViewModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self.viewModel)
    }
    
    func makeUIView(context: Context) -> WKWebView  {
        
        let webView = HomeWebView.shared.webView
        HomeWebView.shared.setNavigationDelegate(navigationDelegate: context.coordinator)
        HomeWebView.shared.setUserData(userData: userData)
        
        loadWebView(webView)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        
        var readCookie = true
        if(userData.doWebViewLogout){
            DispatchQueue.main.async {
                userData.doWebViewLogout = false
            }
            readCookie = false
            DispatchQueue.main.async {
                webView.evaluateJavaScript("window.location.href = '/logoff';") { (result, error) in
                    if let error = error {
                        print("logout JS error: \(error)")
                    }
                    if let _ = result {
                        saveUserToken(newUserToken: "")
                        saveUserName(newUserName: "")
                    }
                }
                saveUserToken(newUserToken: "")
                saveUserName(newUserName: "")
            }
        }
        
        if(!loadUrl().isEmpty && userData.lastCalledUrl != loadUrl()){
            loadWebView(webView)
            return
        }
        
        if(readCookie && (webView.url?.path(percentEncoded: true) ?? "???") == "/"){
            readLoginTokenCookie(webView.configuration.websiteDataStore, userData: userData)
        }
        
        saveRefreshState(newState: false)
    }
    
    func loadWebView(_ webView: WKWebView) {
        
        if loadUrl().isEmpty {
            let fileUrl = Bundle.main.url(forResource: "signInFirst", withExtension: "html")!
            webView.loadFileURL(fileUrl, allowingReadAccessTo: fileUrl.deletingLastPathComponent())
            DispatchQueue.main.async {
                userData.lastCalledUrl = fileUrl.absoluteString
            }
        }else{
            saveRefreshState(newState: true)
            let request = URLRequest.init(url: URL.init(string: loadUrl())!)
            webView.load(request)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                userData.lastCalledUrl = loadUrl()
            }
        }
    }
    
    func dismantleUIView(_ uiView: Self.UIViewType, coordinator: Self.Coordinator){
        // nothing to do here
    }
    
    func readLoginTokenCookie(_ store : WKWebsiteDataStore, userData : UserData) {
        store.httpCookieStore.getAllCookies { (cookies) in
            for cookie in cookies {
                if(cookie.name == CONST_WEBVIEW_COOKIENAME){
                    if(loadUserToken() != cookie.value){
                        saveUserToken(newUserToken: cookie.value)
                        saveUserName(newUserName: cookie.value.components(separatedBy: "*")[0])
                    }
                }
            }
        }
    }
    
}
