//  PostViewController.swift
//  Pixster
//
//  Created by Aldrin Clement on 4/15/15.
//  Copyright (c) 2015 Aldrin Clement. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices
import AVFoundation
import AVKit
import Foundation
import SystemConfiguration

class PostViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var saveImageButton: UIButton!
    @IBOutlet weak var imageLoading: UIProgressView!
    @IBOutlet weak var parseTestPostView: UITextField!
    @IBOutlet weak var parseImagePostView: UIImageView!
    var currLocation: CLLocationCoordinate2D?
    var reset:Bool = false
    let locationManager = CLLocationManager()
    var mediaURL:NSURL = NSURL()
    private func alert(message : String) {
        let alert = UIAlertController(title: "Error:", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let settings = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default) { (action) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            return
        }
        alert.addAction(settings)
        alert.addAction(action)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.parseTestPostView.delegate = self
        self.parseTestPostView  .becomeFirstResponder()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        /*
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            var photoSelector = UIImagePickerController()
            photoSelector.delegate = self
            photoSelector.sourceType = .Camera
            photoSelector.showsCameraControls = true
            photoSelector.allowsEditing = true
            photoSelector.cropMode = DZNPhotoEditorViewControllerCropMode.Square
            
            photoSelector.mediaTypes = [kUTTypeMovie, kUTTypeImage]
            
            var videoMax = PixsterConfigManager.sharedInstance.videoMaxDuration
            println("Max video duration :\(videoMax)")
            photoSelector.videoMaximumDuration = videoMax
            self.presentViewController(photoSelector, animated: true, completion: nil);
        }
        else{
            var photoSelector = UIImagePickerController()
            photoSelector.delegate = self
            photoSelector.sourceType = .PhotoLibrary
            photoSelector.mediaTypes = [kUTTypeMovie, kUTTypeImage]
            self.presentViewController(photoSelector, animated: true, completion: nil)
        }
*/
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true , completion: nil)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.stopUpdatingLocation()
        if(locations.count > 0){
            let location = locations[0] as CLLocation
            currLocation = location.coordinate
        } else {
            alert("Location cannot be found")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
            }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true , completion: nil)
    }
    
    @IBAction func postPressed(sender: AnyObject) {
        if Reachability.isConnectedToNetwork() == false{
            self.view.endEditing(true)
            SweetAlert().showAlert("No network connection")
            return
        }
        if(currLocation == nil)
        {
            self.view.endEditing(true)
            SweetAlert().showAlert("No Location", subTitle: "Curent Location is empty. Please enable location services", style: AlertStyle.None)
            return
        }
        //Device ID to track likes and reports
        let uuid = UIDevice.currentDevice().identifierForVendor.UUIDString
        
        // get parseClassName from Config
        var parseClassName = PixsterConfigManager.sharedInstance.parseClassName
        let testObject = PFObject(className: parseClassName)
        if (mediaURL.path==nil)
        {
            //Image Post
     
            let imageData = UIImagePNGRepresentation(parseImagePostView.image)
            let imageFile = PFFile(name: "picOne.png", data:imageData)
            testObject["profileImage"] = imageFile
        }
        else
        {
            //Video Post
         
            let videoData = NSData(contentsOfURL: mediaURL)?
            let videoFile = PFFile(name: "video.mov", data: videoData)
            //Generate Thumbnail
            let asset: AVAsset = AVAsset.assetWithURL(mediaURL) as AVAsset
            let imageGenerator = AVAssetImageGenerator(asset: asset);
            imageGenerator.appliesPreferredTrackTransform = true
            let time = CMTimeMakeWithSeconds(1.0, 1)
            var actualTime : CMTime = CMTimeMake(0, 0)
            var error : NSError?
            let thumbnail = imageGenerator.copyCGImageAtTime(time, actualTime: &actualTime, error: &error)
            //Merge PlayButton with Thumbnail
            let backgroundImage = UIImage(CGImage:thumbnail)
            self.parseImagePostView.contentMode = .ScaleAspectFit
            self.parseImagePostView.frame = CGRectMake(8, 150, self.view.frame.size.width - 16, self.view.frame.height - 8)
            self.parseImagePostView.image = backgroundImage
            let playButtonImage = UIImage(named: "PlayButton")
            let newSize = CGSize(width: 400, height: 400)
            UIGraphicsBeginImageContext(newSize)
            backgroundImage?.drawInRect(CGRectMake(0, 0, 400, 400))
            playButtonImage?.drawInRect(CGRectMake(190, 190 , 50, 50))
            let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let mergedData = UIImagePNGRepresentation(newImage)
            let mergedFile = PFFile(name: "picOne.png", data: mergedData)
            testObject["profileImage"] = mergedFile
            testObject["videoFile"] = videoFile
        }
        
        if !(textViewLimit(self.parseTestPostView, shouldChangeCharactersInRange: 35, replacementString: parseTestPostView.text)){
            SweetAlert().showAlert("Maximum characters", subTitle: "Please limit text to 35 characters!", style: AlertStyle.None)
            let button: AnyObject = sender
            return
        }
        if (parseImagePostView.image == nil) {
            self.view.endEditing(true)
            SweetAlert().showAlert("No Media", subTitle: "Please take a photo or video", style: AlertStyle.None)
            return
        }
        testObject["text"] = self.parseTestPostView.text
        testObject["count"] = 0
        testObject["replies"] = 0
        testObject["location"] = PFGeoPoint(latitude: currLocation!.latitude , longitude: currLocation!.longitude)
        testObject["comments"] = []
        testObject["userID"] = uuid
        testObject["likedBy"] = []
        testObject["reportedBy"] = []
        testObject.saveInBackgroundWithBlock(nil)
        self.dismissViewControllerAnimated(true , completion: nil)
        //SweetAlert().showAlert("Posted", subTitle: "Posted it for you! Please wait for a few seconds and Pull to refresh. Like us on Facebook", style: AlertStyle.None)
    }
    func textViewLimit(textView: UITextField!,
        shouldChangeCharactersInRange range: NSRange,
        replacementString string: String!) -> Bool {
            var allowPost = false
            if countElements(self.parseTestPostView.text) < 35 {
                allowPost = true
            }
            return allowPost
    }
    
    @IBAction func openPhotoLibrary(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            var photoSelector = UIImagePickerController()
            photoSelector.delegate = self
            photoSelector.sourceType = .Camera
            photoSelector.showsCameraControls = true
            photoSelector.allowsEditing = true
            photoSelector.cropMode = DZNPhotoEditorViewControllerCropMode.Square
            
            photoSelector.mediaTypes = [kUTTypeImage]
            self.presentViewController(photoSelector, animated: true, completion: nil);
        }
        else{
            var photoSelector = UIImagePickerController()
            photoSelector.delegate = self
            photoSelector.sourceType = .PhotoLibrary
            photoSelector.mediaTypes = [kUTTypeImage]
            self.presentViewController(photoSelector, animated: true, completion: nil)
        }
    }
    
    @IBAction func openVideoCamera(sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            var photoSelector = UIImagePickerController()
            photoSelector.delegate = self
            photoSelector.sourceType = .Camera
            photoSelector.showsCameraControls = true
            photoSelector.allowsEditing = true
            photoSelector.mediaTypes = [kUTTypeMovie]
            var videoMax = PixsterConfigManager.sharedInstance.videoMaxDuration
            println("Max video duration :\(videoMax)")
            photoSelector.videoMaximumDuration = videoMax
            self.presentViewController(photoSelector, animated: true, completion: nil);
        }
        else{
            var photoSelector = UIImagePickerController()
            photoSelector.delegate = self
            photoSelector.sourceType = .PhotoLibrary
            photoSelector.mediaTypes = [kUTTypeMovie]
            self.presentViewController(photoSelector, animated: true, completion: nil)
        }

        
    }
    func scaleImageWith(image:UIImage, and newSize: CGSize) ->UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType] as NSString
        if mediaType.isEqualToString(kUTTypeImage as NSString) {
            let imagePicked:UIImage = info [UIImagePickerControllerEditedImage] as UIImage
            self.dismissViewControllerAnimated(false, completion: nil)
            imageHandler(imagePicked)
        } else if mediaType.isEqualToString(kUTTypeMovie as NSString){
            self.mediaURL = info [UIImagePickerControllerMediaURL] as NSURL
            self.dismissViewControllerAnimated(true, completion: nil)
            videoHandler(mediaURL)
        }
    }
    //Process Images and Persist
    func imageHandler(imagePicked:UIImage){
        let scaledImage = scaleImageWith(imagePicked, and: CGSize(width: imagePicked.size.width, height: imagePicked.size.height))
        parseImagePostView.contentMode = .ScaleAspectFit
        parseImagePostView.image = scaledImage
        //Save Image
        let imageData = UIImagePNGRepresentation(scaledImage)
        let imageFile = PFFile(name: "image.png", data:imageData)
        imageFile.saveInBackgroundWithBlock({imageFile, error in}, progressBlock: {percent in
            self.imageLoading.setProgress(Float(percent)/100, animated: true)
        })
    }
    //Process Videos and persist
    func videoHandler(movieUrl: NSURL) {
        let url:NSURL = movieUrl
        let mediaURL = movieUrl
        let player = AVPlayer(URL: url)
        let playerController = AVPlayerViewController()
        
        
        playerController.view.frame = CGRectMake(0, 157, self.view.frame.width, self.parseImagePostView.frame.height + 10)
        playerController.player = player
        playerController.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.addChildViewController(playerController)
        self.view.addSubview(playerController.view)
        player.play()
        
        //Save video
        let videoData = NSData(contentsOfURL: url)?
        let videoFile = PFFile(name: "video.mov", data: videoData)
        videoFile.saveInBackgroundWithBlock({videoFile, error in
            }, progressBlock: {percent in
                self.imageLoading.setProgress(Float(percent)/100, animated: true)
        })
        
    }
    
    @IBAction func saveMedia(sender: AnyObject) {
        
        if self.parseImagePostView.image != nil {
            self.view.endEditing(true)
            UIImageWriteToSavedPhotosAlbum(self.parseImagePostView.image, SweetAlert().showAlert("Saved", subTitle: "We've saved your photo", style: AlertStyle.None), nil, nil)
        }else if (self.mediaURL.path != nil)
        {
            self.view.endEditing(true)
            UISaveVideoAtPathToSavedPhotosAlbum(self.mediaURL.path,SweetAlert().showAlert("Saved", subTitle: "We've saved your video", style: AlertStyle.None),nil,nil);
            
        }
        else{
            self.view.endEditing(true)
            SweetAlert().showAlert("No Photo or video", subTitle: "Take a photo or video and we'll save it for you!", style: AlertStyle.None)
        }
    }
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        view.endEditing(true)
        
    }
    
}
//Check if network is available
public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            return false
        }
        
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection) ? true : false
    }
    
}

