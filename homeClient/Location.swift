//
//  Location.swift
//  homeClient
//
//  Created by Matthias Fischer on 09.06.22.
//

import Foundation
import UIKit
import SwiftUI
import CoreLocation

final class Location: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    let identifier = "Zuhause"
    
    @Published var authorizationStatus: CLAuthorizationStatus
    private var lastLocation: CLLocation?
    private let locationManager: CLLocationManager
    
    static let shared = Location()
    
    fileprivate override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        if(loadIsGeofencingOn()){
            _ = geofencingForHome()
        }
    }
    
    fileprivate enum PresenceState: String {
        case PRESENT
        case AWAY
        case UNKNOWN
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.first
    }
    
    func getDistanceFromHome() -> Double? {
        if let lat = loadGeofencingLat(), let lon = loadGeofencingLon(){
            if let distance = lastLocation?.distance(from: CLLocation(latitude:lat, longitude:lon)) {
                return Double(distance)
            }
            if let distance = locationManager.location?.distance(from: CLLocation(latitude:lat, longitude:lon)) {
                return Double(distance)
            }
        }
        return nil
    }
    
    func geofencingForHome() -> Bool {
        if let lat = loadGeofencingLat(), let lon = loadGeofencingLon(), let radius = loadGeofencingRadius(){
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), radius: radius, identifier: identifier)
                locationManager.startMonitoring(for: region)
                if let distance = getDistanceFromHome(), let radius = loadGeofencingRadius() {
                    if(distance.isLessThanOrEqualTo(radius)){
                        handleState(presenceState: PresenceState.PRESENT)
                    }else{
                        handleState(presenceState: PresenceState.AWAY)
                    }
                    return true
                }
            }
        }
        handleState(presenceState: PresenceState.UNKNOWN)
        return false
    }
    
    func stopGeofencing() -> Bool {
        if let lat = loadGeofencingLat(), let lon = loadGeofencingLon(), let radius = loadGeofencingRadius(){
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), radius: radius, identifier:identifier)
            locationManager.stopMonitoring(for: region)
            handleState(presenceState: PresenceState.UNKNOWN)
            return true
        } else{
            return false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        handleState(presenceState: PresenceState.PRESENT)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        handleState(presenceState: PresenceState.AWAY)
    }
    
    fileprivate func handleState(presenceState : PresenceState) {
        writePresenceState(presenceState: presenceState.rawValue)
    }
}
