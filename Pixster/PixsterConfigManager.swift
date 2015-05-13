// PixsterConfigManager.swift
// Pixster
//
// Created by Aldrin Clement on 4/9/15.
// Copyright (c) 2015 Pixster. All rights reserved.
//
//Usage var radius = PixsterConfigManager.sharedInstance.radius

import Foundation

class PixsterConfigManager {
    
    //Set defaults
    var radius:Double = 10
    var applicationId:String = "Undefined"
    var clientKey:String = "Undefined"
    var objectsperpage:UInt = 10
    var locationManager_DesiredAccuracy:Double = 1000
    var parseClassName:String = "PixsterDev"
    var videoMaxDuration:Double = 7
    
    
    class var sharedInstance: PixsterConfigManager {
        struct Static {
            static var instance: PixsterConfigManager?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = PixsterConfigManager()
        }
        
        return Static.instance!
    }
    
    init() {
        // perform some initialization here
        loadConfigData()
    }
    
    
    //Loads the config from propery file
    func loadConfigData() {
        // println("Loading config Data from PixsterConfig.plist")
        // getting path to PixsterConfig.plist
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as String
        let path = documentsDirectory.stringByAppendingPathComponent("PixsterConfig.plist")
        let fileManager = NSFileManager.defaultManager()
        //check if file exists
        if(!fileManager.fileExistsAtPath(path)) {
            // If it doesn't, copy it from the default file in the Bundle
            if let bundlePath = NSBundle.mainBundle().pathForResource("PixsterConfig", ofType: "plist") {
                let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                
                fileManager.copyItemAtPath(bundlePath, toPath: path, error: nil)
                
            } else {
                println("PixsterConfig.plist not found. Please, make sure it is part of the bundle.")
            }
        } else {
            println("PixsterConfig.plist already exits at path.")
            // use this to delete file from documents directory
            //fileManager.removeItemAtPath(path, error: nil)
        }
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        println("Loaded PixsterConfig.plist file is --> \(resultDictionary?.description)")
        var myDict = NSDictionary(contentsOfFile: path)
        if let dict = myDict {
            //loading values
            
            radius = dict.objectForKey("Radius")! as Double
            applicationId = dict.objectForKey("ApplicationId") as String
            clientKey = dict.objectForKey("ClientKey") as String
            objectsperpage = dict.objectForKey("ObjectsPerPage")! as UInt
            locationManager_DesiredAccuracy = dict.objectForKey("LocationManager_DesiredAccuracy")! as Double
            parseClassName = dict.objectForKey("ParseClassName") as String
            //videoMaxDuration = dict.objectForKey("VideoMaxDuration")! as Double
            
        } else {
            println("WARNING: Couldn't create dictionary from PixsterConfig.plist! Default values will be used!")
        }
    }
}