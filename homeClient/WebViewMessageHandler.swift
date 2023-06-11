//
//  WebViewObserver.swift
//  iOSHomeApp
//
//  Created by Matthias Fischer on 03.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

import Foundation
import WebKit

class WebViewMessageHandler : NSObject, WKScriptMessageHandler {
    
    let userData : UserData
    let webView : WKWebView?
    
    var selectionGenerator : UISelectionFeedbackGenerator
    init(ud : UserData, ww : WKWebView) {
        selectionGenerator = UISelectionFeedbackGenerator()
        userData = ud
        webView = ww
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if(message.name != "homeMessageHandler"){
            return
        }
        
        let messageBody = message.body as! String
        var key: String
        var value : String?
        
        if let range = messageBody.range(of: "=") {
            key = String(messageBody[messageBody.startIndex..<range.lowerBound])
            value =  String(messageBody[range.upperBound...])
        }else{
            key = messageBody
        }
        
        #if DEBUG
            NSLog("homeMessageHandler key: \(key)")
        #endif
        
        switch key {
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
        case "modelTimestamp":
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.userData.webViewTitle = value ?? ""
            }
        case "loadedView":
            if(!self.userData.webViewFastLink.isEmpty){
                DispatchQueue.main.async {
                    NSLog("fastLinkTo('\(self.userData.webViewFastLink)')")
                    self.webView?.evaluateJavaScript("fastLinkTo('\(self.userData.webViewFastLink)')")
                    self.userData.webViewFastLink = ""
                }
            }
            DispatchQueue.main.async {
                self.webView?.evaluateJavaScript("if(typeof setPushToken === 'function'){setPushToken('\(lookupPushToken(userData: self.userData))', '\(self.userData.device)');}") { (result, error) in
                    if let error = error {
                        NSLog("setPushToken JS error: \(error)")
                    }
                }
            }
        default:
            print("WKWEBVIEW Message received: \(message.name) with body: \(message.body)")
        }
    }
}
