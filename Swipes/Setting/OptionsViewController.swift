//
//  OptionsViewController.swift
//  Swipes
//
//  Created by 马乾亨 on 6/5/19.
//  Copyright © 2019 CS3432. All rights reserved.
//

import UIKit
import UserNotifications

class OptionsViewController: UIViewController,UNUserNotificationCenterDelegate {
    var selectedOptions:[Bool] = [false,false,false,false,false,false]
    let notificationCenter = UNUserNotificationCenter.current()
    let notificationContent = UNMutableNotificationContent()
    
    var sections:[String] = ["TWEAKS","SOUNDS","NOTIFICATIONS"]
    var sectionOneRows:[String] = ["Add new tasks to bottom","Use standards status bar"]
    var sectionTwoRows:[String] = ["In-app sounds"]
    var sectionThreeRows:[String] = ["Task snoozed for later","Daily reminder to plan the day","Weekly reminder to plan the weak","App permissions"]

    var themeSwitcher = false
    
    @IBOutlet weak var tableView_UI: UITableView!
    @IBOutlet weak var titleLabel_UI: UILabel!
    @IBOutlet weak var backButton_UI: UIButton!
    @IBOutlet weak var titleUnderLineView_UI: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //<<---------Get users defalut options setting---------
        if UserDefaults.standard.data(forKey: "option") == nil {
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: selectedOptions),forKey: "option")
        }else{
            let optionsArrData = UserDefaults.standard.data(forKey: "option")
            do {
                if let loadedOptionsArr = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(optionsArrData!) as? Array<Bool> {
                    selectedOptions = loadedOptionsArr
                }
            } catch {
                print("Couldn't read file.")
            }
            
        }
        themeSwitcher = UserDefaults.standard.bool(forKey:"theme")
        //---------Get users defalut options setting--------->>
        
        switch themeSwitcher {
        case true:
            view.backgroundColor = UIColor(named: "DarkColor")
            tableView_UI.backgroundColor = UIColor(named: "DarkColor")
            titleUnderLineView_UI.backgroundColor = .white
            
            backButton_UI.tintColor = .white
            
            titleLabel_UI.textColor = .white
        case false:
            titleUnderLineView_UI.backgroundColor = .black
            backButton_UI.tintColor = .black
        }
        
        tableView_UI.tableFooterView = UIView()
        
        
        
    }
}

extension OptionsViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        let titleLabel = UILabel(frame: CGRect(x: 16, y: 5, width: tableView.frame.width - 16, height: 20))
        titleLabel.text = "\(sections[section])"
        titleLabel.font=UIFont.boldSystemFont(ofSize: 16)//调整文字为加粗类型
        switch themeSwitcher {
        case true:
            titleLabel.textColor = .white
            view.addBorder(side: .bottom, thickness: 0.5, color: .white)
        case false:
            titleLabel.textColor = UIColor(named: "DarkColor")
            view.addBorder(side: .bottom, thickness: 0.5, color: UIColor(named: "DarkColor")!)
        }
        
        view.addSubview(titleLabel)
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return sectionOneRows.count
        case 1:
            return sectionTwoRows.count
        case 2:
            return sectionThreeRows.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CustomOptionsTableViewCell
        cell!.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell!.bounds.size.width)
        switch indexPath.section {
        case 0:
            cell?.optionsLable_UI.text = sectionOneRows[indexPath.row]
            if indexPath.row == 0 && selectedOptions[0] == true{
                cell?.optionsStatus_UI.backgroundColor = UIColor(named: "CompleteColor")
            }else if indexPath.row == 1 && selectedOptions[1] == true{
                cell?.optionsStatus_UI.backgroundColor = UIColor(named: "CompleteColor")
            }else{
                cell?.optionsStatus_UI.backgroundColor = UIColor.white
            }
        case 1:
            cell?.optionsLable_UI.text = sectionTwoRows[indexPath.row]
            if indexPath.row == 0 && selectedOptions[2] == true{
                cell?.optionsStatus_UI.backgroundColor = UIColor(named: "CompleteColor")
            }else{
                cell?.optionsStatus_UI.backgroundColor = UIColor.white
            }
        case 2:
            cell?.optionsLable_UI.text = sectionThreeRows[indexPath.row]
            if indexPath.row == 0 && selectedOptions[3] == true{
                cell?.optionsStatus_UI.backgroundColor = UIColor(named: "CompleteColor")
            }else if indexPath.row == 1 && selectedOptions[4] == true{
                cell?.optionsStatus_UI.backgroundColor = UIColor(named: "CompleteColor")
            }else if indexPath.row == 2 && selectedOptions[5] == true{
                cell?.optionsStatus_UI.backgroundColor = UIColor(named: "CompleteColor")
            }else{
                cell?.optionsStatus_UI.backgroundColor = UIColor.white
            }
            if indexPath.row == 3{
                cell?.optionsStatus_UI.isHidden = true
            }
        default:
            break
        }
        switch themeSwitcher {
        case true:
            cell?.backgroundColor = UIColor(named: "DarkColor")
            cell?.optionsLable_UI.backgroundColor = UIColor(named: "DarkColor")
            cell?.optionsLable_UI.textColor = .white
        case false:
            cell?.backgroundColor = .white
            cell?.optionsLable_UI.backgroundColor = .white
            cell?.optionsLable_UI.textColor = UIColor(named: "DarkColor")
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case [0,0]:
            if selectedOptions[0] == true{
                selectedOptions[0] = false
            }else{
                selectedOptions[0] = true
            }
        case [0,1]:
            if selectedOptions[1] == true{
                selectedOptions[1] = false
            }else{
                selectedOptions[1] = true
            }
        case [1,0]:
            if selectedOptions[2] == true{
                selectedOptions[2] = false
            }else{
                selectedOptions[2] = true
            }
        case [2,0]:
            if selectedOptions[3] == true{
                selectedOptions[3] = false
            }else{
                selectedOptions[3] = true
            }
        case [2,1]:
            if selectedOptions[4] == true{
                selectedOptions[4] = false
                if let vc = storyboard?.instantiateViewController(withIdentifier: "viewController") as? ViewController{
                    vc.notificationCenter.removePendingNotificationRequests(withIdentifiers: ["daliyReminder"])
                }
            }else{
                selectedOptions[4] = true
                if let vc = storyboard?.instantiateViewController(withIdentifier: "viewController") as? ViewController{
                    vc.notificationContent.title = "Plan your day."
                    vc.notificationContent.sound = .default
                    var dateComponents = DateComponents()
                    dateComponents.hour = 19
                    dateComponents.minute = 00
                    dateComponents.second = 0
                    let trigger = UNCalendarNotificationTrigger( dateMatching: dateComponents, repeats: true)
                    let request = UNNotificationRequest(identifier: "daliyReminder", content: vc.notificationContent, trigger: trigger)
                    vc.notificationCenter.add(request) { (true) in
                        print("registered")
                    }
                }
            }
        case [2,2]:
            if selectedOptions[5] == true{
                selectedOptions[5] = false
                if let vc = storyboard?.instantiateViewController(withIdentifier: "viewController") as? ViewController{
                    vc.notificationCenter.removePendingNotificationRequests(withIdentifiers: ["weeklyReminder"])
                }
            }else{
                selectedOptions[5] = true
                if let vc = storyboard?.instantiateViewController(withIdentifier: "viewController") as? ViewController{
                    vc.notificationContent.title = "Plan your week."
                    vc.notificationContent.sound = .default
                    var dateComponents = DateComponents()
                    dateComponents.hour = 10
                    dateComponents.minute = 00
                    //monday:
                    dateComponents.weekday = 2
                    dateComponents.second = 0
                    let trigger = UNCalendarNotificationTrigger( dateMatching: dateComponents, repeats: true)
                    let request = UNNotificationRequest(identifier: "weeklyReminder", content: vc.notificationContent, trigger: trigger)
                    vc.notificationCenter.add(request) { (true) in
                        print("registered")
                    }
                }
            }
        default:
            break
        }
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: selectedOptions),forKey: "option")
        tableView_UI.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .fade)
        print(selectedOptions)
    }
    
}
