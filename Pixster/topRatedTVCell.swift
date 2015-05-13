//
//  topRatedTVCell.swift
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


class topRatedTVCell: PFTableViewCell {

    @IBOutlet weak var parseImage: UIImageView!
    @IBOutlet weak var parseText: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var count: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      
    }

    
    
}