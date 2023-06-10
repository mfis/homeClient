//
//  WebViewObserver.swift
//  iOSHomeApp
//
//  Created by Matthias Fischer on 03.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

import Foundation
import WebKit

class WebViewObserver : NSObject {
    
    var userData : UserData = UserData()
    var webView : WKWebView? = nil
    var lastTitleValue : String = ""
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        switch keyPath {
        case #keyPath(WKWebView.title):
            if let dict = change{
                for (key,value) in dict {
                    if(key.rawValue == "new"){
                        let newTitleValue = value as! String
                        if(lastTitleValue != newTitleValue){
                            if(newTitleValue.starts(with: "ts=")){
                                if let range = newTitleValue.range(of: "ts=") {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self.userData.webViewTitle = String(newTitleValue[range.upperBound...])
                                    }
                                    if(!self.userData.webViewFastLink.isEmpty){
                                        DispatchQueue.main.async {
                                            NSLog("fastLinkTo('\(self.userData.webViewFastLink)')")
                                            self.webView?.evaluateJavaScript("fastLinkTo('\(self.userData.webViewFastLink)')")
                                            self.userData.webViewFastLink = ""
                                        }
                                    }
                                }
                            }
                            if(!loadUrl().isEmpty && userData.webViewPath == "/"){
                                DispatchQueue.main.async {
                                    self.webView?.evaluateJavaScript("if(typeof setPushToken === 'function'){setPushToken('\(lookupPushToken(userData: self.userData))', '\(self.userData.device)');}") { (result, error) in
                                        if let error = error {
                                            NSLog("setPushToken JS error: \(error)")
                                        }
                                    }
                                }
                            }
                        }
                        lastTitleValue = newTitleValue
                    }
                }
            }
        case #keyPath(WKWebView.url):
            if let dict = change{
                for (key,value) in dict {
                    if(key.rawValue == "new"){
                        if let url = value as? NSURL {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.userData.webViewPath = url.path ?? ""
                            }
                        }
                    }
                }
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

class WebViewMessageHandler : NSObject, WKScriptMessageHandler {
    
    var selectionGenerator : UISelectionFeedbackGenerator
    override init() {
        selectionGenerator = UISelectionFeedbackGenerator()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "homeMessageHandler":
            switch message.body as! String {
            case "startTransition":
                    selectionGenerator.selectionChanged()
            case "endTransition":
                    selectionGenerator.selectionChanged()
            case "startButtonPress":
                    selectionGenerator.selectionChanged()
            case "endButtonPress":
                    selectionGenerator.selectionChanged()
            case "changeSelection":
                    selectionGenerator.selectionChanged()
            default:
                print("WKWEBVIEW Message received: \(message.name) with body: \(message.body)")
            }
        default:
            print("WKWEBVIEW Message received: \(message.name) with body: \(message.body)")
        }
    }
}
