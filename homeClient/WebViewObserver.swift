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
                            self.userData.webViewPath = url.path ?? ""
                        }
                    }
                }
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
