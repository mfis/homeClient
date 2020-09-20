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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        switch keyPath {
        case #keyPath(WKWebView.title):
            if let dict = change{
                for (key,value) in dict {
                    if(key.rawValue == "new"){
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.userData.webViewTitle = (value as! String)
                        }
                    }
                }
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
