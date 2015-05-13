//  CommentsTableViewController.swift
//  Pixster
//
//  Created by Aldrin Clement on 4/15/15.
//  Copyright (c) 2015 Aldrin Clement. All rights reserved.
//


import UIKit
import CoreLocation

class CommentsTableViewController: UITableViewController, UITextViewDelegate {
    
    var commentView: UITextView?
    var footerView: UIView?
    var contentHeight: CGFloat = 0
    var pixster: PFObject?
    var comments: [String]?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.None
        
        if(pixster?.objectForKey("comments") != nil) {
            comments = (pixster?.objectForKey("comments") as [String])
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.footerView != nil {
            return self.footerView!.bounds.height
        }
        return 50
    }
    
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
     
        footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
        footerView?.backgroundColor = UIColor(red: 243.0/255, green: 243.0/255, blue: 243.0/255, alpha: 1)
        commentView = UITextView(frame: CGRect(x: 10, y: 5, width: tableView.bounds.width - 80 , height: 40))
        commentView?.backgroundColor = UIColor.whiteColor()
        commentView?.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        commentView?.layer.cornerRadius = 2
        commentView?.scrollsToTop = true
        footerView?.addSubview(commentView!)
        let button = UIButton(frame: CGRect(x: tableView.bounds.width - 65, y: 10, width: 60 , height: 30))
        button.setTitle("Reply", forState: UIControlState.Normal)
        button.backgroundColor = UIColor(red: 155.0/255, green: 189.0/255, blue: 113.0/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: "reply", forControlEvents: UIControlEvents.TouchUpInside)
        footerView?.addSubview(button)
        commentView?.delegate = self
       
        return footerView
    }
    
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
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
    
    func reply() {
  
        pixster?.addObject(commentView?.text, forKey: "comments")
        commentView?.text = ""
        self.commentView?.resignFirstResponder()
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = comments![indexPath.row]
        
        return cell
    }
    
}
