//
//  DetailViewController.swift
//  SJSU_Map_Lab3
//
//  Created by TUSHAR KHONDE on 11/10/15.
//  Copyright © 2015 TUSHAR KHONDE. All rights reserved.
//

import UIKit
import CoreLocation

class DetailViewController: UIViewController, LocationUtilityProtocol{
    
    @IBOutlet weak var buildingImage: UIImageView!
    @IBOutlet weak var buildingName: UILabel!
    @IBOutlet weak var buildingAdderss: UITextView!
    @IBOutlet weak var buildingDistance: UILabel!
    @IBOutlet weak var timeRequired: UILabel!
    var building : Building!

    
    var currentLocation : CLLocationCoordinate2D = CLLocationCoordinate2D();
    
    var count : Int = 1;
    var timer : NSTimer = NSTimer();
    
    let activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge);
    
    var locationUtil : Location = Location.init();
    var locationManager : CLLocationManager = CLLocationManager();

    
    override func viewDidLoad() {
       super.viewDidLoad()
       self.title = "Building Details";
        
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor();
        self.navigationController!.navigationItem.backBarButtonItem?.title = "Map";
        
        locationManager = CLLocationManager.init();
        locationManager.delegate = locationUtil;
        locationUtil.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let selector : Selector = Selector("requestWhenInUseAuthorization");
        if (self.locationManager.respondsToSelector(selector)) {
            
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        buildingName.text = building.name;
        buildingAdderss.text = building.address;
        let backgroundImage : UIImage = building.image!;
        buildingImage.image = backgroundImage
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        getLocationPermission();
        getDistanceMatrix();
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        timer.invalidate();
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // Distance and Time
    
    func getDataMatrixFrom (response : NSDictionary) -> NSDictionary {
        
        let rows : NSArray = NSArray(array: (response.objectForKey("rows") as! NSArray));
        
        let subDictionary : NSDictionary = NSDictionary(dictionary: (rows.lastObject as! NSDictionary));
        
        let elements : NSArray = NSArray(array: (subDictionary.objectForKey("elements") as! NSArray));
        
        let dataMatrix : NSDictionary = NSDictionary(dictionary: (elements.lastObject as! NSDictionary));
        
        return dataMatrix;
    }
    
    func didUpdateLocation(location : CLLocationCoordinate2D) {
        
        currentLocation = location;
        getDistanceMatrix();
    }
    
    func didFail(error : NSError) {
        
    }
    
    func didChangeStatus(status : CLAuthorizationStatus) {
        
        if (CLLocationManager.authorizationStatus() == .Denied ||
            CLLocationManager.authorizationStatus() == .Restricted ||
            CLLocationManager.authorizationStatus() == .NotDetermined) {
                
                let selector : Selector = Selector("requestWhenInUseAuthorization");
                if (self.locationManager.respondsToSelector(selector)) {
                    
                    self.locationManager.requestWhenInUseAuthorization()
                }
        }
        if (status == .AuthorizedWhenInUse || status == .AuthorizedAlways) {
            
            locationManager.startUpdatingLocation();
        }
    }
    
    
    func getLocationPermission () {
        
        if(isLocationServiceEnable() == true) {
            
            locationManager.startUpdatingLocation()
        } else {
            
            let alertController = UIAlertController (title: "Failure", message: "Enable location from Settings", preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
            alertController.addAction(dismissAction)
             let settingsAction = UIAlertAction(title: "Open settings", style: .Default, handler: { (_) -> Void in
                self.openSettings();
            });
            
            alertController.addAction(settingsAction);
              presentViewController(alertController, animated: true, completion: { () -> Void in
                 self.locationManager.startUpdatingLocation();
            });
        }
    }
    
    func isLocationServiceEnable () -> Bool {
        
        if (CLLocationManager.authorizationStatus() == .Denied ||
            CLLocationManager.authorizationStatus() == .Restricted ||
            CLLocationManager.authorizationStatus() == .NotDetermined) {
                return false;
        }
        return true;
    }
    
    func openSettings () {
        let stringUrl : String = String(format: "%@BundleID", UIApplicationOpenSettingsURLString);
        let settingsUrl = NSURL(string: stringUrl)
        UIApplication.sharedApplication().openURL(settingsUrl!)
    }
    
    func getDistanceMatrix () {
        
        let fromLocation : String = String(format: "%f,%f", currentLocation.latitude, currentLocation.longitude);
        let toLocation : String = String(building.address.stringByReplacingOccurrencesOfString(" ", withString: "+"));
        
        if (currentLocation.latitude != 0.0 && currentLocation.longitude != 0.0) {
            
            let url : NSURL = prepareUrlUsing(fromLocation, toLocation: toLocation);
            ConnectionUtility.getDataFrom(url, onCompletion: { (responseDictionary : [NSObject : AnyObject]!, error : NSError!) -> Void in
                
                if (error != nil) {
                    
                    let errorAlert : UIAlertController = UIAlertController(title: "Failure", message: "Unable to get distance location", preferredStyle: UIAlertControllerStyle.Alert);
                    
                    let dismissAction : UIAlertAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil);
                    errorAlert.addAction(dismissAction);
                    
                    self.presentViewController(errorAlert, animated: true, completion: nil);
                    
                } else {
                    
                    let dataMatrix : NSDictionary = self.getDataMatrixFrom(responseDictionary as NSDictionary);
                    
                    let distanceMatrix : NSDictionary = NSDictionary(dictionary: (dataMatrix.objectForKey("distance") as! NSDictionary));
                    let timeMatrix : NSDictionary = NSDictionary(dictionary: (dataMatrix.objectForKey("duration") as! NSDictionary));
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.timeRequired.text = timeMatrix.objectForKey("text") as? String;
                        self.buildingDistance.text = distanceMatrix.objectForKey("text") as? String;
                        
                        self.activityIndicator.stopAnimating();
                    });
                }
            })
        } else {
            
            let errorAlert : UIAlertController = UIAlertController(title: "Error!", message: "Unable to get user location", preferredStyle: UIAlertControllerStyle.Alert);
            
            let dismissAction : UIAlertAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil);
            errorAlert.addAction(dismissAction);
            
            presentViewController(errorAlert, animated: true, completion: nil);
            activityIndicator.stopAnimating();
        }
    }
    
     func prepareUrlUsing(fromLocation : String!, toLocation : String!) -> NSURL {
        
        var stringUrl : String = String(format: "%@%@%@%@%@?%@=%@&%@=%@&%@=%@",Constants.PROTOCOL, Constants.BASE_URL, Constants.SERVICE_REQUESTED, Constants.PATH, Constants.RESPONSE_TYPE, Constants.ORIGIN, fromLocation, Constants.DESTINATION, toLocation, Constants.KEY, Constants.API);
        
        stringUrl = stringUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!;
        
        return NSURL(string: stringUrl)!;
    }

}
