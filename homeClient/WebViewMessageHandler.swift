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
    
    var userData : UserData?
    
    var selectionGenerator : UISelectionFeedbackGenerator
    override init() {
        selectionGenerator = UISelectionFeedbackGenerator()
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
            NSLog("homeMessageHandler key: \(key) value: \(String(describing: value))")
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
                self.userData?.webViewTitle = value ?? ""
            }
        case "loadedView":
            if let userData = self.userData {
                DispatchQueue.main.async {
                    userData.webViewRefreshPending = false
                }
                HomeWebView.shared.executeScript(script: "if(typeof setPushToken === 'function'){setPushToken('\(lookupPushToken(userData: userData))', '\(userData.device)');}")
                if(!userData.webViewFastLink.isEmpty) {
                    HomeWebView.shared.executeScript(script: "fastLinkTo('\(userData.webViewFastLink)')")
                    DispatchQueue.main.async {
                        userData.webViewFastLink = ""
                    }
                }
            }
        case "confirmForegroundMarker":
            DispatchQueue.main.async {
                self.userData?.webViewRefreshPending = false
            }
        case "log":
                NSLog("WebView log message: \(value ?? "")")
        default:
            return
        }
    }
}
