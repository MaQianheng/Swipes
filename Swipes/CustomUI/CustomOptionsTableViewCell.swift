//
//  CustomOptionsTableViewCell.swift
//  Swipes
//
//  Created by 马乾亨 on 6/5/19.
//  Copyright © 2019 CS3432. All rights reserved.
//

import UIKit

class CustomOptionsTableViewCell: UITableViewCell {
    @IBOutlet weak var optionsLable_UI: UILabel!
    @IBOutlet weak var optionsStatus_UI: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        optionsStatus_UI.layer.cornerRadius = 5
        optionsStatus_UI.layer.borderColor = UIColor.black.cgColor
        optionsStatus_UI.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
