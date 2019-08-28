//
//  HelpViewController.swift
//  Swipes
//
//  Created by 马乾亨 on 11/6/19.
//  Copyright © 2019 CS3432. All rights reserved.
//

import UIKit

class HelpTableViewCell: UITableViewCell {
    @IBOutlet weak var label_UI:UILabel!
    @IBOutlet weak var imgButton_UI: UIButton!
    
}

class HelpViewController: UIViewController {
    
    var helpTitle:[String] = ["Open Policies","Known Issues","FAQ","Get Started","Walkthrough","Contact Swipes support@swipesapp.com","User: Is trying out"]
    
    var themeSwitcher = false
    
    
    @IBOutlet weak var titleLabel_UI: UILabel!
    
    @IBOutlet weak var titleUnderLineView_UI: UIView!
    @IBOutlet weak var helpTableView_UI: UITableView!
    @IBOutlet weak var backButton_UI: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeSwitcher = UserDefaults.standard.bool(forKey:"theme")
        
        switch themeSwitcher {
        case true:
            view.backgroundColor = UIColor(named: "DarkColor")
            titleUnderLineView_UI.backgroundColor = UIColor(named: "DarkColor")
            helpTableView_UI.backgroundColor = UIColor(named: "DarkColor")
            
            backButton_UI.tintColor = .white
            
            titleLabel_UI.textColor = .white
        case false:
            titleUnderLineView_UI.backgroundColor = .black
            backButton_UI.tintColor = .black
        }
        
        let email = UserDefaults.standard.string(forKey: "fbEmail") ?? ""
        if email != "" {
            helpTitle[6] = "User: \(email)(Facebook)"
        }
        helpTableView_UI.tableFooterView = UIView()
    }
    
}

extension HelpViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HelpTableViewCell
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width)
        cell.selectedBackgroundView = UIView()
        cell.label_UI.text = helpTitle[indexPath.row]
        if indexPath.row == helpTitle.count - 1 {
            cell.imgButton_UI.isHidden = true
        }else{
            cell.imgButton_UI.isHidden = false
        }
        switch themeSwitcher {
        case true:
            cell.backgroundColor = UIColor(named: "DarkColor")
            cell.selectedBackgroundView?.backgroundColor = UIColor(named: "DarkColor")
            cell.label_UI.backgroundColor = UIColor(named: "DarkColor")
            cell.label_UI.textColor = .white
            cell.imgButton_UI.tintColor = .white
        case false:
            cell.backgroundColor = .white
            cell.label_UI.backgroundColor = .white
            cell.label_UI.textColor = UIColor(named: "DarkColor")
            cell.imgButton_UI.tintColor = UIColor(named: "DarkColor")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let alert = UIAlertController(title: "Policies", message: "Read through our 'Privacy Policy' and 'Terms and conditions'.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Open", style: .default, handler: {(true) in
                let url = URL(string: "https://swipesapp.com/policies.pdf")!
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
            present(alert,animated:true,completion: nil)
        case 1:
            let alert = UIAlertController(title: "Known Issues", message: "You found a bug? Check out if we're already working on it.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Open", style: .default, handler: {(true) in
                let url = URL(string: "https://support.swipesapp.com/hc/en-us/sections/200659851-Known-Issues")!
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
            present(alert,animated:true,completion: nil)
        case 2:
            let alert = UIAlertController(title: "FAQ", message: "Learn how to get most out of the different features in Swipes.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Open", style: .default, handler: {(true) in
                let url = URL(string: "https://support.swipesapp.com/hc/en-us/categories/200368652-FAQ")!
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
            present(alert,animated:true,completion: nil)
        case 3:
            let alert = UIAlertController(title: "Get Started", message: "Learn how to get most out of Swipes.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Open", style: .default, handler: {(true) in
                let url = URL(string: "https://support.swipesapp.com/hc/en-us/sections/200685992-Get-Started")!
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
            present(alert,animated:true,completion: nil)
        case 4:
            break
        case 5:
            break
//            let alert = UIAlertController(title: "Restore Mail", message: "most out of Swipes.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//            alert.addAction(UIAlertAction(title: "Open", style: .default, handler: {(true) in
//                let url = URL(string: "https://support.swipesapp.com/hc/en-us/sections/200685992-Get-Started")!
//                if UIApplication.shared.canOpenURL(url) {
//                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                }
//            }))
//            present(alert,animated:true,completion: nil)
        default:
            break
        }
    }
    
    
}
