//
//  TableViewController.swift
//  Pixster
//
//  Created by Aldrin Clement on 4/15/15.
//  Copyright (c) 2015 Aldrin Clement. All rights reserved.
//

import UIKit
import CoreLocation
import MediaPlayer
import AVFoundation
import AVKit
import Fabric
import Crashlytics

class TableViewController: PFQueryTableViewController,CLLocationManagerDelegate,UIScrollViewDelegate {
    var pixs = [""]
    var state = "State"
    var country = "Country"
    let locationManager = CLLocationManager()
    var currLocation : CLLocationCoordinate2D?
    
    //Default config
    var radius:Double = 10
    var locationManager_DesiredAccuracy:Double = 1000
    var movieUrl:NSURL = NSURL()
    var mediaType = 0
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    let loadingView = UIView()
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        self.textKey = "text"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = true
        var objectsPerPage = PixsterConfigManager.sharedInstance.objectsperpage
        self.objectsPerPage = objectsPerPage
        self.infiniteScrolling = true
    
        //Get Configuration
        self.radius = PixsterConfigManager.sharedInstance.radius
        self.parseClassName = PixsterConfigManager.sharedInstance.parseClassName
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 398
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        //Show loading view while loading
        loadingView.backgroundColor = UIColor.whiteColor()
        loadingView.frame = CGRectMake(0, 0, 400, 400)
        self.view.addSubview(loadingView)
        //Add activity indicator
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        self.loadingView.addSubview(activityIndicator)
        self.tableView.contentSize = CGSizeMake(400, 454)
        //Set location manager preferences and request authorization
        locationManager.desiredAccuracy = locationManager_DesiredAccuracy
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if(status == CLAuthorizationStatus.NotDetermined || status == CLAuthorizationStatus.Denied) {
            self.locationManager.requestWhenInUseAuthorization();
        }
        if status == CLAuthorizationStatus.NotDetermined {
            return
        }
        if (status == CLAuthorizationStatus.AuthorizedWhenInUse || status == CLAuthorizationStatus.AuthorizedAlways)
        {
            dispatch_async(dispatch_get_main_queue()) {
                //Need to load twice for it to show up on startuo
                self.loadObjects()
                () }
        }
        else
        {
            SweetAlert().showAlert("Can't find your location", subTitle: "Please enable location services so we can find cool pix around you", style: AlertStyle.None)
        }
    }
    override func objectsDidLoad(error: NSError!) {
        super.objectsDidLoad(error)
        activityIndicator.stopAnimating()
        self.loadingView.hidden = true
        dispatch_async(dispatch_get_main_queue()) {
           self.tableView.reloadData()
            () }
    }

    //Alert if location cannot be found
    private func alert(message : String) {
        let alert = UIAlertController(title: "Oops, something went wrong.", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let settings = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default) { (action) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            return
        }
        alert.addAction(settings)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    override func objectsWillLoad() {
        super.objectsWillLoad()
    }
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    override func viewDidAppear(animated: Bool) {
    }
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 398
    }
    
    func currentTimeMillis() -> Int64{
        var nowDouble = NSDate().timeIntervalSince1970
        return Int64(nowDouble*1000) + Int64(nowDouble/1000)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
      override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName)
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            self.tableView.hidden = false
            if let queryLoc = currLocation {
                query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: queryLoc.latitude, longitude: queryLoc.longitude), withinMiles: radius)
                query.limit = 10;
                query.orderByDescending("createdAt")
            } else {
                /* Decide on how the application should react if there is no location available */
                query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: 37.411822, longitude: -121.941125), withinMiles: radius)
                query.limit = 10;
                query.orderByDescending("createdAt")
            }
            return query
        case 1:
                let query = PFQuery(className: self.parseClassName)
                if let queryLoc = currLocation {
                    query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: queryLoc.latitude, longitude: queryLoc.longitude), withinMiles: 10)
                    query.limit = 10;
                    query.orderByDescending("count")
                } else {
                    /* Decide on how the application should react if there is no location available */
                    query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: 37.411822, longitude: -121.941125), withinMiles: 10)
                    query.limit = 10;
                    query.orderByDescending("count")
                }
                return query
        default:
            break;
        }
        return query
}
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        alert("Cannot fetch your location")
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.stopUpdatingLocation()
        if(locations.count > 0){
            let location = locations[0] as CLLocation
            
            currLocation = location.coordinate
            //Get state
            CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
                if (error != nil) {
                    self.alert("Reverse geocoder failed" + error.localizedDescription)
                    
                    return
                }
                if placemarks.count > 0 {
                    let pm = placemarks[0] as CLPlacemark
                    
                    self.state = pm.administrativeArea
                    
                    var orig_country = pm.country
                    let toArray = orig_country.componentsSeparatedByString(" ")
                    self.country = join("_", toArray)
                    
                    // Later put records in table that is specific to country and state
                    //self.parseClassName = self.country + "_"+self.state
                    //println("ParseClassname :\(self.parseClassName)")
                    
                } else {
                    self.alert("Cannot fetch your location - geocoder error")
                }
            })
        } else {
            alert("Cannot fetch your location")
        }
    }
    override func objectAtIndexPath(indexPath: NSIndexPath!) -> PFObject! {
        var obj : PFObject? = nil
        if(indexPath.row < self.objects.count){
            obj = self.objects[indexPath.row] as? PFObject
        }
        return obj
    }
    func isDBFieldEmpty()
    {
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as TableViewCell
        //Text from User
        cell.parseText.text = object.valueForKey("text") as? String
        cell.parseText.numberOfLines = 1
        //Likes
        let score = object.valueForKey("count") as Int
        cell.count.text = "\(score)"
        //Retrieve date from Parse Servers and display in label
        var dateUpdated = object.createdAt as NSDate
        let currentTime = NSDate()
        let timeDifference = currentTime.offsetFrom(dateUpdated)
        cell.time.text = "\(timeDifference)"
        //Replies
        if(object.valueForKey("comments") != nil) {
            var comments = object.valueForKey("comments") as? [String]
            var repliesCount:Int! = comments?.count
            if repliesCount == 0 {
                cell.replyLabel.text = ""
                cell.replyCount.text = ""
            }
            if repliesCount == 1 {
                cell.replyLabel.text = " reply"
                cell.replyCount.text = "\(repliesCount)"
            }
            if repliesCount > 1 {
            cell.replyLabel.text = "replies"
            cell.replyCount.text = "\(repliesCount)"
            }
        }
        //Images
        let userImageFile = object.valueForKey("profileImage")? as PFFile
        //Download Image
        userImageFile.getDataInBackgroundWithBlock({ succeeded, error in
            if error == nil {
                let image = UIImage(data:succeeded)
                //cell.parseImage.frame = CGRectMake(8, 10, self.view.frame.size.width - 16, 372)
                cell.parseImage.contentMode = .ScaleAspectFit
                cell.parseImage.clipsToBounds = true
                cell.parseImage.image = image
            }
            }, progressBlock: { percent in
                if (self.progressView.progress > 0.99) {
                    self.progressView.hidden = true
                }
                else{
                    self.progressView.hidden = false
                }
                self.progressView.setProgress(Float(percent)/100, animated: true)
                
        })
        return cell
    }
    
    //Like button functionality
    @IBAction func topButton(sender: UIButton) {
        let uuid = UIDevice.currentDevice().identifierForVendor.UUIDString
        let hitPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
        let hitIndex = self.tableView.indexPathForRowAtPoint(hitPoint)
        let object = objectAtIndexPath(hitIndex)
        if object.valueForKey("likedBy") != nil {
            var UUIDarray = object.valueForKey("likedBy")? as NSArray
            var uuidArray:[String] = UUIDarray as [String]
            if !isStringPresentInArray(uuidArray, str: uuid) {
                object.addObject(uuid, forKey: "likedBy")
                object.incrementKey("count")
                object.saveInBackgroundWithBlock(nil)
                let count = object.valueForKey("count") as Int?
                //cell.count.text = "\(count)"
                self.tableView.reloadRowsAtIndexPaths([hitIndex!], withRowAnimation: UITableViewRowAnimation.Fade)
                self.tableView.scrollToRowAtIndexPath(hitIndex!, atScrollPosition: UITableViewScrollPosition.None, animated: false)
            }
        }
    }
    //Check if String is present in Parse
    func isStringPresentInArray(strArray: [String], str: String) -> Bool {
        for currentStr in strArray {
            if (currentStr==str) {
                return true
            }
        }
        return false
    }
    //Show Action Sheet
    @IBAction func moreOptions(sender: AnyObject) {
        let actionSheet = UIAlertController()
        let option0 = UIAlertAction(title: "Report as Inappropriate", style: UIAlertActionStyle.Destructive, handler: {(actionSheet: UIAlertAction!) in (self.reportPostPressed(sender as UIButton))})
        let option1 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(actionSheet: UIAlertAction!) in (self.dismissViewControllerAnimated(true, completion: nil))})
        
        actionSheet.addAction(option0)
        actionSheet.addAction(option1)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    //ReportButton Functionality
    @IBAction func reportPostPressed(sender: UIButton) {
        let actionSheet = UIAlertController(title: "Options", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let option0 = UIAlertAction(title: "Zero", style: UIAlertActionStyle.Default, handler: {(actionSheet: UIAlertAction!) in (self.reportPostPressed(sender))})
        
        
        let uuid = UIDevice.currentDevice().identifierForVendor.UUIDString
        let hitPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
        let hitIndex = self.tableView.indexPathForRowAtPoint(hitPoint)
        let object = objectAtIndexPath(hitIndex)
        
        if object.valueForKey("reportedBy") != nil {
            var UUIDarray = object.valueForKey("reportedBy")? as NSArray
            var uuidArray:[String] = UUIDarray as [String]
            
            if !isStringPresentInArray(uuidArray, str: uuid) {
                object.addObject(uuid, forKey: "reportedBy")
                object.incrementKey("reportCount")
                object.saveInBackgroundWithBlock(nil)
                SweetAlert().showAlert("Reported", subTitle: "Thank you for informing us! We will review this post for inappropriate content and act accordingly.", style: AlertStyle.None)
            }
        }
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {

        dispatch_async(dispatch_get_main_queue()) {
            self.loadObjects()
            () }
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "pixDetail"){
            let indexPath = self.tableView.indexPathForSelectedRow()
            let obj = self.objects[indexPath!.row] as PFObject
            let navVC = segue.destinationViewController as UINavigationController
            let detailVC = navVC.topViewController as DetailViewController
            detailVC.pixster = obj
        }
    }
}

