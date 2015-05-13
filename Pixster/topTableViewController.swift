//
//  topTableViewController.swift
//  Pixster
//
//  Created by Aldrin Clement on 4/29/15.
//  Copyright (c) 2015 Aldrin Clement. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MediaPlayer
import AVFoundation
import AVKit
import Fabric
import Crashlytics

class topTableViewController: PFQueryTableViewController {
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("topCell", forIndexPath: indexPath) as TableViewCell
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
        //Images
        let userImageFile = object.valueForKey("profileImage")? as PFFile
        //Download Image
        userImageFile.getDataInBackgroundWithBlock({ succeeded, error in
            if error == nil {
                let image = UIImage(data:succeeded)
                //cell.parseImage.frame = CGRectMake(8, 10, self.view.frame.size.width - 16, 372)
                cell.parseImage.contentMode = .ScaleAspectFill
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
    

    
    }

