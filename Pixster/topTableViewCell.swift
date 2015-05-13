//
//  topTableViewCell.swift
//  Pixster
//
//  Created by Aldrin Clement on 4/29/15.
//  Copyright (c) 2015 Aldrin Clement. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer
import AVFoundation
import AVKit

class topTableViewCell: PFTableViewCell {
   
    
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var topText: UILabel!
    @IBOutlet weak var topTime: UILabel!
    @IBOutlet weak var topLike: UIButton!
    @IBOutlet weak var topCount: UILabel!
    
    @IBOutlet weak var topReport: UIButton!
    
    var player:AVPlayer!
    var movieURL:NSURL!
    var playerController:AVPlayerViewController!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let playerController = AVPlayerViewController()
        player = AVPlayer(URL: movieURL)
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}