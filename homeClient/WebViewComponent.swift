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
        webView.scrollView.showsVerticalScrollIndicator = false
    }
    
    func loadWebView() {
        #if targetEnvironment(simulator)
            NSLog("loadWebView()")
        #endif
        var url : String
        if loadUrl().isEmpty {
            let fileUrl = Bundle.main.url(forResource: "signInFirst", withExtension: "html")!
            webView.loadFileURL(fileUrl, allowingReadAccessTo: fileUrl.deletingLastPathComponent())
            url = fileUrl.absoluteString
        }else{
            saveRefreshState(newState: true)
            let request = URLRequest.init(url: URL.init(string: loadUrl())!)
            webView.load(request)
            url = loadUrl()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.webViewMessageHandler.userData!.lastCalledUrl = url
            saveIsWebViewTerminated(newState: false)
        }
    }
    
    func setNavigationDelegate(navigationDelegate : WKNavigationDelegate){
        webView.navigationDelegate = navigationDelegate
    }
    
    func setUserData(userData : UserData){
        webViewMessageHandler.userData = userData
    }
    
    func handleAppInForeground(){
        
        func settingForgroundMarkerFailed(){
            DispatchQueue.main.sync {
                // set to unused to use it after reload
                self.webViewMessageHandler.userData!.webViewFastLinkIsUsed = false
            }
            webView.reload()
        }
        
        func settingForegroundMarcerSucceded(result: Any?) {
            handleFastLink()
        }
        
        if(isHomePageLoaded()){
            HomeWebView.shared.executeScript(script: "setAppInForegroundMarker(true)", errorHandler: settingForgroundMarkerFailed, successHandler: settingForegroundMarcerSucceded);
        }else if (!isHomePageNavigated()){
            loadWebView()
        }
    }

    func handleAppInBackround(){
        if(isHomePageLoaded()){
            executeScript(script: "setAppInForegroundMarker(false)");
        }
    }
    
    fileprivate func fastLinkSuccess(result: Any?){
        DispatchQueue.main.async {
            self.webViewMessageHandler.userData!.webViewFastLinkIsUsed = true
        }
    }
    
    func handleFastLink(){
        if(!self.webViewMessageHandler.userData!.webViewFastLink.isEmpty
           && !self.webViewMessageHandler.userData!.webViewFastLinkIsUsed) {
            HomeWebView.shared.executeScript(script: "fastLinkTo('\(self.webViewMessageHandler.userData!.webViewFastLink)')", errorHandler: {}, successHandler: fastLinkSuccess)
        }
    }
    
    fileprivate func isHomePageLoaded() -> Bool {
        return isHomePageNavigated() && webView.estimatedProgress == 1.0
    }

    fileprivate func isHomePageNavigated() -> Bool {
        return webView.url?.absoluteURL.absoluteString == loadUrl() && webView.title != nil && !loadIsWebViewTerminated()
    }
    
    typealias ScriptErrorHandler = () -> Void
    typealias ScriptSuccessHandler = (_ result : Any?) -> Void
    
    func executeScript(script : String){
        executeScript(script: script, errorHandler: {}, successHandler: {result in })
    }
    
    func executeScript(script : String, errorHandler : @escaping ScriptErrorHandler, successHandler : @escaping ScriptSuccessHandler){
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript(script){ (result, error) in
                if let error = error {
                    NSLog("Script error: \(error) executing: \(script)")
                    errorHandler()
                } else {
                    successHandler(result)
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
        HomeWebView.shared.loadWebView()
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
                HomeWebView.shared.executeScript(script: "window.location.href = '/logoff';", errorHandler: {}, successHandler: {result in
                    saveUserToken(newUserToken: "")
                    saveUserName(newUserName: "")
                })
                saveUserToken(newUserToken: "")
                saveUserName(newUserName: "")
            }
        }
        
        if(!loadUrl().isEmpty && userData.lastCalledUrl != "" && userData.lastCalledUrl != loadUrl()){
            HomeWebView.shared.loadWebView()
            return
        }
        
        if(readCookie && (webView.url?.path(percentEncoded: true) ?? "???") == "/"){
            readLoginTokenCookie(webView.configuration.websiteDataStore, userData: userData)
        }
        
        saveRefreshState(newState: false)
    }
    
    func dismantleUIView(_ uiView: Self.UIViewType, coordinator: Self.Coordinator){
        saveIsWebViewTerminated(newState: true)
        DispatchQueue.main.async {
            userData.lastErrorMsg = "dismantleUIView()";
            userData.lastErrorTs = formattedTS()
        }
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
