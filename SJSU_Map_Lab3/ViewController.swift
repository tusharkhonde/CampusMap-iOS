//
//  ViewController.swift
//  SJSU_Map_Lab3
//
//  Created by TUSHAR KHONDE on 11/7/15.
//  Copyright © 2015 TUSHAR KHONDE. All rights reserved.
//
import UIKit
import CoreLocation

class ViewController: UIViewController, UIScrollViewDelegate, UISearchBarDelegate,CLLocationManagerDelegate, LocationUtilityProtocol{
    

    @IBOutlet weak var contentImageView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var kingButton: UIButton!
    @IBOutlet weak var enggButton: UIButton!
    @IBOutlet weak var bbcButton: UIButton!
    @IBOutlet weak var southButton: UIButton!
    @IBOutlet weak var yoshidaButton: UIButton!
    @IBOutlet weak var studentButton: UIButton!
    
    
    var currentLocation : CLLocationCoordinate2D = CLLocationCoordinate2D();
    var locationManager : CLLocationManager = CLLocationManager();
    var locationUtil : Location = Location.init();
    
    
    let building1 = Building(name: "King Library",address: "Dr. Martin Luther King, Jr. Library, 150 East San Fernando Street, San Jose, CA 95112",image: UIImage(named: "kingLibrary.jpg"), tag: "1001")
    
    let building2 =  Building(name: "Engineering Building",address: "San José State University Charles W. Davidson College of Engineering, 1 Washington Square, San Jose, CA 95112", image: UIImage(named: "engg.jpg"), tag: "1002")
    
    let building3 =  Building(name: "Yoshihiro Uchida Hall",address: "Yoshihiro Uchida Hall, San Jose, CA 95112", image: UIImage(named: "yoshida.jpg"), tag: "1003")
    
    let building4 =  Building(name: "Student Union", address: "Student Union Building, San Jose, CA 95112", image: UIImage(named: "studentUnion.jpg"), tag: "1004")
    
    let building5 =  Building(name: "BBC", address: "Boccardo Business Complex, San Jose, CA 95112", image: UIImage(named: "bbc.jpg"), tag: "1005")
    
    let building6 =  Building(name: "South Parking Garage", address: " San Jose State University South Garage, 330 South 7th Street, San Jose, CA 95112", image: UIImage(named: "southGarage.png"), tag: "1006")

    var searchModeOn : Bool = false;
    var searchText : String = "";
    
    var selectedBuilding : Building = Building(name: "",address: "",image: UIImage(named: ""), tag: "");
     var searchedBuilding : Building = Building(name: "",address: "",image: UIImage(named: ""), tag: "");

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "SJSU Interactive Map";
        self.automaticallyAdjustsScrollViewInsets = false;
        
        
        locationManager = CLLocationManager.init();
        locationManager.delegate = locationUtil;
        locationUtil.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        let selector : Selector = Selector("requestWhenInUseAuthorization");
        if (self.locationManager.respondsToSelector(selector)) {
            self.locationManager.requestWhenInUseAuthorization()
        }

        scrollView.contentSize = UIImage(imageLiteral: "map2").size;
    }
    

    override func viewDidAppear(animated: Bool) {
        getLocationPermission()
        
        if (ApplicationSettings.sharedSettings.zoom() != 1.0) {
            
            scrollView.zoomScale = ApplicationSettings.sharedSettings.zoom()!;
            scrollView.contentOffset = ApplicationSettings.sharedSettings.contentOffset();
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning();
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "detailView" {
            
            print("Detail View Segue");

            let detailViewController : DetailViewController = segue.destinationViewController as! DetailViewController
            detailViewController.building = selectedBuilding;
            detailViewController.currentLocation = currentLocation;
       
        }
        
    }
    
    @IBAction func buildingButtonTapped(sender: UIButton?) {
        
                let touchedButton : UIButton = sender! ;
        
            if(touchedButton.tag.description == "1001"){
        
                selectedBuilding = building1
                print("King Library Button Pressed");
                performSegueWithIdentifier("detailView", sender: self);
                
            }
            else if(touchedButton.tag.description == "1002"){
            
            selectedBuilding = building2;
            print("Engg Building Button Pressed");
            performSegueWithIdentifier("detailView", sender: self);
            }
            else if(touchedButton.tag.description == "1003"){
            
                selectedBuilding = building3;
            print("Yoshihiro Button Pressed");
            performSegueWithIdentifier("detailView", sender: self);
            }
            else if(touchedButton.tag.description == "1004"){
            
            selectedBuilding = building4;
            print("Studnet Union Button Pressed");
            performSegueWithIdentifier("detailView", sender: self);
            }
            else if(touchedButton.tag.description == "1005"){
            
            selectedBuilding = building5;
            print("BBC Button Pressed");
            performSegueWithIdentifier("detailView", sender: self);
            }
            else if(touchedButton.tag.description == "1006"){
            
            selectedBuilding = building6;
            print("South Garage Button Pressed");
            performSegueWithIdentifier("detailView", sender: self);
            }
        
    }
 
    // Scroll View Function

    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        
        if(!searchModeOn) {
            
            ApplicationSettings.sharedSettings.setZoom(scrollView.zoomScale);
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if(!searchModeOn) {
            
            ApplicationSettings.sharedSettings.setContentOffset(scrollView.contentOffset);
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return contentImageView;
    }

    func alertControllerWithMessage(message : String) -> UIAlertController {
        
        let alertController = UIAlertController (title: "Failure", message: message, preferredStyle: .Alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        
        return alertController;
    }
    
    // Search Function
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        if ((searchBar.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) == nil) {
            
            hideHighlightViews();
        }
    }
    
    func searchBar(searchBar: UISearchBar, var textDidChange searchText: String) {
        
        searchModeOn = true;
        hideHighlightViews();
        
        searchText = searchBar.text!;
        
        displaySearchResult();
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        searchBar.text = "";
        searchBar.resignFirstResponder();
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder();
        searchText = searchBar.text!;
        
        displaySearchResult();
    }

    func hideHighlightViews () {
        
        var tag : Int = 1;
        for (tag = 1; tag<7; tag++) {
            
            let button : UIButton = self.view.viewWithTag(1000+tag) as! UIButton;
            button.layer.borderColor = UIColor.clearColor().CGColor;
        }
    }

    func displaySearchResult () {
    
    if (searchText == "")  {
    
    return;
    }
    
    if (searchText.containsString("king") || searchText.containsString("library")) {
        
        searchedBuilding = building1
        print(searchedBuilding.name)
       	processSearchResult(searchedBuilding , defaultZoom: false);
    }
        
    else if (searchText.containsString("engineering") || searchText.containsString("engg") || searchText.containsString("building")) {
            
         searchedBuilding = building2
        print(searchedBuilding.name)
        processSearchResult(searchedBuilding , defaultZoom: false);
        }
   
    else if (searchText.containsString("yoshihiro") || searchText.containsString("uchida")) || searchText.containsString("hall") {
        
        searchedBuilding = building3
        print(searchedBuilding.name)
        processSearchResult(searchedBuilding , defaultZoom: false);
        }
        
    else if (searchText.containsString("student") || searchText.containsString("union") || searchText.containsString("su")) {
        
         searchedBuilding = building4
        print(searchedBuilding.name)
        processSearchResult(searchedBuilding , defaultZoom: false);
        }
        
    else if (searchText.containsString("bbc") || searchText.containsString("boccardo") ||
        searchText.containsString("business") || searchText.containsString("center")) {
        
        searchedBuilding = building5
        print(searchedBuilding.name)
        processSearchResult(searchedBuilding , defaultZoom: false);
        }
        
    else if (searchText.containsString("south") || searchText.containsString("parking") ||
        searchText.containsString("garage") ) {
            
            searchedBuilding = building6
            print(searchedBuilding.name)
            processSearchResult(searchedBuilding , defaultZoom: false);
        }
    }
    
    func processSearchResult (building : Building, defaultZoom : Bool) {
        
        print(building.tag)
        let searchedButton : UIButton = self.view.viewWithTag(Int(building.tag)!) as! UIButton;
        searchedButton.layer.borderWidth = 2;
        searchedButton.layer.borderColor = UIColor.blueColor().CGColor
        if (defaultZoom) {
            
            scrollView.scrollRectToVisible(CGRectZero, animated: true);
            scrollView.zoomScale = 1.0;
        } else {
            
            let scrollRect : CGRect = CGRectMake(searchedButton.frame.origin.x-20, searchedButton.frame.origin.y-20, searchedButton.frame.size.width+40, searchedButton.frame.size.height+40)
            scrollView.zoomToRect(scrollRect, animated: true);
        }
    }
    
    func openSettings () {
        
        let stringUrl : String = String(format: "%@BundleID", UIApplicationOpenSettingsURLString);
        let settingsUrl = NSURL(string: stringUrl)
        UIApplication.sharedApplication().openURL(settingsUrl!)
    }
    
    /// Location function
    func didUpdateLocation(location : CLLocationCoordinate2D) {
        currentLocation = location;
        processLocation();
    }
    
    func didFail(error : NSError) {
        let alertController = alertControllerWithMessage("Failed to update location. Enable Location from Settings");
        presentViewController(alertController, animated: true, completion: nil);
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
            
            let alertController = alertControllerWithMessage("Enable Location from Settings");
            let settingsAction = UIAlertAction(title: "Open Settings", style: .Default, handler: { (_) -> Void in
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
    
    func setButtonAppearance (tag : Int) {
        
        let button : UIButton = self.view.viewWithTag(tag) as! UIButton;
        
        button.layer.borderWidth = 2.0;
        button.layer.cornerRadius = 5.0;
        button.layer.borderColor = UIColor.clearColor().CGColor;
        button.transform = CGAffineTransformMakeRotation(5.74213);
    }
    
    func processLocation () {
        
        print(self.contentImageView.frame)
        let userX = Double(self.contentImageView.bounds.height) * (fabs(currentLocation.longitude)-fabs(Constants.SJSU_SW.longitude))/(fabs(Constants.SJSU_NE.longitude)-fabs(Constants.SJSU_SW.longitude));
        let userY = Double(self.contentImageView.bounds.width) - (Double(self.contentImageView.bounds.width) * (fabs(currentLocation.latitude)-fabs(Constants.SJSU_SW.latitude))/(fabs(Constants.SJSU_NE.latitude)-fabs(Constants.SJSU_SW.latitude)));
        let locationPoint : CGPoint = CGPointMake(CGFloat(userX), CGFloat(userY));
        
        displayRedCircleAt(locationPoint);
    }
    
    func displayRedCircleAt(point : CGPoint) {
        
        if let tempView = self.contentImageView.viewWithTag(999) {
            
            tempView.removeFromSuperview();
        }
        
        let xStart : Int = Int(point.x);
        let yStart : Int = Int(point.y);
        
        let outerCircleRect : CGRect = CGRectMake(CGFloat(xStart), CGFloat(yStart), 20, 20);
        print(outerCircleRect)
        let outerCircleView : UIView = UIView(frame: outerCircleRect);
        
        outerCircleView.tag = 999;
        outerCircleView.backgroundColor = UIColor.clearColor();
        outerCircleView.layer.borderWidth = 4.0;
        outerCircleView.layer.borderColor = UIColor.blackColor().CGColor;
        outerCircleView.layer.cornerRadius = 10.0;
        self.contentImageView.addSubview(outerCircleView);
        
        let innerCircleRect : CGRect = CGRectMake(outerCircleView.frame.size.width/2-5, outerCircleView.frame.size.width/2-5, 10, 10);
        
        let innerCircleView : UIView = UIView(frame: innerCircleRect);
        innerCircleView.alpha = 0.75;
        
        innerCircleView.backgroundColor = UIColor.redColor();
        innerCircleView.layer.cornerRadius = 5.0;
        outerCircleView.addSubview(innerCircleView);
    }

}

