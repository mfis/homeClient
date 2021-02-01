//
//  Network.swift
//  iOSHomeApp
//
//  Created by Matthias Fischer on 03.09.20.
//  Copyright © 2020 Matthias Fischer. All rights reserved.
//

import Foundation

func cleanupUrl(forUrl: String) -> String {
    var url = forUrl.lowercased()
    if(!url.starts(with: "http://") && !url.starts(with: "https://")){
        url = "https://" + url
    }
    if(!url.hasSuffix("/")){
        url = url + "/"
    }
    return url
}

enum HttpMethod : String{
    case GET = "GET"
    case POST = "POST"
}

typealias HttpErrorHandler = (_ msg : String, _ rc : Int) -> Void
typealias HttpSuccessHandler = (_ response : String, _ newToken : String?) -> Void

func httpCall(urlString : String, timeoutSeconds : Double, method : HttpMethod, postParams: [String: String]?, authHeaderFields: [String: String]?, errorHandler : @escaping HttpErrorHandler, successHandler : @escaping HttpSuccessHandler) {
    
    let url = URL(string: urlString)
    guard let requestUrl = url else { fatalError() }
    let timeout : TimeInterval = timeoutSeconds
    var request = URLRequest(url: requestUrl, timeoutInterval: timeout)
    request.httpMethod = method.rawValue
    if let postParams = postParams {
        request.httpBody = buildQuery(postParams).data(using: .utf8)
    }
    if let authHeaderFields = authHeaderFields {
        NSLog("token used: \(authHeaderFields["appUserToken"]!.prefix(50)) for url=\(urlString)")
        request.addValue(authHeaderFields["appUserName"]!, forHTTPHeaderField: "appUserName")
        request.addValue(authHeaderFields["appUserToken"]!, forHTTPHeaderField: "appUserToken")
        request.addValue(authHeaderFields["appDevice"]!, forHTTPHeaderField: "appDevice")
        if let _ = authHeaderFields["refreshToken"]{
            request.addValue(authHeaderFields["refreshToken"]!, forHTTPHeaderField: "refreshToken")
        }
    }
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let e = error {
            errorHandler("\(e)", -1)
            return
        }
        var newUserToken : String?
        if let httpResponse = response as? HTTPURLResponse {
            if(httpResponse.statusCode != 200){
                errorHandler("StatusCode: \(httpResponse.statusCode)", httpResponse.statusCode)
                return
            }else{
                newUserToken = httpResponse.value(forHTTPHeaderField: "appUserToken");
                if let newUserToken = newUserToken{
                    NSLog("new token recieved: \(newUserToken.prefix(50))")
                }
            }
        }
        guard let data = data else {return}
        let dataString = String(data: data, encoding: String.Encoding.utf8)! as String
        successHandler(dataString, newUserToken)
    }
    
    task.resume()
}

fileprivate func buildQuery(_ params: [String: String]) -> String {
    var query = ""
    for key in params.keys {
        query = query + (query.isEmpty ? "" : "&")
        query = query + key + "=" + urlEncode(params[key]!)
    }
    return query
}

fileprivate func urlEncode(_ string : String) -> String {
    let encoded = string.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
    return encoded!
}
