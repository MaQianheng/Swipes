//
//  CustomHomeTableViewSectionCell.swift
//  Swipes
//
//  Created by 马乾亨 on 26/5/19.
//  Copyright © 2019 CS3432. All rights reserved.
//

import UIKit

class CustomHomeTableViewSectionCell: UITableViewCell {
    @IBOutlet weak var dateLabel_UI: UILabel!
    @IBOutlet weak var bottomLineView_UI: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
