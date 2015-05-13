//
//  topRatedTVC.swift
//  Pixster
//
//  Created by Aldrin Clement on 4/29/15.
//  Copyright (c) 2015 Aldrin Clement. All rights reserved.
//

import Foundation

class topRatedTVC: TableViewController {
    
    override func viewDidLoad(){
    super.viewDidLoad()
    locationManager.startUpdatingLocation()
    //self.loadObjects()
    }
      override func queryForTable() -> PFQuery {
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
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "topPixDetail"){
            let indexPath = self.tableView.indexPathForSelectedRow()
            let obj = self.objects[indexPath!.row] as PFObject
            let navVC = segue.destinationViewController as UINavigationController
            let detailVC = navVC.topViewController as DetailViewController
            detailVC.pixster = obj
        }
    }
    


}
