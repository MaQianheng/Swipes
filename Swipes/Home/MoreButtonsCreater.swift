//
//  KeyboardHandler.swift
//  Swipes
//
//  Created by 马乾亨 on 4/5/19.
//  Copyright © 2019 CS3432. All rights reserved.
//

import Foundation
import UIKit

func moreButtonsShow(trigger:UIButton,animatedObj:[UIButton],animatedAddObj:UIButton) {
    trigger.isSelected = true
    UIView.animate(withDuration: 0.25){
        //逆时针旋转
        trigger.transform = CGAffineTransform(rotationAngle: 45.0).inverted()
    }
    UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
        animatedObj[0].alpha = 1
        animatedObj[0].transform = CGAffineTransform(translationX: 0, y: -120)
        animatedObj[1].alpha = 1
        animatedObj[1].transform = CGAffineTransform(translationX: -50, y: -100)
        animatedObj[2].alpha = 1
        animatedObj[2].transform = CGAffineTransform(translationX: -80, y: -50)
        animatedObj[3].alpha = 1
        animatedObj[3].transform = CGAffineTransform(translationX: -100, y: 0)
        animatedAddObj.alpha = 0
        animatedAddObj.transform = CGAffineTransform(translationX: 0, y: 100)
    }, completion: nil)
}

func moreButtonsHide(trigger:UIButton,animatedObj:[UIButton],animatedAddObj:UIButton) {
    trigger.isSelected = false
    UIView.animate(withDuration: 0.25){
        trigger.transform = CGAffineTransform(rotationAngle: 0.0)
    }
    UIView.animate(withDuration: 0.25){
        animatedObj[0].transform = CGAffineTransform(translationX: 0, y: 0)
        animatedObj[0].alpha = 0
        animatedObj[1].transform = CGAffineTransform(translationX: 0, y: 0)
        animatedObj[1].alpha = 0
        animatedObj[2].transform = CGAffineTransform(translationX: 0, y: 0)
        animatedObj[2].alpha = 0
        animatedObj[3].transform = CGAffineTransform(translationX: 0, y: 0)
        animatedObj[3].alpha = 0
        animatedAddObj.alpha = 1
        animatedAddObj.transform = CGAffineTransform(translationX: 0, y: 0)
    }
}
