//  DetailViewController.swift
//  Pixster
//
//  Created by Aldrin Clement on 4/15/15.
//  Copyright (c) 2015 Aldrin Clement. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation
import AVKit
import MapKit
class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    var pixster: PFObject?
    var commentView: UITextView?
    var footerView: UIView?
    var contentHeight: CGFloat = 0
    var comments: [String]?
    let FOOTERHEIGHT : CGFloat = 50;
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var pixView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pixsterLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Setup the datasource delegate */
        tableView.delegate = self
        tableView.dataSource = self
        /* Setup the keyboard notifications */
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        /* Setup the table cells */
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        /* Make sure the content doesn't go below tabbar/navbar */
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = false
        self.scrollView.scrollEnabled = true
        self.scrollView.frame = CGRectMake(215, 64, 76, 800)
        self.scrollView.contentSize = CGSizeMake(400, 800)
        if(pixster?.objectForKey("comments") != nil) {
            comments = pixster?.objectForKey("comments") as? [String]
        }
      
        self.pixsterLabel.text = pixster?.objectForKey("text") as? String
        var i: AnyObject? = pixster?.valueForKey("profileImage")
        if(i != nil)
        {
            
            let imageFile = pixster?.valueForKey("profileImage") as PFFile
            imageFile.getDataInBackgroundWithBlock({success, error in
                if error == nil {
                    let image = UIImage(data:success)
                    self.pixView.contentMode = .ScaleAspectFit
                    self.pixView.image = image
                }
            })
            
        }
        
        i = pixster?.valueForKey("videoFile")
        
        
        if(i != nil)
        {
            
            let videoFile = pixster?.valueForKey("videoFile") as PFFile
            
            videoFile.getDataInBackgroundWithBlock({success, error in
                let movieURL:NSURL = NSURL(string: videoFile.url)!
                let playerItem = AVPlayerItem(URL: movieURL)
                let player = AVPlayer(playerItem: playerItem)
                player.volume = 1
                let playerController = AVPlayerViewController()
                playerController.view.frame = CGRectMake(0, 0, self.view.bounds.width, self.pixView.bounds.height + 10)
                playerController.videoGravity = AVLayerVideoGravityResizeAspectFill
                playerController.player = player
                self.addChildViewController(playerController)
                self.scrollView.addSubview(playerController.view)
                let sharedInstance = AVAudioSession()
                sharedInstance.setCategory(AVAudioSessionCategoryPlayback, error: nil)
                player.play()
                
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        //super.viewDidAppear(animated)
        self.tableView.reloadData()
        
    }
    func keyBoardWillShow(notification: NSNotification) {
        var info:NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat =  keyboardSize.height
        
        
        var animationDuration:CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as CGFloat
        
        var contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
        
    }
    func keyBoardWillHide(notification: NSNotification) {
        
        self.tableView.contentInset = UIEdgeInsetsZero
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero
    }
    
    func configureTableView() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = comments?.count {
            return count
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as CommentTableViewCell
        cell.contentView.layer.borderWidth = 0.5
        cell.detailTextLabel?.textColor = UIColor.blackColor()
        cell.contentView.layer.backgroundColor = UIColor(red: 197/255, green: 197/255, blue: 197/255, alpha: 0.1).CGColor
        cell.contentView.layer.cornerRadius = 2
        cell.contentView.layer.borderColor = UIColor.darkGrayColor().CGColor
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.commentText?.text = comments![indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.footerView != nil {
            return self.footerView!.bounds.height
        }
        return FOOTERHEIGHT
    }
    
    
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: FOOTERHEIGHT))
        footerView?.backgroundColor = UIColor(red: 243.0/255, green: 243.0/255, blue: 243.0/255, alpha: 1)
        commentView = UITextView(frame: CGRect(x: 10, y: 5, width: tableView.bounds.width - 80 , height: 40))
        commentView?.backgroundColor = UIColor.whiteColor()
        commentView?.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        commentView?.layer.cornerRadius = 2
        commentView?.scrollsToTop = false
        commentView?.autocorrectionType = UITextAutocorrectionType.Default
        
        footerView?.addSubview(commentView!)
        let button = UIButton(frame: CGRect(x: tableView.bounds.width - 65, y: 10, width: 60 , height: 30))
        button.setTitle("Reply", forState: UIControlState.Normal)
        button.backgroundColor = UIColor.grayColor()

        //button.backgroundColor = UIColor(red: 255/255, green: 94.0/255, blue: 94.0/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: "reply", forControlEvents: UIControlEvents.TouchUpInside)
        footerView?.addSubview(button)
        commentView?.delegate = self
        return footerView
    }
    
    func textViewDidChange(textView: UITextView) {
        if (contentHeight == 0) {
            contentHeight = commentView!.contentSize.height
        }
        if(commentView!.contentSize.height != contentHeight && commentView!.contentSize.height > footerView!.bounds.height) {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                let myview = self.footerView
               
                let newHeight : CGFloat = self.commentView!.font.lineHeight
                let myFrame = CGRect(x: myview!.frame.minX, y: myview!.frame.minY - newHeight , width: myview!.bounds.width, height: newHeight + myview!.bounds.height)
                myview?.frame = myFrame
                
                let mycommview = self.commentView
                let newCommHeight : CGFloat = self.commentView!.contentSize.height
                let myCommFrame = CGRect(x: mycommview!.frame.minX, y: mycommview!.frame.minY, width: mycommview!.bounds.width, height: newCommHeight)
                mycommview?.frame = myCommFrame
                
                self.commentView = mycommview
                self.footerView  = myview
                
                for item in self.footerView!.subviews {
                    if(item.isKindOfClass(UIButton.self)){
                        let button = item as UIButton
                        let newY = self.footerView!.bounds.height / 2 - button.bounds.height / 2
                        let buttonFrame = CGRect(x: button.frame.minX, y: newY , width: button.bounds.width, height : button.bounds.height)
                        button.frame = buttonFrame
                    }
                }
            })
            
            
            contentHeight = commentView!.contentSize.height
         
        }
    }
    
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        view.endEditing(true)
        
    }
    func reply() {
        if var tmpText = commentView?.text {
         
            
            if tmpText.isEmpty
            {
                alert("Comments cannot be Empty")
                return
            }
            else{
                
                pixster?.addObject(commentView?.text, forKey: "comments")
                pixster?.saveInBackgroundWithBlock(nil)
                
                
                let toArray = tmpText.componentsSeparatedByString("\n")
                tmpText = join(" ", toArray)
                self.tableView.reloadData()
                
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
                comments?.append(tmpText)
            }
            
            commentView?.text = ""
       
            self.commentView?.resignFirstResponder()
            self.tableView.canBecomeFirstResponder()
            self.tableView.reloadData()
            
            let numberOfSections = tableView.numberOfSections()
            let numberOfRows = tableView.numberOfRowsInSection(numberOfSections-1)
            
            if numberOfRows > 0 {
          
                let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
                
                let delay = 0.1 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                
                dispatch_after(time, dispatch_get_main_queue(), {
                    self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                })
                
                
            }
            
            
        }
    }
    
    //Alert if location cannot be found
    private func alert(message : String) {
        let alert = UIAlertController(title: "Can't do that:", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newLength = countElements(textField.text) + countElements(string) - range.length
        return newLength <= 10 // Bool
    }
    
    func textViewDidEndEditing(textView: UITextView) {
    }
    
    func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.reloadData()
    }
}

//Date Extension to calculate date difference
extension NSDate {
    func yearsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitYear, fromDate: date, toDate: self, options: nil).year
    }
    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitMonth, fromDate: date, toDate: self, options: nil).month
    }
    func weeksFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitWeekOfYear, fromDate: date, toDate: self, options: nil).weekOfYear
    }
    func daysFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitDay, fromDate: date, toDate: self, options: nil).day
    }
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitHour, fromDate: date, toDate: self, options: nil).hour
    }
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitMinute, fromDate: date, toDate: self, options: nil).minute
    }
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitSecond, fromDate: date, toDate: self, options: nil).second
    }
    func offsetFrom(date:NSDate) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}
