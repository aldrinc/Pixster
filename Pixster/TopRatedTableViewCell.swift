//
//  TopRatedTableViewCell.swift
//  Pixster
//
//  Created by Aldrin Clement on 4/28/15.
//  Copyright (c) 2015 Aldrin Clement. All rights reserved.
//

import Foundation
import UIKit
import Foundation
import MediaPlayer
import AVFoundation
import AVKit

class TopRatedTableViewCell: PFTableViewCell {
 
    
    @IBOutlet weak var topRatedParseImage: UIImageView!
    
    @IBOutlet weak var topRatedTextView: UILabel!
    @IBOutlet weak var topRatedLikesCount: UILabel!
    @IBOutlet weak var topRatedLikeBtn: UIButton!
    
    @IBOutlet weak var topRatedTimeStamp: UILabel!
    
    @IBOutlet weak var topRatedMoreOptions: UIButton!
    @IBOutlet weak var topRatedProgressView: UIProgressView!
    
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
