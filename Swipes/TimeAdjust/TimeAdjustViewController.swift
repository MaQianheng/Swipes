//
//  TimeAdjustViewController.swift
//  Swipes
//
//  Created by 马乾亨 on 6/6/19.
//  Copyright © 2019 CS3432. All rights reserved.
//

import UIKit
import UserNotifications

class TimeAdjustViewController: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //Get user's tasks
    var todoTaskContainer:[TodoTask] {
        do{
            return try context.fetch(TodoTask.fetchRequest())
        }catch{
            print("Couldn't fetch data")
        }
        return [TodoTask]()
    }
    
    var laterTaskContainer:[LaterTask]{
        do{
            return try context.fetch(LaterTask.fetchRequest())
        }catch{
            print("Couldn't fetch data")
        }
        return [LaterTask]()
    }
    
    var completeTaskContainer:[CompleteTask]{
        do{
            return try context.fetch(CompleteTask.fetchRequest())
        }catch{
            print("Couldn't fetch data")
        }
        return [CompleteTask]()
    }
    //<<--------------UI--------------
    @IBOutlet weak var scaleImage_UI: UIImageView!
    @IBOutlet weak var confirmButton_UI: UIButton!
    @IBOutlet weak var coverView_UI: UIView!
    @IBOutlet weak var topCoverView_UI: UIImageView!
    
    @IBOutlet weak var dateLabel_UI: UILabel!
    @IBOutlet weak var timeLabel_UI: UILabel!
    
    
    @IBOutlet weak var backButton_UI: UIButton!
    //--------------UI-------------->>
    
    //<<--------------Variable--------------
    var touchDownLocation = CGPoint()
    var movingLocation = CGPoint()
    var flag = Bool()
    var angleArr = [Double]()
    var previousPoint = CGPoint()
    var currentPoint = CGPoint()
    var currentTable = Int()
    var taskTimeStamp = String()
    var taskTime = Int()
    var timeInterval = String()
    var newTimeContainer = timeSlicing()
    var currentTimeContainer = timeSlicing()
    var thisMonthDays = Int()
    var timeAdjustController = Int()
    
    var date = String()
    let weekday = Calendar.current.component(.weekday, from: Date())
    var newWeekDay = Int()
    var weekDayEnglish = String()
    var monthEnglish = String()
    
    var todoSingle: TodoTask?
    var laterSingle: LaterTask?
    var completeSingle: CompleteTask?
    var laterSorting:[LaterTask] = []
    //0:later(+3 hours),1:tomorrow eve(19:00),3:tomorrow(10:00),4:Sunday(sunday 10:00),5:This Weekend(saturday 10:00),6:Next Week(+ 1 week),7:Unspecified:nil,8:Pick A Date
    var adjustTimeType = Int()
    
    var selectedOptions:[Bool] = [false,false,false,false,false,false]
    
    //0:Viewcontroller,1:DetailViewController
    var previousController = Int()
    
    let notificationCenter = UNUserNotificationCenter.current()
    let notificationContent = UNMutableNotificationContent()
    
    var fromDateView = false
    var preTimeContainer = timeSlicing()
    var editingTaskIndex = IndexPath()
    
    var themeSwitcher = false
    //--------------Variable-------------->>
    
    //<<--------------Action--------------
    @IBAction func confirmButton_Action(_ sender: Any) {
        if fromDateView == true {
            switch previousController{
            case 0:
                let vc = storyboard?.instantiateViewController(withIdentifier: "viewController") as! ViewController
                vc.fromTimeAdjustView = true
                vc.selectedTimeContainer = newTimeContainer
                vc.currentTable = currentTable
                vc.editingTaskIndex = editingTaskIndex
                present(vc,animated: true,completion: nil)
                vc.showTimeAdjustCollectionView()
                vc.showCalendarView()
            case 1:
                let vc = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
                vc.fromTimeAdjustView = true
                vc.selectedTimeContainer = newTimeContainer
                vc.currentTable = currentTable
                vc.editingTaskIndex = editingTaskIndex
                switch currentTable{
                case 0:
                    vc.todoSingle = todoSingle
                case 1:
                    vc.laterSingle = laterSingle
                case 2:
                    vc.completeSingle = completeSingle
                default:
                    break
                }
                present(vc,animated: true,completion: nil)
                vc.showTimeAdjustCollectionView()
                vc.showCalendarView()
            default:
                break
            }
        }else{
            laterSorting = laterTaskContainer.sorted(by: { (p1, p2) -> Bool in
                p2.position > p1.position
            })
            var position = Int()
            if self.laterSorting.count == 0{
                position = 0
            }else{
                if self.selectedOptions[0] == false{
                    //Insert at begining
                    position = Int(self.laterSorting[0].position - 1)
                }else{
                    //Append at ending
                    position =  Int(self.laterSorting[self.laterSorting.count-1].position + 1)
                }
            }
            var notificationTitle = String()
            var notificationId = Int32()
            var notificationTimeInterval = Int()
            switch currentTable {
            case 0:
                notificationTitle = todoSingle!.name!
                notificationId = Int32(position)
                notificationTimeInterval = dateToTimeStamp(date: date) - getCurrentStamp()
                let container = LaterTask(context: context)
                container.name = todoSingle?.name
                container.note = todoSingle?.note
                container.repeatInterval = todoSingle?.repeatInterval
                container.status = todoSingle?.status
                container.steps = todoSingle?.steps
                container.tags = todoSingle?.tags
                container.time =  Int32(dateToTimeStamp(date: date))
                container.position = Int32(position)
                let item = todoSingle
                self.context.delete(item!)
            case 1:
                notificationTitle = laterSingle!.name!
                notificationId = Int32(position)
                notificationTimeInterval = dateToTimeStamp(date: date) - getCurrentStamp()
                let item = laterSingle
                item?.time = Int32(dateToTimeStamp(date: date))
                item?.position = Int32(position)
            case 2:
                notificationTitle = completeSingle!.name!
                notificationId = Int32(position)
                notificationTimeInterval = dateToTimeStamp(date: date) - getCurrentStamp()
                let container = LaterTask(context: context)
                container.name = completeSingle?.name
                container.note = completeSingle?.note
                container.repeatInterval = completeSingle?.repeatInterval
                container.status = completeSingle?.status
                container.steps = completeSingle?.steps
                container.tags = completeSingle?.tags
                container.time = Int32(dateToTimeStamp(date: date))
                container.position = Int32(position)
                let item = completeSingle
                self.context.delete(item!)
            default:
                break
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            //<<------------register notification------------
            notificationContent.title = notificationTitle
            notificationContent.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(notificationTimeInterval), repeats: false)
            let request = UNNotificationRequest(identifier: "\(notificationId)", content: notificationContent, trigger: trigger)
            notificationCenter.add(request) { (true) in
                print("registered")
            }
            //------------register notification------------>>
            switch previousController {
            case 0:
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "viewController") as? ViewController{
                    vc.currentTable = 1
                    self.present(vc,animated: true,completion: nil)
                }
            case 1:
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailViewController") as? DetailViewController{
                    laterSorting = laterTaskContainer.sorted(by: { (p1, p2) -> Bool in
                        p2.position > p1.position
                    })
                    if selectedOptions[0] == false{
                        laterSingle = laterSorting[0]
                    }else{
                        laterSingle = laterSorting[laterSorting.count - 1]
                    }
                    vc.currentTable = 1
                    vc.laterSingle = laterSingle
                    let viewController = ViewController()
                    viewController.prepareTodoLaterTask()
                    viewController.setTimerForFirstLaterTask()
                    self.present(vc,animated: true,completion: nil)
                }
            default:
                break
            }
        }
        
    }
    
    @IBAction func bcakButton_Action(_ sender: Any) {
        if fromDateView == true{
            switch previousController{
            case 0:
                let vc = storyboard?.instantiateViewController(withIdentifier: "viewController") as! ViewController
                vc.fromTimeAdjustView = true
                vc.selectedTimeContainer = preTimeContainer
                vc.currentTable = currentTable
                vc.editingTaskIndex = editingTaskIndex
                present(vc,animated: true,completion: nil)
                vc.showTimeAdjustCollectionView()
                vc.showCalendarView()
            case 1:
                let vc = storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
                vc.fromTimeAdjustView = true
                vc.selectedTimeContainer = newTimeContainer
                vc.currentTable = currentTable
                vc.editingTaskIndex = editingTaskIndex
                switch currentTable{
                case 0:
                    vc.currentTable = currentTable
                    vc.todoSingle = todoSingle
                case 1:
                    vc.currentTable = currentTable
                    vc.laterSingle = laterSingle
                case 2:
                    vc.currentTable = currentTable
                    vc.completeSingle = completeSingle
                default:
                    break
                }
                present(vc,animated: true,completion: nil)
                vc.showTimeAdjustCollectionView()
                vc.showCalendarView()
            default:
                break
            }
            
        }else{
            switch previousController {
            case 0:
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "viewController") as? ViewController{
                    switch currentTable{
                    case 0:
                        vc.currentTable = currentTable
                    case 1:
                        vc.currentTable = currentTable
                    case 2:
                        vc.currentTable = currentTable
                    default:
                        break
                    }
                    present(vc,animated: true,completion: nil)
                }
            case 1:
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailViewController") as? DetailViewController{
                    switch currentTable {
                    case 0:
                        vc.currentTable = currentTable
                        vc.todoSingle = todoSingle
                    case 1:
                        vc.currentTable = currentTable
                        vc.laterSingle = laterSingle
                    case 2:
                        vc.currentTable = currentTable
                        vc.completeSingle = completeSingle
                    default:
                        break
                    }
                    present(vc,animated: true,completion: nil)
                    vc.showTimeAdjustCollectionView()
                }
            default:
                break
            }
        }
        
    }
    
    
    //--------------Action-------------->>
    
    //<<--------------viewDidLoad--------------
    override func viewDidLoad() {
        super.viewDidLoad()
        print(currentTable)
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
        themeSwitcher = UserDefaults.standard.bool(forKey: "theme")
        //---------Get users defalut options setting--------->>
        
        switch themeSwitcher {
        case true:
            view.backgroundColor = UIColor(named: "DarkColor")
            
            timeLabel_UI.textColor = .gray
            
            confirmButton_UI.setBackgroundColor(color: UIColor(named: "DarkColor")!, forState: .normal)
            
            confirmButton_UI.tintColor = .white
            backButton_UI.tintColor = .white
            backButton_UI.layer.masksToBounds = true
            backButton_UI.layer.cornerRadius = 17.5
            backButton_UI.layer.borderColor = UIColor.white.cgColor
            backButton_UI.layer.borderWidth = 1.0
            
            scaleImage_UI.backgroundColor = .white
            
            topCoverView_UI.image = UIImage(named: "topCover Dark")
        case false:
            confirmButton_UI.tintColor = .black
            backButton_UI.tintColor = .black
        }
        
        scaleImage_UI.layer.cornerRadius = 150
        scaleImage_UI.layer.borderColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 0.5).cgColor
        scaleImage_UI.layer.borderWidth = 1.0
        
        coverView_UI.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 0.7)
        
        confirmButton_UI.layer.cornerRadius = 75
        
        coverView_UI.setAnchorPoint(anchorPoint: CGPoint(x: 0, y: 1))
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(sender:)))
        coverView_UI.addGestureRecognizer(panGesture)
        
        view.bringSubviewToFront(confirmButton_UI)
        if fromDateView == true{
        }else{
            if todoSingle != nil {
                currentTable = 0
            }else if laterSingle != nil{
                currentTable = 1
            }else{
                currentTable = 2
            }
            
            switch currentTable {
            case 0:
                taskTimeStamp = String(todoSingle!.time)
            case 1:
                taskTimeStamp = String(laterSingle!.time)
            case 2:
                taskTimeStamp = String(completeSingle!.time)
            default:
                break
            }
        }
        
        //handle timeStamp
        newTimeContainer = timeStampSlicing(timeStamp: String(getCurrentStamp()))
        thisMonthDays = daysOfThisMonth(year: Int(newTimeContainer.year)!, month: Int(newTimeContainer.month)!)
        switch adjustTimeType {
            //later 3 hours
        case 0:
            newTimeContainer.hour = String(Int(newTimeContainer.hour)! + 3)
            //如果超出当天24点 天数加一天
            if Int(newTimeContainer.hour)! >= 24{
                //day + 1
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 1)
                //hour to 00˜
                newTimeContainer.hour = String(Int(newTimeContainer.hour)! - 24)
            }
            if Int(newTimeContainer.day)! > thisMonthDays{
                //month + 1
                newTimeContainer.month = String(Int(newTimeContainer.month)! + 1)
                //day to 01
                newTimeContainer.day = String(01)
            }
            //this evening
        case 1:
            if Int(newTimeContainer.hour)! >= 19{
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 1)
                if Int(newTimeContainer.day)! > thisMonthDays{
                    //month + 1
                    newTimeContainer.month = String(Int(newTimeContainer.month)! + 1)
                    //day to 01
                    newTimeContainer.day = String(01)
                }
            }else{
                newTimeContainer.hour = String(19)
                newTimeContainer.minute = String(00)
            }
            
//            timeContainer.day = String(Int(timeContainer.day)! + 1)
//            if Int(timeContainer.day)! > thisMonthDays{
//                //month + 1
//                timeContainer.month = String(Int(timeContainer.month)! + 1)
//                //day to 01
//                timeContainer.day = String(01)
//            }
            //tomorrow
        case 2:
            newTimeContainer.day = String(Int(newTimeContainer.day)! + 1)
            if Int(newTimeContainer.day)! > thisMonthDays{
                //month + 1
                newTimeContainer.month = String(Int(newTimeContainer.month)! + 1)
                //day to 01
                newTimeContainer.day = String(01)
            }
            newTimeContainer.hour = String(10)
            newTimeContainer.minute = String(00)
            //this sunday
        case 3:
            switch weekday{
            case 1:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 7)
            case 2:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 6)
            case 3:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 5)
            case 4:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 4)
            case 5:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 3)
            case 6:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 2)
            case 7:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 1)
            default:
                break
            }
            if Int(newTimeContainer.day)! > thisMonthDays{
                //month + 1
                newTimeContainer.month = String(Int(newTimeContainer.month)! + 1)
                //day to ˜˜
                newTimeContainer.day = String(Int(newTimeContainer.day)! - thisMonthDays)
            }
            newTimeContainer.hour = String(10)
            newTimeContainer.minute = String(00)
            //this weekend(saturday)
        case 4:
            switch weekday{
            case 1:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 6)
            case 2:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 5)
            case 3:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 4)
            case 4:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 3)
            case 5:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 2)
            case 6:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 1)
            case 7:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 7)
            default:
                break
            }
            if Int(newTimeContainer.day)! > thisMonthDays{
                //month + 1
                newTimeContainer.month = String(Int(newTimeContainer.month)! + 1)
                //day to ˜˜
                newTimeContainer.day = String(Int(newTimeContainer.day)! - thisMonthDays)
            }
            newTimeContainer.hour = String(10)
            newTimeContainer.minute = String(00)
            //next week(monday)
        case 5:
            switch weekday{
            case 1:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 1)
            case 2:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 7)
            case 3:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 6)
            case 4:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 5)
            case 5:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 4)
            case 6:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 3)
            case 7:
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 2)
            default:
                break
            }
            if Int(newTimeContainer.day)! > thisMonthDays{
                //month + 1
                newTimeContainer.month = String(Int(newTimeContainer.month)! + 1)
                //day to ˜˜
                newTimeContainer.day = String(Int(newTimeContainer.day)! - thisMonthDays)
            }
            newTimeContainer.hour = String(10)
            newTimeContainer.minute = String(00)
        case 6:
            break
        case 7:
            newTimeContainer.year = preTimeContainer.year
            newTimeContainer.month = preTimeContainer.month
            newTimeContainer.day = preTimeContainer.day
            newTimeContainer.hour = preTimeContainer.hour
            newTimeContainer.minute = preTimeContainer.minute
            newTimeContainer.second = preTimeContainer.second
        default:
            break
        }
        
        if newTimeContainer.month.count < 2 {
            newTimeContainer.month = "0\(newTimeContainer.month)"
        }
        if newTimeContainer.day.count < 2{
            newTimeContainer.day = "0\(newTimeContainer.day)"
        }
        if newTimeContainer.hour.count < 2{
            newTimeContainer.hour = "0\(newTimeContainer.hour)"
        }
        if newTimeContainer.minute.count < 2{
            newTimeContainer.minute = "0\(newTimeContainer.minute)"
        }
        
        //handle Date
        date = "\(newTimeContainer.year)-\(newTimeContainer.month)-\(newTimeContainer.day) \(newTimeContainer.hour):\(newTimeContainer.minute):\(newTimeContainer.second)"
        newWeekDay = Calendar.current.component(.weekday, from: timeStringToDate(date))
        weekDayEnglish = convertEnglishWeekDay(day: newWeekDay)
        monthEnglish = convertEnglishMonth(month: Int(newTimeContainer.month)!)
        dateLabel_UI.text = "\(weekDayEnglish) - \(newTimeContainer.day) \(monthEnglish)"
        timeLabel_UI.text = "\(newTimeContainer.hour):\(newTimeContainer.minute)"
        
    }
    
    
    
    //--------------viewDidLoad-------------->>
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchDownLocation = touch.location(in: self.view)
            flag = true
        }
    }
    
    func angle(start:CGPoint,end:CGPoint)->Double {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let abs_dy = abs(dy);
        //calculate radians
        let theta = atan(abs_dy/dx)
        let mmmm_pie:CGFloat = 3.1415927
        
        //calculate to degrees , some API use degrees , some use radians
        var degrees = (theta * 360/(2*mmmm_pie)) + (dx < 0 ? 180:0)
        
        //transmogrify to negative for upside down angles
        if dy<0 {
            degrees = degrees * -1
        }
        return Double(degrees)
    }
    
    @objc func handlePanGesture(sender:UIPanGestureRecognizer){
        let translation = sender.translation(in: self.view)
        if flag == true {
            timeAdjustController = 0
            angleArr.removeAll()
            previousPoint.x = touchDownLocation.x
            previousPoint.y = touchDownLocation.y
            currentPoint.x = touchDownLocation.x + translation.x
            currentPoint.y = touchDownLocation.y + translation.y
            angleArr.append(angle(start: previousPoint, end: currentPoint))
            angleArr.append(angle(start: previousPoint, end: currentPoint))
            if angleArr[0]>0 {
                timeAdjustController = timeAdjustController - 5
                coverView_UI.transform = coverView_UI.transform.rotated(by: CGFloat(-0.05))
            }else{
                timeAdjustController = timeAdjustController + 5
                coverView_UI.transform = coverView_UI.transform.rotated(by: CGFloat(0.05))
            }
        }else{
            previousPoint.x = currentPoint.x
            previousPoint.y = currentPoint.y
            currentPoint.x = currentPoint.x + translation.x
            currentPoint.y = currentPoint.y + translation.y
            angleArr[0] = angleArr[1]
            angleArr[1] = angle(start: touchDownLocation, end: currentPoint)
            if angleArr[0]>angleArr[1] {
                timeAdjustController = timeAdjustController - 5
                coverView_UI.transform = coverView_UI.transform.rotated(by: CGFloat(-0.05))
            }else{
                timeAdjustController = timeAdjustController + 5
                coverView_UI.transform = coverView_UI.transform.rotated(by: CGFloat(0.05))
            }
        }
        //加时间
        if timeAdjustController == 50 {
            timeAdjustController = 0
            newTimeContainer.minute = String(Int(newTimeContainer.minute)! + 5)
            if Int(newTimeContainer.minute)! >= 60{
                newTimeContainer.hour = String(Int(newTimeContainer.hour)! + 1)
                newTimeContainer.minute = "00"
            }
            if Int(newTimeContainer.hour)! >= 24{
                newTimeContainer.day = String(Int(newTimeContainer.day)! + 1)
                newTimeContainer.hour = "00"
            }
            if Int(newTimeContainer.day)! > daysOfThisMonth(year: Int(newTimeContainer.year)!, month: Int(newTimeContainer.month)!){
                newTimeContainer.month = String(Int(newTimeContainer.month)! + 1)
                newTimeContainer.day = "01"
            }
        }
        //减时间
        else if timeAdjustController == -50{
            currentTimeContainer = timeStampSlicing(timeStamp: String(getCurrentStamp()))
            timeAdjustController = 0
            //如果选择的时间小于当前时间
            if newTimeContainer.month == currentTimeContainer.month&&newTimeContainer.day == currentTimeContainer.day&&newTimeContainer.hour == currentTimeContainer.hour&&Int(newTimeContainer.minute)!-10<=Int(currentTimeContainer.minute)!{
                newTimeContainer.minute = String(Int(currentTimeContainer.minute)! + 5)
                if Int(newTimeContainer.minute)! >= 60{
                    newTimeContainer.hour = String(Int(newTimeContainer.hour)! + 1)
                    newTimeContainer.minute = "00"
                }
                if Int(newTimeContainer.hour)! >= 24{
                    newTimeContainer.day = String(Int(newTimeContainer.day)! + 1)
                    newTimeContainer.hour = "00"
                }
                if Int(newTimeContainer.day)! > daysOfThisMonth(year: Int(newTimeContainer.year)!, month: Int(newTimeContainer.month)!){
                    newTimeContainer.month = String(Int(newTimeContainer.month)! + 1)
                    newTimeContainer.day = "01"
                }
            }else{
                newTimeContainer.minute = String(Int(newTimeContainer.minute)! - 5)
                if Int(newTimeContainer.minute)! <= 0{
                    newTimeContainer.hour = String(Int(newTimeContainer.hour)! - 1)
                    newTimeContainer.minute = "55"
                }
                if Int(newTimeContainer.hour)! < 0{
                    newTimeContainer.day = String(Int(newTimeContainer.day)! - 1)
                    newTimeContainer.hour = "23"
                }
                if Int(newTimeContainer.day)! < 1{
                    newTimeContainer.month = String(Int(newTimeContainer.month)! - 1)
                    newTimeContainer.day = String(daysOfThisMonth(year: Int(newTimeContainer.year)!, month: Int(newTimeContainer.month)!))
                }
            }
        }
                
        if newTimeContainer.month.count < 2 {
            newTimeContainer.month = "0\(newTimeContainer.month)"
        }
        if newTimeContainer.day.count < 2{
            newTimeContainer.day = "0\(newTimeContainer.day)"
        }
        if newTimeContainer.hour.count < 2{
            newTimeContainer.hour = "0\(newTimeContainer.hour)"
        }
        if newTimeContainer.minute.count < 2{
            newTimeContainer.minute = "0\(newTimeContainer.minute)"
        }
        
        //handle Date
        date = "\(newTimeContainer.year)-\(newTimeContainer.month)-\(newTimeContainer.day) \(newTimeContainer.hour):\(newTimeContainer.minute):\(newTimeContainer.second)"
        newWeekDay = Calendar.current.component(.weekday, from: timeStringToDate(date))
        weekDayEnglish = convertEnglishWeekDay(day: newWeekDay)
        monthEnglish = convertEnglishMonth(month: Int(newTimeContainer.month)!)
        dateLabel_UI.text = "\(weekDayEnglish) - \(newTimeContainer.day) \(monthEnglish)"
        timeLabel_UI.text = "\(newTimeContainer.hour):\(newTimeContainer.minute)"
        flag = false
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    

}


extension UIView{
    func setAnchorPoint(anchorPoint: CGPoint) {
        var newPoint = CGPoint(x: self.bounds.size.width * anchorPoint.x, y: self.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: self.bounds.size.width * self.layer.anchorPoint.x, y: self.bounds.size.height * self.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(self.transform)
        oldPoint = oldPoint.applying(self.transform)
        
        var position : CGPoint = self.layer.position
        
        position.x -= oldPoint.x
        position.x += newPoint.x;
        
        position.y -= oldPoint.y;
        position.y += newPoint.y;
        
        self.layer.position = position;
        self.layer.anchorPoint = anchorPoint;
    }
    
    
}
