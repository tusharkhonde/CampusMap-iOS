//
//  Constants.swift
//  SJSU_Map_Lab3
//
//  Created by TUSHAR KHONDE on 11/12/15.
//  Copyright © 2015 TUSHAR KHONDE. All rights reserved.
//

import Foundation
import CoreLocation


struct Constants {
    
    static let API = ""
    static let KEY = "key"
    static let PROTOCOL = "https://"
    static let BASE_URL = "maps.googleapis.com/"
    static let SERVICE_REQUESTED = "maps/api/"
    static let PATH = "distancematrix/"
    static let RESPONSE_TYPE = "json"
    static let ORIGIN = "origins"
    static let DESTINATION = "destinations"
    
    static let SJSU_SW : CLLocationCoordinate2D = CLLocationCoordinate2DMake(37.331361, -121.886478);
    static let SJSU_NE : CLLocationCoordinate2D = CLLocationCoordinate2DMake(37.338800, -121.876243);
}