//
//  customHomeTableViewCell.swift
//  Swipes
//
//  Created by 马乾亨 on 3/5/19.
//  Copyright © 2019 CS3432. All rights reserved.
//

import UIKit

class customHomeTableViewCell: UITableViewCell {
    @IBOutlet weak var point_UI: UIButton!
    @IBOutlet weak var taskLabel_UI: UILabel!
    @IBOutlet weak var selectedView_UI: UIView!
    @IBOutlet weak var tagImg: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var stepsCountLabel_UI: UILabel!
    @IBOutlet weak var noteImg_UI: UIImageView!
    @IBOutlet weak var timeLabel_UI: UILabel!
    @IBOutlet weak var repeatImg_UI: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
