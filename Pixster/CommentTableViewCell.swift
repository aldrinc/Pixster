//  CommentTableViewCell.swift
//  Pixster
//
//  Created by Aldrin Clement on 4/15/15.
//  Copyright (c) 2015 Aldrin Clement. All rights reserved.
//

import UIKit
class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var commentText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
