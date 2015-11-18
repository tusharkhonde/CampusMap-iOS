//
//  Location.swift
//  SJSU_Map_Lab3
//
//  Created by TUSHAR KHONDE on 11/12/15.
//  Copyright © 2015 TUSHAR KHONDE. All rights reserved.
//

import UIKit
import CoreLocation


protocol LocationUtilityProtocol {
    
    func didUpdateLocation(location : CLLocationCoordinate2D);
    func didFail(error : NSError);
    func didChangeStatus(status : CLAuthorizationStatus);
}

class Location: NSObject, CLLocationManagerDelegate {
    
    var currentLocation : CLLocationCoordinate2D;
    var delegate : LocationUtilityProtocol?;
    
    override init() {
        
        self.currentLocation = CLLocationCoordinate2D();
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = (locations.last?.coordinate)!;
        if let delegate = self.delegate {
             delegate.didUpdateLocation(currentLocation);
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
     if let delegate = self.delegate {
            delegate.didFail(error);
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if let delegate = self.delegate {
            delegate.didChangeStatus(status);
        }
    }
}