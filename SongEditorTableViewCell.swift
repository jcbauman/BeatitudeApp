//
//  SongEditorTableViewCell.swift
//  Beatitude
//
//  Created by Rocko Bauman on 7/27/18.
//  Copyright © 2018 Pranjal Satija. All rights reserved.
//

import UIKit

class SongEditorTableViewCell: UITableViewCell {
    @IBOutlet weak var albumLogo: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
