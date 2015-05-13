//  TableViewCell.swift
//  Pixster
//
//  Created by Aldrin Clement on 4/15/15.
//  Copyright (c) 2015 Aldrin Clement. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer
import AVFoundation
import AVKit

class TableViewCell: PFTableViewCell {
    @IBOutlet weak var parseImage: UIImageView!
    @IBOutlet weak var parseText: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var replyCount: UILabel!
    @IBOutlet weak var replyLabel: UILabel!
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
        
        // Configure the view for the selected state
        
        //self.parseImage.contentMode = .ScaleAspectFit
        //self.parseImage.frame = CGRectMake(8, 8, 384, 200)
    }
    
    
}
