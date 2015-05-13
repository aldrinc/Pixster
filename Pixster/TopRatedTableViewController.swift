//
//  TopRatedTableViewController.swift
//  Pixster
//
//  Created by Aldrin Clement on 4/27/15.
//  Copyright (c) 2015 Aldrin Clement. All rights reserved.
//

import UIKit
import CoreLocation
import MediaPlayer
import AVFoundation
import AVKit
import Fabric
import Crashlytics

class TopRatedTableViewController: TableViewController {

     override func queryForTable() -> PFQuery {

        let query = PFQuery(className: "Pixster")

        if let queryLoc = currLocation {
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: queryLoc.latitude, longitude: queryLoc.longitude), withinMiles: radius)
            query.limit = 10;
            query.orderByAscending("count")
        } else {
            /* Decide on how the application should react if there is no location available */
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: 37.411822, longitude: -121.941125), withinMiles: radius)
            query.limit = 10;
            query.orderByAscending("count")
        }
        return query
    }
}

