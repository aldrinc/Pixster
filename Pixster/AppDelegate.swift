
//
//  AppDelegate.swift
//  Pixster
//
//  Created by Aldrin Clement on 4/15/15.
//  Copyright (c) 2015 Aldrin Clement. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let navbar = UINavigationBar.appearance()
        navbar.barTintColor = UIColor(red: 255/255, green: 94.0/255, blue: 94.0/255, alpha: 1)
        let font = UIFont(name: "Avenir", size: 18)
        navbar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName: font!]
        navbar.tintColor = UIColor.whiteColor()
        let tabbar = UITabBar.appearance()
        tabbar.barTintColor = UIColor(red: 255/255, green: 94.0/255, blue: 94.0/255, alpha: 1)
        tabbar.tintColor = UIColor.whiteColor()
        let imageView = UIImageView.appearance()
        imageView.layer.borderWidth=1.0
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.whiteColor().CGColor
        imageView.layer.cornerRadius = 200
        imageView.layer.cornerRadius = imageView.frame.size.height/2
        imageView.clipsToBounds = true
        
        //Get the app id and client key from Congig Manager
        Parse.setApplicationId(PixsterConfigManager.sharedInstance.applicationId, clientKey: PixsterConfigManager.sharedInstance.clientKey)
        //Parse.setApplicationId("GzwAWCG4lA16SFhSroj5WfG2FSXix94l9d9cME7i",clientKey: "iDZkU0dFOY8SB9yw7IvblVj1mCE2nAjBm07kPKB0")

        PFUser.enableAutomaticUser()
        PFUser.currentUser().incrementKey("RunCount")
        PFUser.currentUser() ["userID"] = UIDevice.currentDevice().identifierForVendor.UUIDString
        PFUser.currentUser() ["ipAddress"] = getIFAddresses()
        PFUser.currentUser().saveInBackgroundWithBlock(nil)
        Fabric.with([Crashlytics()])
        return true
    }
    func getIFAddresses() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
        if getifaddrs(&ifaddr) == 0 {
            
            // For each interface ...
            for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next) {
                let flags = Int32(ptr.memory.ifa_flags)
                var addr = ptr.memory.ifa_addr.memory
                
                // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                                if let address = String.fromCString(hostname) {
                                    addresses.append(address)
                                }
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return addresses
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

