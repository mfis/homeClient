//
//  AuthController.swift
//  homeClient
//
//  Created by Matthias Fischer on 07.03.24.
//

import Foundation
import LocalAuthentication

class AuthController : ObservableObject {

    func isAvailable(completion: @escaping (Bool?) -> Void){
        let context = LAContext()
        var failureReason : NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &failureReason) {
            completion(context.biometryType != LABiometryType.none)
        } else {
            NSLog("AuthController#isAvailable#ERROR")
            completion(false)
        }
    }
    
    func doAuthentication(completion : @escaping (Bool?) -> Void){
        let context = LAContext()
        let reason = "Start Biometric"
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            if success {
                completion(true)
            } else if let error = error as? LAError {
                NSLog("biometric authentication error: " + error.localizedDescription)
                completion(false)
            } else {
                NSLog("biometric authentication unknown state")
                completion(false)
            }
        }
    }
}
