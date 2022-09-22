//
//  ComplicationData.swift
//  homeClient WatchKit Extension
//
//  Created by Matthias Fischer on 07.09.21.
//

import SwiftUI
import ClockKit
import os

class ComplicationData: ObservableObject {
 
    init(vm : HomeViewValueModel?) {
        valueModel = vm
    }
    
    static let shared = ComplicationData(vm: nil)
    
    var lastReloadDirectFromController = Date(timeIntervalSince1970: 0)
    
    @Published var valueModel : HomeViewValueModel? = nil {
        
        didSet {
            DispatchQueue.global().async {
                let server = CLKComplicationServer.sharedInstance()
                for complication in server.activeComplications ?? [] {
                    server.reloadTimeline(for: complication)
                }
            }
        }
    }
}

func loadComplicationData(){
    
    func onError(msg : String, rc : Int){
        NSLog("!!! loadComplicationData - onError: \(rc) - \(msg)")
        let model = ComplicationData.shared
        model.valueModel = nil
        saveComplicationError(newString: "\(formattedTS()): rc=\(rc) - \(msg)")
    }
    
    func onSuccess(response : String, newToken : String?){
        let decoder = JSONDecoder ()
        do{
          let newModel = try decoder.decode(HomeViewModel.self, from: response.data(using: .utf8)!)
            refreshComplicationData(model: newModel)
        } catch let jsonError as NSError {
            onError(msg : "error parsing json document. \(jsonError.localizedDescription)", rc : -2)
        }
    }
    
    if(!loadUserToken().isEmpty && !loadRefreshState()){
        let authDict = ["appUserName": loadUserName(), "appDevice" : loadDeviceName()]
          httpCall(urlString: loadUrl() + "getAppModel?viewTarget=complication", pin: nil, timeoutSeconds: 10.0, method: HttpMethod.GET, postParams: nil, authHeaderFields: authDict, errorHandler: onError, successHandler: onSuccess)
    }
}

func refreshComplicationData(model : HomeViewModel){
    for place in model.places{
        if(place.placeDirectives.contains(CONST_PLACE_DIRECTIVE_WATCH_SYMBOL)){
            for value in place.values{
                let complicationData = ComplicationData.shared
                complicationData.valueModel = value
                break
            }
        }
    }
}
