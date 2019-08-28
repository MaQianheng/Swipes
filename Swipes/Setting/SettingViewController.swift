//
//  SettingViewController.swift
//  Swipes
//
//  Created by 马乾亨 on 4/5/19.
//  Copyright © 2019 CS3432. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class settingCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgButton_UI: UIButton!
    @IBOutlet weak var label_UI:UILabel!
}

class SettingViewController: UIViewController {
    var email = String()
    var settingTitle = ["Options","Theme","Help","Account"]
    //true:dark,false:not dark
    var themeSwitcher = false
    
    @IBOutlet weak var backButton_UI: UIButton!
    @IBOutlet weak var settingCollectionView_UI: UICollectionView!
    @IBOutlet weak var titleLabel_UI: UILabel!
    @IBOutlet weak var titleUnderLineView_UI: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeSwitcher = UserDefaults.standard.bool(forKey:"theme")
        
        switch themeSwitcher {
        case true:
            view.backgroundColor = UIColor(named: "DarkColor")
            settingCollectionView_UI.backgroundColor = UIColor(named: "DarkColor")
            titleUnderLineView_UI.backgroundColor = .white
            
            backButton_UI.tintColor = UIColor.white
            
            titleLabel_UI.textColor = .white
            
        case false:
            titleUnderLineView_UI.backgroundColor = .black
            backButton_UI.tintColor = .black
        }
        
        email = UserDefaults.standard.string(forKey: "fbEmail") ?? ""
        if email != ""{
            settingTitle[3] = "Log Out"
        }
    }
    
//    @objc func settingButtonTouch(_ sender:UIButton){
//        let tag = sender.tag
//        print(tag)
//    }
    
    
    func GetFBUserData() {
        if FBSDKAccessToken.current() != nil{
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, first_name, last_name, picture.type(large), email"])?.start(completionHandler: { (connection, result, error) -> Void in
                if error == nil{
                    let faceDic = result as! [String:AnyObject]
                    print(faceDic)
                    let email = faceDic["email"] as! String
                    print(email)
                    let id = faceDic["id"] as! String
                    print(id)
                    UserDefaults.standard.set("\(email)", forKey: "fbEmail")
                }
            })
        }
    }
    
}



extension SettingViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settingTitle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! settingCollectionViewCell
        cell.imgButton_UI.setImage(UIImage(named: settingTitle[indexPath.row]), for: .normal)
//        cell.imgButton_UI.addTarget(self, action: #selector(settingButtonTouch(_:)), for: .touchUpInside)
        cell.label_UI.text = settingTitle[indexPath.row]
        switch themeSwitcher {
        case true:
            cell.imgButton_UI.tintColor = .white
            cell.label_UI.textColor = .white
        case false:
            cell.imgButton_UI.tintColor = UIColor(named: "DarkColor")
            cell.label_UI.textColor = UIColor(named: "DarkColor")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = storyboard?.instantiateViewController(withIdentifier: "optionsViewController") as! OptionsViewController
            present(vc,animated: true,completion: nil)
        case 1:
            if UserDefaults.standard.bool(forKey: "theme") == true{
                UserDefaults.standard.set(false, forKey: "theme")
            }else{
                UserDefaults.standard.set(true, forKey: "theme")
            }
            let vc = storyboard?.instantiateViewController(withIdentifier: "viewController") as! ViewController
            present(vc,animated: true,completion: nil)
        case 2:
            let vc = storyboard?.instantiateViewController(withIdentifier: "helpViewController") as! HelpViewController
            present(vc,animated: true,completion: nil)
        case 3:
            email = UserDefaults.standard.string(forKey: "fbEmail") ?? ""
            if email == ""{
                let fbLoginManager:FBSDKLoginManager = FBSDKLoginManager()
                fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
                    if (error == nil){
                        let fbLoginResult:FBSDKLoginManagerLoginResult = result!
                        if fbLoginResult.grantedPermissions != nil{
                            if fbLoginResult.grantedPermissions.contains("email"){
                                self.GetFBUserData()
                                fbLoginManager.logOut()
                            }
                        }
                    }
                    self.settingTitle[3] = "Log Out"
                    self.settingCollectionView_UI.reloadData()
                }
            }else{
                let alertView = UIAlertController(title: "Log out", message: "Are you sure you want to log out of your account?", preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alertView.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
                    UserDefaults.standard.set("", forKey: "fbEmail")
                    self.settingTitle[3] = "Account"
                    self.settingCollectionView_UI.reloadData()
                }))
                present(alertView,animated: true,completion: nil)
            }
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 80)
    }
    
}
