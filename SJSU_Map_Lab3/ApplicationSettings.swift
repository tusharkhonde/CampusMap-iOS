//
//  ApplicationSettings.swift
//  SJSU_Map_Lab3
//
//  Created by TUSHAR KHONDE on 11/10/15.
//  Copyright © 2015 TUSHAR KHONDE. All rights reserved.
//

import UIKit

class ApplicationSettings: NSObject {
    
    static let sharedSettings = ApplicationSettings();
    
    private override init() {
        
    }
    
    func setZoom (zoom:CGFloat) {
        
        NSUserDefaults.standardUserDefaults().setFloat(Float(zoom), forKey: "zoomLevel");
        NSUserDefaults.standardUserDefaults().synchronize();
    }
    
    func zoom () -> CGFloat? {
        
        return CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("zoomLevel"));
    }
    
    func setContentOffset(contentOffset:CGPoint) {
        
        NSUserDefaults.standardUserDefaults().setObject(NSStringFromCGPoint(contentOffset), forKey: "contentOffset");
        NSUserDefaults.standardUserDefaults().synchronize();
    }
    
    func contentOffset () -> CGPoint {
        
        if ((NSUserDefaults.standardUserDefaults().objectForKey("contentOffset")) != nil) {
            
            return CGPointFromString(NSUserDefaults.standardUserDefaults().objectForKey("contentOffset") as! String);
        } else {
            
            return CGPointMake(0, 0);
        }
    }
}