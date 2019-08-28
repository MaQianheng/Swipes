//
//  ViewController.swift
//  Swipes
//
//  Created by 马乾亨 on 1/5/19.
//  Copyright © 2019 CS3432. All rights reserved.
//

import UIKit
import UserNotifications

class CustomCalendarCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var label_UI:UILabel!
}

class ViewControllerAdjustTimeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var img_UI:UIImageView!
    @IBOutlet weak var label_UI:UILabel!
}

class ViewController: UIViewController,UITextFieldDelegate,UNUserNotificationCenterDelegate {
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
    
    //Get user's tags
    var tags:[Tags]{
        do{
            return try context.fetch(Tags.fetchRequest())
        }catch{
            print("Couldn't fetch data")
        }
        return [Tags]()
    }
    //----------------UI----------------
    @IBOutlet weak var todoTaskNumberLabel_UI: UILabel!
    
    
    @IBOutlet weak var later_UI: UIButton!
    @IBOutlet weak var todo_UI: UIButton!
    @IBOutlet weak var complete_UI: UIButton!
    @IBOutlet weak var tableView_UI: UITableView!
    @IBOutlet weak var add_UI: UIButton!
    @IBOutlet weak var moreFunction_UI: UIButton!
    @IBOutlet weak var multipleView_UI: UIView!
    
    @IBOutlet weak var multipleCancel_UI: UIButton!
    
    @IBOutlet weak var progress_UI: UIProgressView!
    @IBOutlet weak var progressBack_UI: UIView!
    
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.light))
    
    var addTask_txt = UITextField()
    
    var addTag = UIButton(type: .custom)
    
    @IBOutlet weak var multiAll_UI: UIButton!
    
    @IBOutlet weak var multipleFunctionsView_UI: UIView!
    @IBOutlet weak var multipleFunctionsTag_UI: UIButton!
    @IBOutlet weak var multipleFunctionsTrash_UI: UIButton!
    @IBOutlet weak var multipleFunctionsShare_UI: UIButton!
    @IBOutlet weak var multipleFunctionsLabel_UI: UILabel!
    
    
    @IBOutlet weak var searchResultView_UI: UIView!
    @IBOutlet weak var searchResultLabel_UI: UILabel!
    @IBOutlet weak var searchResultClearButton_UI: UIButton!
    
    @IBOutlet weak var tagFilterView_UI: UIView!
    @IBOutlet weak var tagCollectionView_UI: UICollectionView!
    @IBOutlet weak var tagFilterViewTitleLabel_UI: UILabel!
    @IBOutlet weak var tagFilterViewClearButton_UI: UIButton!
    @IBOutlet weak var tagFilterViewDownButton_UI: UIButton!
    
    @IBOutlet weak var searchView_UI: UIView!
    @IBOutlet weak var searchTxt_UI: UITextField!
    @IBOutlet weak var searchViewClearButton_UI: UIButton!
    
    @IBOutlet weak var timeAdjustCollectionView_UI: UICollectionView!
    @IBOutlet weak var timeAdjustLabel_UI: UILabel!
    
    @IBOutlet weak var calendarView_UI: UIView!
    @IBOutlet weak var calendarCollectionView_UI: UICollectionView!
    @IBOutlet weak var calendarViewPreMonthButton_UI: UIButton!
    @IBOutlet weak var calendarViewNextMonthButton_UI: UIButton!
    @IBOutlet weak var calendarViewBackButton_UI: UIButton!
    @IBOutlet weak var calendarViewConfirmButton_UI: UIButton!
    @IBOutlet weak var calendarViewDateButton_UI: UIButton!
    
    //----------------UI----------------
    
    
    
    //----------------Variable----------------
    //Tasks' container
    
    var tagsButtonsContainer:[UIButton] = []
    
    var todoSorting:[TodoTask] = []
    var laterSorting:[LaterTask] = []
    var completeSorting:[CompleteTask] = []
    var todoTaskGroup = [[TodoTask]]()
    var laterTaskGroup = [[LaterTask]]()
    var completeTaskGroup = [[CompleteTask]]()
    var todoDates = [String]()
    var laterDates = [String]()
    var completeDates = [String]()
    
    var todoFiltering = [TodoTask]()
    var laterFiltering = [LaterTask]()
    var completeFiltering = [CompleteTask]()
    
    //currentTable(0:todo,1:later,2:complete)
    var currentTable:Int = 0
    
    //四个功能键
    var moreButtons:[UIButton] = []
    var moreButtonImg:[String] = ["multiple","filter","search","setting"]
    
    var selectedArr = [IndexPath]()
    var selectedFilterTagArr = [Int]()
    var filterText = ""
    var selectedTaskTagArr = [Int]()
    
    var adjustTimeTitleArr:[String] = ["Later +3h","This Evening","Tomorrow","Sunday","This Weekend","Next Week","Unspecified","Pick A Date","5 seconds test"]
    var adjustTimeDarkTitleArr:[String] = ["Later +3h Dark","This Evening Dark","Tomorrow Dark","Sunday Dark","This Weekend Dark","Next Week Dark","Unspecified Dark","Pick A Date Dark","5 seconds test"]
    var selectedOptions:[Bool] = [false,false,false,false,false,false]
    
    var newTimeContainer = timeSlicing()
    var currentTimeContainer = timeSlicing()
    var thisMonthDays = Int()
    let weekday = Calendar.current.component(.weekday, from: Date())
    var date = String()
    var timeDidChange = Bool()
    
    var editingTaskIndex = IndexPath()
    
    let notificationCenter = UNUserNotificationCenter.current()
    let notificationContent = UNMutableNotificationContent()
    var notificationIdArr = [String]()
    
    var timer = Timer()
    
    var selectedTimeContainer = timeSlicing()
    var calendarDayArr = [Int]()
    var preDateIndexPath = IndexPath()
    var fromTimeAdjustView = false
    
    var themeSwitcher = false
    //----------------Variable----------------
    
    
    
    //----------------Action----------------
    //添加任务按钮
    @IBAction func add_Action(_ sender: Any) {
        showAddTaskView()
    }
    
    @IBAction func later_Action(_ sender: Any) {
        selectLater()
    }
    
    @IBAction func todo_Action(_ sender: Any) {
        selectTodo()
    }
    
    @IBAction func complete_Action(_ sender: Any) {
        selectComplete()
    }
    
    //更多功能按钮
    @IBAction func more_Action(_ sender: Any) {
        //收回菜单
        if moreFunction_UI.isSelected == true{
            moreButtonsHide(trigger: moreFunction_UI, animatedObj: moreButtons, animatedAddObj: add_UI)
        }
        //展开菜单
        else{
            moreButtonsShow(trigger: moreFunction_UI, animatedObj: moreButtons, animatedAddObj: add_UI)
        }
    }
    
    //多选按钮-取消
    @IBAction func multiCancel_Action(_ sender: Any) {
        moreButtons[0].isSelected = false
        multiAll_UI.isSelected = false
        UIView.animate(withDuration: 0.25) {
            self.multipleView_UI.transform = self.multipleView_UI.transform.translatedBy(x: 0, y: 50)
            switch self.themeSwitcher{
            case true:
                self.setShadow(view: self.multipleView_UI, width: 0, bColor: UIColor(named: "DarkColor")!, sColor: UIColor(named: "DarkColor")!, offset: CGSize(width: 0.0, height: 0.0), opacity: 0, radius: 0)
            case false:
                self.setShadow(view: self.multipleView_UI, width: 0, bColor: UIColor.white, sColor: UIColor.white, offset: CGSize(width: 0.0, height: 0.0), opacity: 0, radius: 0)
            }
            self.moreFunction_UI.alpha = 1
            self.add_UI.alpha = 1
        }
        if selectedArr.count != 0{
            multipleFunctionsViewHide()
        }
        selectedArr.removeAll()
        performFilter()
    }
    
    //全选按钮-全选
    @IBAction func multiAll_Action(_ sender: Any) {
        if multiAll_UI.isSelected {
            //取消全选
            multiAll_UI.isSelected = false
            selectedArr.removeAll()
            performFilter()
            if selectedArr.count != 0{
                if multipleFunctionsView_UI.isHidden == true{
                    multipleFunctionsViewShow()
                }
            }else{
                multipleFunctionsViewHide()
            }
        }else{
            //全选
            multiAll_UI.isSelected = true
            selectedArr.removeAll()
            selectAllTask()
            
            if selectedArr.count != 0{
                if multipleFunctionsView_UI.isHidden == true{
                    multipleFunctionsViewShow()
                }
            }else{
                multipleFunctionsViewHide()
            }
        }
    }
    
    //多任务删除按钮
    @IBAction func multipleViewTrash_Action(_ sender: Any) {
        if selectedArr.count > 1{
            let title = "Delete \(selectedArr.count) tasks"
            let message = "Are you sure you want to permanently delete these tasks?"
            multipleDeleteAlert(title: title, message: message)
        }else{
            let title = "Delete \(selectedArr.count) task"
            let message = "Are you sure you want to permanently delete this task?"
            multipleDeleteAlert(title: title, message: message)
        }
    }
    
    //多任务分享按钮
    @IBAction func multipleViewShare_Action(_ sender: Any) {
        let activityController: UIActivityViewController
        var str:String = ""
        str = multipleTasksShare()
        activityController = UIActivityViewController(activityItems: [str], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    //search filter clear
    @IBAction func searchClear_Action(_ sender: Any) {
        searchTxt_UI.text = ""
        searchTxt_UI.resignFirstResponder()
        searchTxt_UI.isEnabled = false
        moreButtons[2].isSelected = false
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.frame = CGRect(x: 0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.searchView_UI.transform = self.searchView_UI.transform.translatedBy(x: 0, y: 70)
            self.searchView_UI.alpha = 0
        }) { (true) in
            self.searchView_UI.isHidden = true
        }
        performFilter()
    }
    
    //all filter clear
    @IBAction func filterClear_Action(_ sender: Any) {
        searchTxt_UI.text = ""
        moreButtons[1].isSelected = false
        moreButtons[2].isSelected = false
        selectedFilterTagArr.removeAll()
        tagCollectionView_UI.reloadData()
        searchResultView_UI.isHidden = true
        performFilter()
    }
    
    //tagFilterView下滑
    @IBAction func tagFilterViewDown_Action(_ sender: Any) {
        UIView.animate(withDuration: 0.25) {
            self.tagFilterView_UI.transform = self.tagFilterView_UI.transform.translatedBy(x: 0, y: 120)
        }
    }
    
    //tagFilterView下滑并清除
    @IBAction func tagFilterViewClear_Action(_ sender: Any) {
        if selectedFilterTagArr.count == 0 {
            let alertView = UIAlertController(title: "Workspaces", message: "Set your workspace, select tags and stay focused.", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            present(alertView,animated: true,completion: nil)
        }else{
            selectedFilterTagArr.removeAll()
            tagCollectionView_UI.reloadData()
            UIView.animate(withDuration: 0.25) {
                self.tagFilterView_UI.transform = self.tagFilterView_UI.transform.translatedBy(x: 0, y: 120)
            }
            performFilter()
        }
        moreButtons[1].isSelected = false
    }
    
    @IBAction func calendarViewBackButton_Action(_ sender: Any) {
        hideCalendarView()
    }
    
    @IBAction func calendarViewConfirmButton_Action(_ sender: Any) {
        newTimeContainer = selectedTimeContainer
        updateLaterTask()
        hideCalendarView()
        hideTimeAdjustCollectionView()
    }
    
    @IBAction func calendarViewPreMonth_Action(_ sender: Any) {
        showPreMonthCalendarCollectionView()
    }
    
    @IBAction func calendarViewNextMonth_Action(_ sender: Any) {
        showNextMonthCalendarCollectionView()
    }
    
    @IBAction func calendarViewDateButton_Action(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "timeAdjustViewController") as! TimeAdjustViewController
        vc.preTimeContainer = selectedTimeContainer
        vc.fromDateView = true
        vc.currentTable = currentTable
        vc.editingTaskIndex = editingTaskIndex
        vc.adjustTimeType = 7
        present(vc,animated: false,completion: nil)
    }
    
    
    //----------------Action----------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<laterTaskContainer.count{
            print(laterTaskContainer[i].time)
        }
        
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
        
        //<<---------Theme UI---------
        switch themeSwitcher {
            //dark
        case true:
            view.backgroundColor = UIColor(named: "DarkColor")
            tableView_UI.backgroundColor = UIColor(named: "DarkColor")
            add_UI.tintColor = UIColor.white
            moreFunction_UI.tintColor = UIColor.white
            todoTaskNumberLabel_UI.textColor = UIColor.white
            tagFilterView_UI.backgroundColor = UIColor(named: "DarkColor")
            tagCollectionView_UI.backgroundColor = UIColor(named: "DarkColor")
            tagFilterViewTitleLabel_UI.backgroundColor = UIColor(named: "DarkColor")
            tagFilterViewTitleLabel_UI.textColor = UIColor.white
            tagFilterViewClearButton_UI.tintColor = UIColor.white
            tagFilterViewDownButton_UI.tintColor = UIColor.white
            
            addTask_txt.attributedPlaceholder = NSAttributedString(string: "Add a new task",attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            
            multipleFunctionsView_UI.backgroundColor = UIColor(named: "DarkColor")
            multipleFunctionsTrash_UI.tintColor = UIColor.white
            multipleFunctionsTag_UI.tintColor = UIColor.white
            multipleFunctionsShare_UI.tintColor = UIColor.white
            
            multipleView_UI.backgroundColor = UIColor(named: "DarkColor")
            multipleCancel_UI.tintColor = UIColor.white
            multiAll_UI.tintColor = UIColor(named: "DarkColor")
            multiAll_UI.setTitleColor(UIColor.white, for: .normal)
            multiAll_UI.setTitleColor(UIColor.white, for: .selected)
            multipleFunctionsLabel_UI.textColor = UIColor.white
            
            searchTxt_UI.textColor = UIColor.white
            searchTxt_UI.tintColor = UIColor(named: "DarkColor")
            searchTxt_UI.backgroundColor = UIColor(named: "DarkColor")
            
            searchViewClearButton_UI.tintColor = UIColor.white
            searchTxt_UI.attributedPlaceholder = NSAttributedString(string: "Search",attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            
            searchResultView_UI.backgroundColor = UIColor(named: "DarkColor")
            searchResultLabel_UI.textColor = UIColor.white
            let yourAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20),
                .foregroundColor: UIColor.white,
                .underlineStyle: NSUnderlineStyle.single.rawValue]
            let attributeString = NSMutableAttributedString(string: "clear workspace", attributes: yourAttributes)
            searchResultClearButton_UI.setAttributedTitle(attributeString, for: .normal)
            
            calendarView_UI.backgroundColor = UIColor(named: "DarkColor")
            calendarCollectionView_UI.backgroundColor = UIColor(named: "DarkColor")
            calendarViewBackButton_UI.tintColor = UIColor.white
            calendarViewConfirmButton_UI.tintColor = UIColor.white
            calendarViewPreMonthButton_UI.tintColor = UIColor.white
            calendarViewNextMonthButton_UI.tintColor = UIColor.white
            calendarViewDateButton_UI.setTitleColor(UIColor.white, for: .normal)
            
            timeAdjustCollectionView_UI.backgroundColor = UIColor(red: 27/255, green: 30/255, blue: 34/255, alpha: 1)
            //bright
        case false:
            add_UI.tintColor = UIColor(named: "DarkColor")
            moreFunction_UI.tintColor = UIColor(named: "DarkColor")
            todoTaskNumberLabel_UI.textColor = UIColor(named: "DarkColor")
            
            multipleFunctionsTrash_UI.tintColor = UIColor(named: "DarkColor")
            multipleFunctionsTag_UI.tintColor = UIColor(named: "DarkColor")
            multipleFunctionsShare_UI.tintColor = UIColor(named: "DarkColor")
            
            multiAll_UI.tintColor = UIColor.white
            multiAll_UI.setTitleColor(UIColor(named: "DarkColor"), for: .normal)
            multiAll_UI.setTitleColor(UIColor(named: "DarkColor"), for: .selected)
            
            searchViewClearButton_UI.tintColor = UIColor(named: "DarkColor")
            
            //clearButton underline
            let yourAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20),
                .foregroundColor: UIColor.black,
                .underlineStyle: NSUnderlineStyle.single.rawValue]
            let attributeString = NSMutableAttributedString(string: "clear workspace", attributes: yourAttributes)
            searchResultClearButton_UI.setAttributedTitle(attributeString, for: .normal)
            
            calendarViewBackButton_UI.tintColor = UIColor(named: "DarkColor")
            calendarViewConfirmButton_UI.tintColor = UIColor(named: "DarkColor")
            calendarViewPreMonthButton_UI.tintColor = UIColor(named: "DarkColor")
            calendarViewNextMonthButton_UI.tintColor = UIColor(named: "DarkColor")
            calendarViewDateButton_UI.setTitleColor(UIColor(named: "DarkColor"), for: .normal)
            
            timeAdjustCollectionView_UI.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        }
        //---------Theme UI--------->>
        
        if filterText != "" {
            searchTxt_UI.text = filterText
        }
        
        if notificationIdArr.count != 0 {
            removeNotification(identifiers: notificationIdArr)
            notificationIdArr.removeAll()
        }
        
        notificationCenter.delegate = self
        
        currentTimeContainer = timeStampSlicing(timeStamp: String(getCurrentStamp()))

        //<<---------addTaskButtonUI---------
        add_UI.layer.masksToBounds = true
        add_UI.layer.cornerRadius = 25
        
        //---------addTaskButtonUI--------->>
        
        //<<---------addTask_txt---------
        addTask_txt.frame = CGRect(x: 5.0, y:view.bounds.maxY - 40.0 , width: view.frame.width - 10.0, height: 40.0)
        setShadow(view: tagFilterView_UI, width: 0, bColor: UIColor.white, sColor: UIColor.white, offset: CGSize(width: 0, height: 0), opacity: 0, radius: 0)
        addTask_txt.isHidden = true
        view.addSubview(addTask_txt)
        //---------addTask_txt--------->>
        
        //<<---------blurView---------
        blurView.isHidden = true
        blurView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        let blurViewTap = UITapGestureRecognizer(target: self, action: #selector(blurClick(tap:)))
        blurView.addGestureRecognizer(blurViewTap)
        view.addSubview(blurView)
        //---------blurView--------->>
        
        //<<---------taskButton conerRadius---------
        todo_UI.layer.masksToBounds = true
        todo_UI.layer.cornerRadius = 12.5
        later_UI.layer.masksToBounds = true
        later_UI.layer.cornerRadius = 12.5
        complete_UI.layer.masksToBounds = true
        complete_UI.layer.cornerRadius = 12.5
        //---------taskButton conerRadius--------->>
        
        //<<---------moreFunction_UI conerRadius---------
        moreFunction_UI.layer.masksToBounds = true
        moreFunction_UI.layer.cornerRadius = 25
        //---------moreFunction_UI conerRadius--------->>
        
        //<<---------TextField delegete---------
        searchTxt_UI.delegate = self
        addTask_txt.delegate = self
        //---------TextField delegete--------->>
        
        //<<---------progress_UI---------
        progress_UI.tintColor = UIColor(named: "TodoColor")
        progress_UI.backgroundColor = UIColor.white
        progressBack_UI.backgroundColor = UIColor(named: "TodoColor")
        //---------progress_UI--------->>
        
        //<<---------textField default isEnable---------
        addTask_txt.isEnabled = false
        searchTxt_UI.isEnabled = false
        //---------textField default isEnable--------->>
        
        //<<---------multiAll_UI button---------
        multiAll_UI.setTitle("None", for: .selected)
        multiAll_UI.setTitle("All", for: .normal)
        //---------multiAll_UI button--------->>
        
        //<<---------multiView buttons---------
        setCornerRadios(obj: multipleFunctionsTag_UI, radius: 20, bColor: UIColor.black, bWidth: 1)
        setCornerRadios(obj: multipleFunctionsTrash_UI, radius: 20, bColor: UIColor.black, bWidth: 1)
        setCornerRadios(obj: multipleFunctionsShare_UI, radius: 20, bColor: UIColor.black, bWidth: 1)
        //---------multiView buttons--------->>
        
        //<<---------moreButton---------
        for i in 0..<moreButtonImg.count{
            let button = UIButton(type: .system)
            let buttonWidth:CGFloat = 50.0
            let buttonHeight:CGFloat = 50.0
            button.setImage(UIImage(named: moreButtonImg[i]), for: .normal)
            button.frame = CGRect(x: moreFunction_UI.frame.origin.x, y: moreFunction_UI.frame.origin.y, width: buttonWidth, height: buttonHeight)
            button.alpha = 0
            switch themeSwitcher{
            case true:
                button.tintColor = UIColor.white
            case false:
                button.tintColor = UIColor(named: "DarkColor")
            }
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 25
            moreButtons.append(button)
            view.addSubview(button)
        }
        //---------moreButton--------->>
        
        //<<---------keyboard---------
        let center:NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        //---------keyboard--------->>
        
        //for multiple choice
        moreButtons[0].addTarget(self, action: #selector(multipleClick(button:)), for: .touchUpInside)
        
        //for tag filter
         moreButtons[1].addTarget(self, action: #selector(tagFilterClick(button:)), for: .touchUpInside)
        
        //for search
        moreButtons[2].addTarget(self,action: #selector(searchClick(button:)), for: .touchUpInside)
        searchTxt_UI.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        //for setting
        moreButtons[3].addTarget(self,action: #selector(settingClick(button:)), for: .touchUpInside)
        
        //tagFilterViewClearButton default tint color
        tagFilterViewClearButton_UI.tintColor = UIColor.gray
        
        //<<---------timeAdjustCollectionView_UI---------
        timeAdjustCollectionView_UI.roundCorners([.topLeft,.topRight,.bottomLeft,.bottomRight], radius: 30)
        let timeAdjustLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(timeAdjustLongPressed(sender:)))
        timeAdjustCollectionView_UI.addGestureRecognizer(timeAdjustLongPressRecognizer)
        //---------timeAdjustCollectionView_UI--------->>
        
        performFilter()
        
        updateTaskNumberProgrees()
        
        switch currentTable {
        case 0:
            selectTodo()
        case 1:
            selectLater()
        case 2:
            selectComplete()
        default:
            break
        }
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        setTimerForFirstLaterTask()
//        print("2")
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        setTimerForFirstLaterTask()
//        print("1")
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self,name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.removeObserver(self,name: UIResponder.keyboardWillHideNotification,object: nil)
    }
    
    @objc func blurClick(tap:UITapGestureRecognizer){
        if addTask_txt.isFirstResponder {
            hideAddTaskView()
        }else{
            hideCalendarView()
            hideTimeAdjustCollectionView()
        }
        
    }
    
    @objc func timeAdjustLongPressed(sender:UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizer.State.began{
            let timeAdjustCollectionViewTouchPoint = sender.location(in: self.timeAdjustCollectionView_UI)
            
            if let indexPath = timeAdjustCollectionView_UI.indexPathForItem(at: timeAdjustCollectionViewTouchPoint){
                if indexPath == [0,7]{
                    showCalendarView()
                }else if indexPath == [0,6]{
                    return
                }else{
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "timeAdjustViewController") as? TimeAdjustViewController{
                        vc.adjustTimeType = indexPath.row
                        switch currentTable{
                        case 0:
                            vc.todoSingle = todoTaskGroup[editingTaskIndex.section][editingTaskIndex.row]
                        case 1:
                            vc.laterSingle = laterTaskGroup[editingTaskIndex.section][editingTaskIndex.row]
                        case 2:
                            vc.completeSingle = completeTaskGroup[editingTaskIndex.section][editingTaskIndex.row]
                        default:
                            break
                        }
                        vc.previousController = 0
                        self.present(vc,animated: true,completion: nil)
                    }
                }
                
            }
        }
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        performFilter()
    }
    
    //Multiple select button moreButtons[0]
    @objc func multipleClick(button:UIButton){
        moreButtons[0].isSelected = true
        multipleView_UI.isHidden = false
        switch themeSwitcher {
        case true:
            self.setShadow(view: self.multipleView_UI, width: 3, bColor: UIColor(named: "DarkColor")!, sColor: UIColor.white, offset: CGSize(width: 0, height: -5.0), opacity: 1, radius: 5.5)
        case false:
            self.setShadow(view: self.multipleView_UI, width: 3, bColor: UIColor.white, sColor: UIColor(named: "DarkColor")!, offset: CGSize(width: 0, height: -5.0), opacity: 1, radius: 5.5)
        }
        UIView.animate(withDuration: 0.25) {
            self.multipleView_UI.transform = self.multipleView_UI.transform.translatedBy(x: 0, y: -50)
            self.moreFunction_UI.alpha = 0
        }
        moreButtonsHide(trigger: moreFunction_UI, animatedObj: moreButtons, animatedAddObj: add_UI)
        self.add_UI.alpha = 0
    }
    
    //Tag filter button moreButtons[1]
    @objc func tagFilterClick(button:UIButton){
        tagCollectionView_UI.reloadData()
        if selectedFilterTagArr.count == 0 {
            moreButtons[1].isSelected = false
        }else{
            moreButtons[1].isSelected = true
        }
        tagFilterView_UI.isHidden = false
        tagFilterViewTitleLabel_UI.isHidden = false
        tagFilterViewClearButton_UI.isHidden = false
        tagFilterViewDownButton_UI.isHidden = false
        switch themeSwitcher {
        case true:
            setShadow(view: tagFilterView_UI, width: 1, bColor: UIColor(named: "DarkColor")!, sColor: UIColor.white, offset: CGSize(width: 0.0, height: -5.0), opacity: 1, radius: 5.5)
        case false:
            setShadow(view: tagFilterView_UI, width: 1, bColor: UIColor.white, sColor: UIColor(named: "DarkColor")!, offset: CGSize(width: 0.0, height: -5.0), opacity: 1, radius: 5.5)
        }
        UIView.animate(withDuration: 0.25) {
            self
            .tagFilterView_UI.transform = self.tagFilterView_UI.transform.translatedBy(x: 0, y: -120)
        }
        moreButtonsHide(trigger: moreFunction_UI, animatedObj: moreButtons, animatedAddObj: add_UI)
    }
    
    //Search moreButtons[2]
    @objc func searchClick(button:UIButton){
        searchView_UI.isHidden = false
        searchTxt_UI.isEnabled = true
        moreButtonsHide(trigger: moreFunction_UI, animatedObj: moreButtons, animatedAddObj: add_UI)
        searchTxt_UI.becomeFirstResponder()
        switch themeSwitcher {
        case true:
            setShadow(view: searchTxt_UI, width: 1, bColor: UIColor(named: "DarkColor")!, sColor: UIColor.white, offset: CGSize(width: 0.0, height: -5.0), opacity: 1, radius: 5.5)
        case false:
            setShadow(view: searchTxt_UI, width: 1, bColor: UIColor.white, sColor: UIColor(named: "DarkColor")!, offset: CGSize(width: 0.0, height: -5.0), opacity: 1, radius: 5.5)
        }
        UIView.animate(withDuration: 0.25) {
            self.searchView_UI.transform = self.searchView_UI.transform.translatedBy(x: 0, y: -70)
            self.searchView_UI.alpha = 1
        }
    }
    
    //Setting moreButtons[3]
    @objc func settingClick(button:UIButton){
        moreButtonsHide(trigger: moreFunction_UI, animatedObj: moreButtons, animatedAddObj: add_UI)
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "settingViewController") as? SettingViewController{
            self.present(vc, animated: true, completion: nil)
        }
    }

    
    @objc func keyboardDidShow(notification:Notification){
        let info:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardY:CGFloat = self.view.frame.size.height - keyboardSize.height
        //        let editingTextFieldH:CGFloat! = self.addTask_txt?.bounds.height
        if addTask_txt.isEnabled {
            if addTask_txt.frame.origin.y > keyboardY {
                UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                    self.addTask_txt.frame = CGRect.init(x: self.addTask_txt.frame.origin.x, y: keyboardY - self.addTask_txt.frame.height, width: self.addTask_txt.frame.width, height: self.addTask_txt.frame.height)
                }, completion: nil)
            }
        }
        else if searchTxt_UI.isEnabled{
            if searchView_UI.frame.origin.y > keyboardY {
//                let correctY = keyboardY - self.searchView_UI.frame.height
                let moveY = keyboardY - self.searchView_UI.frame.origin.y + 30
                UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                    self.searchView_UI.transform = self.searchView_UI.transform.translatedBy(x: 0, y: moveY)
                }, completion: nil)
            }
        }
    }
    
    @objc func keyboardWillHide(notification:Notification){
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
    }
    
    @objc func todoPointButtonClick(button:UIButton ){
        button.isSelected = !button.isSelected
        if button.isSelected{
            button.setImage(UIImage(named: "pointClicked"), for: .normal)
        }else{
            button.setImage(UIImage(named: "point"), for: .normal)
        }
    }
    
    @objc func laterPointButtonClick(button:UIButton ){
        button.isSelected = !button.isSelected
        if button.isSelected{
            button.setImage(UIImage(named: "laterPointClicked"), for: .normal)
        }else{
            button.setImage(UIImage(named: "laterPoint"), for: .normal)
        }
    }
    
    @objc func completePointButtonClick(button:UIButton ){
        button.isSelected = !button.isSelected
        if button.isSelected{
            button.setImage(UIImage(named: "completePointClicked"), for: .normal)
        }else{
            button.setImage(UIImage(named: "completePoint"), for: .normal)
        }
    }
    
    func updateFinishedTaskNumber() -> Int {
        var taskNumber = Int()
        let time = timeStampSlicing(timeStamp: String(getCurrentStamp()))
        let startTimeOfToday = dateToTimeStamp(date: "\(time.year)-\(time.month)-\(time.day) 00:00:01")
        let endTimeOfToday = dateToTimeStamp(date: "\(time.year)-\(time.month)-\(time.day) 23:59:59")
        var sorting = completeTaskContainer.sorted { (p1, p2) -> Bool in
            p2.time > p1.time
        }
        for i in 0..<sorting.count{
            if sorting[i].time < endTimeOfToday&&sorting[i].time > startTimeOfToday{
                taskNumber += 1
            }
        }
        return taskNumber
    }
    
    func updateTotalTaskNumber() -> Int{
        var taskNumber = Int()
        let time = timeStampSlicing(timeStamp: String(getCurrentStamp()))
        let startTimeOfToday = dateToTimeStamp(date: "\(time.year)-\(time.month)-\(time.day) 00:00:01")
        let endTimeOfToday = dateToTimeStamp(date: "\(time.year)-\(time.month)-\(time.day) 23:59:59")
        var sorting = laterTaskContainer.sorted { (p1, p2) -> Bool in
            p2.time > p1.time
        }
        for i in 0..<sorting.count{
            if sorting[i].time < endTimeOfToday{
                taskNumber += 1
            }
        }
        var sorting1 = completeTaskContainer.sorted { (p1, p2) -> Bool in
            p2.time > p1.time
        }
        for i in 0..<sorting1.count{
            if sorting1[i].time < endTimeOfToday&&sorting1[i].time > startTimeOfToday{
                taskNumber += 1
            }
        }
        return taskNumber + todoTaskContainer.count
    }
    
    func reloadTodoLaterTask() {
        var todoPosition = [Int32]()
        for i in 0..<todoTaskContainer.count{
            todoPosition.append(todoTaskContainer[i].position)
        }
        todoPosition.sort(by:<)
        var items = [LaterTask]()
        var position = Int()
        if todoPosition.count == 0{
            position = 0
        }else{
            if self.selectedOptions[0] == false{
                //Insert at begining
                position = Int(todoPosition[0] - 1)
            }else{
                //Append at ending
                position =  Int(todoPosition[todoPosition.count - 1] + 1)
            }
        }
        for i in 0..<laterTaskContainer.count{
            if laterTaskContainer[i].time <= getCurrentStamp(){
                let item = laterTaskContainer[i]
                let container = TodoTask(context: context)
                container.name = item.name
                container.note = item.note
                container.repeatInterval = item.repeatInterval
                container.status = item.status
                container.steps = item.steps
                container.tags = item.tags
                container.time = item.time
                container.position = Int32(position)
                items.append(laterTaskContainer[i])
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
        }
        for i in 0..<items.count{
            let item = items[i]
            self.context.delete(item)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
    }

    func prepareTodoLaterTask() {
        todoSorting = todoTaskContainer.sorted(by: { (p1, p2) -> Bool in
            p2.position > p1.position
        })
        laterSorting = laterTaskContainer.sorted(by: { (p1, p2) -> Bool in
            p2.time > p1.time
        })
    }

    func sortTodoTask(){
        if searchTxt_UI.text == ""&&selectedFilterTagArr.count == 0 {
            todoSorting = todoTaskContainer
        }
        todoSorting.sort { (p1, p2) -> Bool in
            return p2.position > p1.position
        }
        var dateSection:[String] = []
        for i in 0..<todoSorting.count{
            dateSection.append(String(todoSorting[i].time))
        }
        
        todoTaskGroup.removeAll()
        for _ in 0..<1{
            var arr:[TodoTask] = []
            for j in 0..<todoSorting.count{
                arr.append(todoSorting[j])
            }
            todoTaskGroup.append(arr)
        }
        //        tableView_UI.reloadData()
    }
    
    func sortLaterTask(){
        if searchTxt_UI.text == ""&&selectedFilterTagArr.count == 0 {
            laterSorting = laterTaskContainer
        }
        laterSorting.sort { (p1, p2) -> Bool in
            return p2.time > p1.time
        }
        
        var unspecifiedLaterTaskArr = [LaterTask]()
        for i in (0..<laterSorting.count).reversed(){
            if laterSorting[i].time == 2147483647{
                unspecifiedLaterTaskArr.append(laterSorting[i])
                laterSorting.remove(at: i)
            }else{
                break
            }
        }
        var dateSection:[String] = []
        for i in 0..<laterSorting.count{
            dateSection.append(String(laterSorting[i].time))
        }
        
        laterTaskGroup.removeAll()
        laterDates = dateGrouping(dtArr: dateSection)
        for i in 0..<laterDates.count{
            var arr:[LaterTask] = []
            for j in 0..<laterSorting.count{
                if timeStampToString(String(laterSorting[j].time)) == laterDates[i]{
                    arr.append(laterSorting[j])
                }
            }
            laterTaskGroup.append(arr)
        }
        
        if unspecifiedLaterTaskArr.count != 0{
            laterDates.append("UNSPECIFIED")
            laterTaskGroup.append(unspecifiedLaterTaskArr)
        }
        
    }
    
    func sortCompleteTask(){
        if searchTxt_UI.text == ""&&selectedFilterTagArr.count == 0 {
            completeSorting = completeTaskContainer
        }
        completeSorting.sort { (p1, p2) -> Bool in
            return p2.position > p1.position
        }
        var dateSection:[String] = []
        for i in 0..<completeSorting.count{
            dateSection.append(String(completeSorting[i].time))
        }
        completeTaskGroup.removeAll()
        completeDates = dateGrouping(dtArr: dateSection)
        completeDates = completeDates.reversed()
        for i in 0..<completeDates.count{
            var arr:[CompleteTask] = []
            for j in 0..<completeSorting.count{
                if timeStampToString(String(completeSorting[j].time)) == completeDates[i]{
                    arr.append(completeSorting[j])
                }
            }
            completeTaskGroup.append(arr)
        }
        //        tableView_UI.reloadData()
    }
    
    func setTimerForRepeatTask() {
        var timerForRepeat = Timer()
        
    }
    
    func setTimerForFirstLaterTask() {
        timer.invalidate()
        var sorting = laterTaskContainer.sorted { (p1, p2) -> Bool in
            p2.time > p1.time
        }
        if laterTaskContainer.count != 0&&sorting[0].time != 0{
            var timeInterval = Int()
            for i in 0..<sorting.count{
                if sorting[i].time != 0{
                    timeInterval = Int(sorting[i].time) - Int(getCurrentStamp())
                    break
                }
            }
            print(timeInterval)
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeInterval), repeats: false) { (true) in
                var position = Int()
                if self.todoTaskContainer.count == 0{
                    position = 0
                }else{
                    var sorting = self.todoTaskContainer.sorted(by: { (p1, p2) -> Bool in
                        p2.position > p1.position
                    })
                    if sorting.count == 0{
                        position = 0
                    }else{
                        if self.selectedOptions[0] == false{
                            //Insert at begining
                            position = Int(sorting[0].position - 1)
                        }else{
                            //Append at ending
                            position =  Int(sorting[sorting.count-1].position + 1)
                        }
                    }
                }
                var sorting = self.laterTaskContainer.sorted(by: { (p1, p2) -> Bool in
                    p2.time > p1.time
                })
                let item = sorting[0]
                let container = TodoTask(context: self.context)
                container.name = item.name
                container.note = item.note
                container.repeatInterval = item.repeatInterval
                container.status = item.status
                container.steps = item.steps
                container.tags = item.tags
                container.time = item.time
                container.position = Int32(position)
                self.context.delete(item)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                if self.tableView_UI != nil{
                    self.performFilter()
                }
//                self.updateTaskNumberProgrees()
                self.setTimerForFirstLaterTask()
            }
        }
    }
    
    func removeNotification(identifiers:[String]) {
        self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //displaying the ios local notification when app is in foreground
        completionHandler([.alert, .badge, .sound])
    }
    
    func addTagButtonClick() {
        var textInput = UITextField()
        let alertView = UIAlertController(title: "Add New tag", message: "Type the name of your tag (ex. work, project or school)", preferredStyle: .alert)
        alertView.addTextField { (TextField) in
            textInput = TextField
        }
        alertView.addAction(UIAlertAction(title: "Cancle", style:.cancel, handler: {
            (alert) in
        }))
        alertView.addAction(UIAlertAction(title: "Add", style: .default, handler: {
            (alert) in
            if let text = textInput.text, text != "" {
                var tagExist = false
                for i in 0..<self.tags.count{
                    if self.tags[i].tags == text{
                        tagExist = true
                        //两个都选中的情况
                        //已经选中的情况 不要重复添加 移除
                        if self.selectedTaskTagArr.contains(i){
                            let index = self.selectedTaskTagArr.firstIndex(of: i)
                            self.selectedTaskTagArr.remove(at: index!)
                        }else{
                            self.selectedTaskTagArr.append(i)
                        }
                        if self.selectedFilterTagArr.contains(i){
                            let index = self.selectedFilterTagArr.firstIndex(of: i)
                            self.selectedFilterTagArr.remove(at: index!)
                        }else{
                            self.selectedFilterTagArr.append(i)
                        }
                        break
                    }
                }
                if tagExist == false{
                    let container = Tags(context: self.context)
                    container.tags = text
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                }
                //sort
                self.selectedTaskTagArr.sort(by:<)
                self.selectedFilterTagArr.sort(by:<)
                self.tagCollectionView_UI.reloadData()
            }
        }))
        present(alertView,animated: true,completion: nil)
    }
    
    func tagCellClick(id:Int,index:Int) -> [Int] {
        var arr = [Int]()
        if id == 0{
            arr = selectedTaskTagArr
        }else{
            arr = selectedFilterTagArr
        }
        //为空->直接添加
        if arr.count == 0 {
            arr.append(index)
        }
        //不为空->判断
        else{
            var flag = true
            for i in 0..<arr.count{
                //selectedTagArr删数据(取消选中)
                if index == arr[i]{
                    arr.remove(at: i)
                    flag = false
                    break
                }else{
                    flag = true
                }
            }
            //selectedArr加数据（选中)
            if flag == true{
                arr.append(index)
            }
            
        }
        return arr
    }
    
    func tagArrayConvertToString() -> String {
        var filterTagName = String()
        for i in 0..<selectedFilterTagArr.count{
            var newStr = String()
            newStr = "\(tags[selectedFilterTagArr[i]].tags!),"
            //最后一个
            if i == selectedFilterTagArr.count - 1{
                newStr = tags[selectedFilterTagArr[i]].tags!
            }
            filterTagName = filterTagName + newStr
        }
        return filterTagName
    }
    
    func performFilter() {
        let searchText = searchTxt_UI.text
        //-----------Variable-----------
        //Signal: 0 -> search, 1 -> tag, 2 -> search + tag
        var signal = Int()
        var taskNumber = Int()
        var filterTaskName = String()
        var filterTagName = String()
        //-----------Variable-----------
        
        filterTaskName = searchTxt_UI.text!
        filterTagName = tagArrayConvertToString()
        //1.text = "!!!",tag = ""
        if let searchText = searchText, searchText != ""&&selectedFilterTagArr.count == 0 {
            searchResultView_UI.isHidden = false
            signal = 0
            todoSorting = todoTaskContainer.filter({ (task) -> Bool in
                return (task.name?.lowercased().contains(searchText.lowercased()))!
            })
            laterSorting = laterTaskContainer.filter({ (task) -> Bool in
                return (task.name?.lowercased().contains(searchText.lowercased()))!
            })
            completeSorting = completeTaskContainer.filter({ (task) -> Bool in
                return (task.name?.lowercased().contains(searchText.lowercased()))!
            })
        }
        //2.text = "", tag = "!!!"
        else if searchTxt_UI.text == ""&&selectedFilterTagArr.count != 0{
            searchResultView_UI.isHidden = false
            signal = 1
            todoSorting = todoTaskContainer
            laterSorting = laterTaskContainer
            completeSorting = completeTaskContainer
            for i in 0..<selectedFilterTagArr.count{
                todoSorting = todoSorting.filter({ (task) -> Bool in
                    return ((task.tags?.contains(tags[selectedFilterTagArr[i]].tags!))!)
                })
            }
            for i in 0..<selectedFilterTagArr.count{
                laterSorting = laterSorting.filter({ (task) -> Bool in
                    return ((task.tags?.contains(tags[selectedFilterTagArr[i]].tags!))!)
                })
            }
            for i in 0..<selectedFilterTagArr.count{
                completeSorting = completeSorting.filter({ (task) -> Bool in
                    return ((task.tags?.contains(tags[selectedFilterTagArr[i]].tags!))!)
                })
            }
        }
        //3.text = "!!!", tag = "!!!"
        else if searchTxt_UI.text != ""&&selectedFilterTagArr.count != 0{
            searchResultView_UI.isHidden = false
            signal = 2
            todoSorting = todoTaskContainer
            laterSorting = laterTaskContainer
            completeSorting = completeTaskContainer
            for i in 0..<selectedFilterTagArr.count{
                todoSorting = todoSorting.filter({ (task) -> Bool in
                    return ((task.tags?.contains(tags[selectedFilterTagArr[i]].tags!))!&&(task.name?.lowercased().contains(searchText!.lowercased()))!)
                })
            }
            for i in 0..<selectedFilterTagArr.count{
                laterSorting = laterSorting.filter({ (task) -> Bool in
                    return ((task.tags?.contains(tags[selectedFilterTagArr[i]].tags!))!&&(task.name?.lowercased().contains(searchText!.lowercased()))!)
                })
            }
            for i in 0..<selectedFilterTagArr.count{
                completeSorting = completeSorting.filter({ (task) -> Bool in
                    return ((task.tags?.contains(tags[selectedFilterTagArr[i]].tags!))!&&(task.name?.lowercased().contains(searchText!.lowercased()))!)
                })
            }
        }
        //4.text = "",tag = ""
        else{
            searchResultView_UI.isHidden = true
            todoSorting = todoTaskContainer
            laterSorting = laterTaskContainer
            completeSorting = completeTaskContainer
        }
        if todo_UI.isSelected {
            taskNumber = todoSorting.count
        }else if later_UI.isSelected{
            taskNumber = laterSorting.count
        }else{
            taskNumber = completeSorting.count
        }
        
        filterResultLabelText(taskNumber: taskNumber, signal: signal,filterTaskName: filterTaskName, filterTagName: filterTagName)
        sortTodoTask()
        sortLaterTask()
        sortCompleteTask()
        tableView_UI.reloadData()
    }
    
    func filterResultLabelText(taskNumber:Int,signal:Int,filterTaskName:String,filterTagName:String) {
        var searchFilterString = String()
        var tagFilterString = String()
        var searchAndTagFilterString = String()
        
        if taskNumber > 1{
            searchFilterString = "\(taskNumber) current tasks matching \"\(filterTaskName)\""
            tagFilterString = "\(taskNumber) current tasks matching tags \(filterTagName)"
            searchAndTagFilterString = "\(taskNumber) current tasks matching \"\(filterTaskName)\" and tags: \(filterTagName)"
        }else{
            searchFilterString = "\(taskNumber) current task matching \"\(filterTaskName)\""
            tagFilterString = "\(taskNumber) current task matching tags \(filterTagName)"
            searchAndTagFilterString = "\(taskNumber) current task matching \"\(filterTaskName)\" and tags: \(filterTagName)"
        }
        
        let startingPositionOfTaskNumber = 0
        let lengthOfTaskNumber = String(taskNumber).count
        let lengthOfFilterTaskName = filterTaskName.count
        let lengthOfFilterTagName = filterTagName.count
        let normalFontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
        
        switch signal {
        case 0:
            let attributedString = NSMutableAttributedString(string: searchFilterString, attributes: normalFontAttributes)
            let startingPositionOfFilterTaskName = searchFilterString.count - lengthOfFilterTaskName - 1
            //bold taskNumber
            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 17), range: NSRange(location:startingPositionOfTaskNumber,length:lengthOfTaskNumber))
            //bold filterTaskName
            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 17), range: NSRange(location:startingPositionOfFilterTaskName,length:lengthOfFilterTaskName))
            searchResultLabel_UI.attributedText = attributedString
        case 1:
            let attributedString = NSMutableAttributedString(string: tagFilterString, attributes: normalFontAttributes)
            let startPositionOfFilterTagName = tagFilterString.count - lengthOfFilterTagName
            //bold taskNumber
            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 17), range: NSRange(location:startingPositionOfTaskNumber,length:lengthOfTaskNumber))
            //bold filterTagName
            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 17), range: NSRange(location:startPositionOfFilterTagName,length:lengthOfFilterTagName))
            searchResultLabel_UI.attributedText = attributedString
        case 2:
            let attributedString = NSMutableAttributedString(string: searchAndTagFilterString, attributes: normalFontAttributes)
            let startingPositionOfFilterTaskName = searchFilterString.count - lengthOfFilterTaskName - 1
            let startingPositionOfFilterTagName = searchFilterString.count + 11
            //bold taskNumber
            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 17), range: NSRange(location:startingPositionOfTaskNumber,length:lengthOfTaskNumber))
            //bold filterTaskName
            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 17), range: NSRange(location:startingPositionOfFilterTaskName,length:lengthOfFilterTaskName))
            //bold filterTagName
           attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 17), range: NSRange(location:startingPositionOfFilterTagName,length:lengthOfFilterTagName))
            searchResultLabel_UI.attributedText = attributedString
        default:
            searchResultLabel_UI.text = ""
        }
    }
    
    
    //true:insert,false:append
    func positionOfLaterTask(bool:Bool) -> Int32 {
        var arr = [Int32]()
        for i in 0..<laterTaskContainer.count{
            arr.append(laterTaskContainer[i].position)
        }
        arr.sort(by:<)
        if laterTaskContainer.count == 0{
            return 0
        }else{
            if bool == true {
                return arr[0]
            }else{
                return arr[arr.count - 1]
            }
        }
    }
    
    //*!!!*
    func selectAllTask() {
        //section
        if todo_UI.isSelected{
            for i in 0..<todoTaskGroup.count{
                for j in 0..<todoTaskGroup[i].count{
                    selectedArr.append(IndexPath(row: j, section: i))
                    self.tableView_UI.reloadRows(at: [IndexPath(row: j, section: i)], with: .fade)
                }
            }
        }else if later_UI.isSelected{
            for i in 0..<laterDates.count{
                for j in 0..<laterTaskGroup[i].count{
                    selectedArr.append(IndexPath(row: j, section: i))
                    self.tableView_UI.reloadRows(at: [IndexPath(row: j, section: i)], with: .fade)
                }
            }
        }else{
            for i in 0..<completeDates.count{
                for j in 0..<completeTaskGroup[i].count{
                    selectedArr.append(IndexPath(row: j, section: i))
                    self.tableView_UI.reloadRows(at: [IndexPath(row: j, section: i)], with: .fade)
                }
            }
        }
    }
    
    func multipleTasksShare() -> String {
        var str:String = "Tasks:\n"
        //selectedArr -> [[0,1][0,2]]
        if todo_UI.isSelected {
            for i in 0..<selectedArr.count{
                let section = selectedArr[i][0]
                let row = selectedArr[i][1]
                let name = "\(todoTaskGroup[section][row].name ?? "-")\n"
                str = str+name
            }
        }else if later_UI.isSelected{
            for i in 0..<selectedArr.count{
                let section = selectedArr[i][0]
                let row = selectedArr[i][1]
                let name = "\(laterTaskGroup[section][row].name ?? "-")\n"
                str = str+name
            }
        }else{
            for i in 0..<selectedArr.count{
                let section = selectedArr[i][0]
                let row = selectedArr[i][1]
                let name = "\(completeTaskGroup[section][row].name ?? "-")\n"
                str = str+name
            }
        }
        return str
    }
    
    func multipleDeleteAlert(title:String,message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            (alert) in
            if self.todo_UI.isSelected {
                for i in 0..<self.selectedArr.count{
//                    let section = self.selectedArr[i][0]
                    let row = self.selectedArr[i][1]
                    let item = self.todoSorting[row]
                    //                        deleteArr.append(item)
                    self.context.delete(item)
                }
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }else if self.later_UI.isSelected{
                for i in 0..<self.selectedArr.count{
                    let section = self.selectedArr[i][0]
                    let row = self.selectedArr[i][1]
                    let item = self.laterTaskGroup[section][row]
                    self.notificationIdArr.append(String(self.laterTaskGroup[section][row].position))
                    self.context.delete(item)
                }
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }else{
                for i in 0..<self.selectedArr.count{
                    let section = self.selectedArr[i][0]
                    let row = self.selectedArr[i][1]
                    let item = self.completeTaskGroup[section][row]
                    //                        deleteArr.append(item)
                    self.context.delete(item)
                }
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
            }
            self.performFilter()
            self.selectedArr.removeAll()
            
            if self.notificationIdArr.count != 0{
                self.removeNotification(identifiers: self.notificationIdArr)
                self.notificationIdArr.removeAll()
                self.setTimerForFirstLaterTask()
            }
            if self.selectedArr.count != 0{
                if self.multipleFunctionsView_UI.isHidden == true{
                    self.multipleFunctionsViewShow()
                }
            }else{
                self.multipleFunctionsViewHide()
            }
            self.updateTaskNumberProgrees()
            
        }))
        present(alert, animated: true)
    }
    
    func multipleFunctionsViewShow() {
        multipleFunctionsView_UI.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.multipleFunctionsView_UI.transform = self.multipleFunctionsView_UI.transform.translatedBy(x: 0, y: -120)
        }
    }
    
    func multipleFunctionsViewHide() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.multipleFunctionsView_UI.transform = self.multipleFunctionsView_UI.transform.translatedBy(x: 0, y: 120)
        }) { (true) in
            self.multipleFunctionsView_UI.isHidden = true
        }
    }
    
    func updateTaskNumberProgrees() {
        todoTaskNumberLabel_UI.text = "\(updateFinishedTaskNumber())/\(updateTotalTaskNumber()) TODAY"
        if todo_UI.isSelected{
            UIView.animate(withDuration: 0.25) {
                self.progress_UI.progress = Float(self.updateFinishedTaskNumber())/Float(self.updateTotalTaskNumber())
            }
        }
    }
    
    func selectTodo() {
        if todo_UI.isSelected == false {
            currentTable = 0
            if searchTxt_UI.text != ""&&selectedFilterTagArr.count == 0{
                filterResultLabelText(taskNumber: todoSorting.count, signal: 0, filterTaskName: searchTxt_UI.text ?? "-", filterTagName: tagArrayConvertToString())
            }else if searchTxt_UI.text == ""&&selectedFilterTagArr.count != 0{
                filterResultLabelText(taskNumber: todoSorting.count, signal: 1, filterTaskName: searchTxt_UI.text ?? "-", filterTagName: tagArrayConvertToString())
            }else if searchTxt_UI.text != ""&&selectedFilterTagArr.count != 0{
                filterResultLabelText(taskNumber: todoSorting.count, signal: 2, filterTaskName: searchTxt_UI.text ?? "-", filterTagName: tagArrayConvertToString())
            }
            todo_UI.isSelected = true
            later_UI.isSelected = false
            complete_UI.isSelected = false
            progress_UI.tintColor = UIColor(named: "TodoColor")
            progress_UI.backgroundColor = UIColor.white
            progressBack_UI.backgroundColor = UIColor(named: "TodoColor")
            updateTaskNumberProgrees()
            selectedArr.removeAll()
            multiAll_UI.isSelected = false
            self.performFilter()
        }
    }
    
    func selectLater() {
        if later_UI.isSelected == false {
            currentTable = 1
            if searchTxt_UI.text != ""&&selectedFilterTagArr.count == 0{
                filterResultLabelText(taskNumber: laterSorting.count, signal: 0, filterTaskName: searchTxt_UI.text ?? "-", filterTagName: tagArrayConvertToString())
            }else if searchTxt_UI.text == ""&&selectedFilterTagArr.count != 0{
                filterResultLabelText(taskNumber: laterSorting.count, signal: 1, filterTaskName: searchTxt_UI.text ?? "-", filterTagName: tagArrayConvertToString())
            }else if searchTxt_UI.text != ""&&selectedFilterTagArr.count != 0{
                filterResultLabelText(taskNumber: laterSorting.count, signal: 2, filterTaskName: searchTxt_UI.text ?? "-", filterTagName: tagArrayConvertToString())
            }
            later_UI.isSelected = true
            todo_UI.isSelected = false
            complete_UI.isSelected = false
            progress_UI.progress = 100.0
            progress_UI.tintColor = UIColor(named: "LaterColor")
            progress_UI.backgroundColor = UIColor(named: "LaterColor")
            progressBack_UI.backgroundColor = UIColor(named: "LaterColor")
            selectedArr.removeAll()
            multiAll_UI.isSelected = false
            
            self.performFilter()
        }
    }
    
    func selectComplete() {
        if complete_UI.isSelected == false {
            currentTable = 2
            if searchTxt_UI.text != ""&&selectedFilterTagArr.count == 0{
                filterResultLabelText(taskNumber: completeSorting.count, signal: 0, filterTaskName: searchTxt_UI.text ?? "-", filterTagName: tagArrayConvertToString())
            }else if searchTxt_UI.text == ""&&selectedFilterTagArr.count != 0{
                filterResultLabelText(taskNumber: completeSorting.count, signal: 1, filterTaskName: searchTxt_UI.text ?? "-", filterTagName: tagArrayConvertToString())
            }else if searchTxt_UI.text != ""&&selectedFilterTagArr.count != 0{
                filterResultLabelText(taskNumber: completeSorting.count, signal: 2, filterTaskName: searchTxt_UI.text ?? "-", filterTagName: tagArrayConvertToString())
            }
            complete_UI.isSelected = true
            later_UI.isSelected = false
            todo_UI.isSelected = false
            progress_UI.progress = 100.0
            progress_UI.tintColor = UIColor(named: "CompleteColor")
            progress_UI.backgroundColor = UIColor(named: "CompleteColor")
            progressBack_UI.backgroundColor = UIColor(named: "CompleteColor")
            selectedArr.removeAll()
            multiAll_UI.isSelected = false
            self.performFilter()
        }
    }
    
    func showAddTaskView() {
        addTask_txt.isEnabled = true
        switch themeSwitcher {
        case true:
            addTask_txt.backgroundColor = UIColor(named: "BlurDarkColor")
            addTask_txt.textColor = UIColor.white
            tagFilterView_UI.backgroundColor = UIColor(named: "BlurDarkColor")
            tagCollectionView_UI.backgroundColor = UIColor(named: "BlurDarkColor")
        case false:
            addTask_txt.backgroundColor = UIColor.white
        }
        addTask_txt.placeholder = "Add a new task"
        addTask_txt.isHidden = false
        blurView.isHidden = false
        tagCollectionView_UI.reloadData()
        tagFilterView_UI.isHidden = false
        tagFilterViewTitleLabel_UI.isHidden = true
        tagFilterViewClearButton_UI.isHidden = true
        tagFilterViewDownButton_UI.isHidden = true
        view.bringSubviewToFront(tagFilterView_UI)
        view.bringSubviewToFront(addTask_txt)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.blurView.alpha = 1
            self.addTask_txt.alpha = 1
        }) { (true) in
            self.addTask_txt.becomeFirstResponder()
            switch self.themeSwitcher{
            case true:
                self.setShadow(view: self.tagFilterView_UI, width: 0, bColor: UIColor(named: "DarkColor")!, sColor: UIColor(named: "DarkColor")!, offset: CGSize(width: 0, height: 0), opacity: 0, radius: 0)
            case false:
                self.setShadow(view: self.tagFilterView_UI, width: 0, bColor: UIColor.white, sColor: UIColor.white, offset: CGSize(width: 0, height: 0), opacity: 0, radius: 0)
            }
            UIView.animate(withDuration: 0.25, animations: {
                self
                    .tagFilterView_UI.transform = self.tagFilterView_UI.transform.translatedBy(x: 0, y: -120 - (self.view.frame.maxY - self.addTask_txt.frame.minY))
            })
        }
        
    }
    
    func hideAddTaskView() {
        addTask_txt.resignFirstResponder()
        switch themeSwitcher {
        case true:
            tagFilterView_UI.backgroundColor = UIColor(named: "DarkColor")
            tagCollectionView_UI.backgroundColor = UIColor(named: "DarkColor")
        case false:
            addTask_txt.backgroundColor = UIColor.white
        }
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
            self.blurView.alpha = 0
            self.addTask_txt.alpha = 0
            self.view.frame = CGRect(x: 0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height)
            self.tagFilterView_UI.transform = self.tagFilterView_UI.transform.translatedBy(x: 0, y: 120 + (self.view.frame.maxY - self.addTask_txt.frame.minY))
        }, completion: {(true) in
            self.addTask_txt.isEnabled = false
            self.addTask_txt.isHidden = true
            self.blurView.isHidden = true
        })
    }
    
    func showTimeAdjustCollectionView() {
        blurView.isHidden = false
        timeAdjustLabel_UI.isHidden = false
        timeAdjustCollectionView_UI.isHidden = false
        view.bringSubviewToFront(timeAdjustCollectionView_UI)
        view.bringSubviewToFront(timeAdjustLabel_UI)
        UIView.animate(withDuration: 0.25) {
            self.blurView.alpha = 1
            self.timeAdjustLabel_UI.alpha = 1
            self.timeAdjustCollectionView_UI.alpha = 1
        }
    }
    
    func hideTimeAdjustCollectionView() {
        performFilter()
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.blurView.alpha = 0
            self.timeAdjustLabel_UI.alpha = 0
            self.timeAdjustCollectionView_UI.alpha = 0
        }) { (true) in
            self.blurView.isHidden = true
            self.timeAdjustLabel_UI.isHidden = true
            self.timeAdjustCollectionView_UI.isHidden = true
        }
    }
    
    func setCornerRadios(obj:UIButton,radius:CGFloat,bColor:UIColor,bWidth:CGFloat) {
        obj.layer.cornerRadius = radius
        obj.layer.borderColor = bColor.cgColor
        obj.layer.borderWidth = bWidth
    }
    
    func setShadow(view:UIView,width:CGFloat,bColor:UIColor,sColor:UIColor,offset:CGSize,opacity:Float,radius:CGFloat) {
        //设置视图边框宽度
        view.layer.borderWidth = width
        //设置边框颜色
        view.layer.borderColor = bColor.cgColor
        //设置边框圆角
        view.layer.cornerRadius = radius
        //设置阴影颜色
        view.layer.shadowColor = sColor.cgColor
        //设置透明度
        view.layer.shadowOpacity = opacity
        //设置阴影半径
        view.layer.shadowRadius = radius
        //设置阴影偏移量
        view.layer.shadowOffset = offset
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if addTask_txt.isEnabled {
            if addTask_txt.text == "" {
                hideAddTaskView()
            }else{
                sortTodoTask()
                var tagStatus = String()
                var tagArray:[String] = []
                var position = 0
                if todoTaskContainer.count == 0{
                    position = 0
                }else{
                    if selectedOptions[0] == false {
                        //Insert at begining
                        position = Int(todoSorting[0].position - 1)
                    }else{
                        //Append at ending
                        position = Int(todoSorting[todoSorting.count-1].position + 1)
                    }
                }
                let container = TodoTask(context: context)
                container.name = addTask_txt.text
                container.note = ""
                container.repeatInterval = "Never"
                for i in 0..<selectedTaskTagArr.count{
                    tagArray.append(tags[selectedTaskTagArr[i]].tags!)
                    tagStatus = tagStatus + tags[selectedTaskTagArr[i]].tags!
                }
                container.status = tagStatus
                container.steps = []
                container.tags = tagArray
                container.time = Int32(getCurrentStamp())
                container.position = Int32(position)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                //tag复原
                addTask_txt.text = ""
                
                self.performFilter()
            }
        }
        else if searchTxt_UI.isEnabled {
            if searchTxt_UI.text == "" {
                searchTxt_UI.resignFirstResponder()
                searchTxt_UI.isEnabled = false
                moreButtons[2].isSelected = false
                //                search_txt.removeFromSuperview()
            }else{
                searchTxt_UI.resignFirstResponder()
                moreButtons[2].isSelected = true
            }
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                self.view.frame = CGRect(x: 0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height)
            }, completion: nil)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                self.searchView_UI.transform = self.searchView_UI.transform.translatedBy(x: 0, y: 70)
                self.searchView_UI.alpha = 0
            }) { (true) in
                self.searchView_UI.isHidden = true
            }
        }
        return true
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    //notification click event
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let application = UIApplication.shared
        if(application.applicationState == .active){
//            prepareTodoLaterTask()
            let vc = storyboard?.instantiateViewController(withIdentifier: "viewController") as! ViewController
            present(vc,animated: true,completion: nil)
//            if tableView_UI != nil{
//                self.performFilter()
//            }
            print("user tapped the notification bar when the app is in foreground")
        }
        
        if(application.applicationState == .inactive)
        {
//            prepareTodoLaterTask()
            let vc = storyboard?.instantiateViewController(withIdentifier: "viewController") as! ViewController
            present(vc,animated: true,completion: nil)
//            if tableView_UI != nil{
//                self.performFilter()
//            }
            print("user tapped the notification bar when the app is in background")
        }
        
        /* Change root view controller to a specific viewcontroller */
        // let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerStoryboardID") as? ViewController
        // self.window?.rootViewController = vc
        completionHandler()
    }
    
    func updateLaterTask() {
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
        date = "\(newTimeContainer.year)-\(newTimeContainer.month)-\(newTimeContainer.day) \(newTimeContainer.hour):\(newTimeContainer.minute):\(newTimeContainer.second)"
        let position = positionOfLaterTask(bool: selectedOptions[0])
        var notificationTitle = String()
        let notificationId = Int32(position)
        let notificationTimeInterval = dateToTimeStamp(date: date) - getCurrentStamp()
        switch currentTable{
        case 0:
            let container = LaterTask(context: context)
            let item = todoTaskGroup[editingTaskIndex.section][editingTaskIndex.row]
            notificationTitle = item.name!
            container.name = item.name
            container.note = item.note
            container.repeatInterval = item.repeatInterval
            container.status = item.status
            container.steps = item.steps
            container.tags = item.tags
            container.time = Int32(dateToTimeStamp(date: date))
            container.position = Int32(position)
            self.context.delete(item)
        case 1:
            let container = LaterTask(context: context)
            let item = laterTaskGroup[editingTaskIndex.section][editingTaskIndex.row]
            notificationIdArr.append(String(item.position))
            notificationTitle = item.name!
            container.name = item.name
            container.note = item.note
            container.repeatInterval = item.repeatInterval
            container.status = item.status
            container.steps = item.steps
            container.tags = item.tags
            container.time = Int32(dateToTimeStamp(date: date))
            container.position = Int32(position)
            self.context.delete(item)
        case 2:
            let container = LaterTask(context: context)
            let item = completeTaskGroup[editingTaskIndex.section][editingTaskIndex.row]
            notificationTitle = item.name!
            container.name = item.name
            container.note = item.note
            container.repeatInterval = item.repeatInterval
            container.status = item.status
            container.steps = item.steps
            container.tags = item.tags
            container.time = Int32(dateToTimeStamp(date: date))
            container.position = Int32(position)
            self.context.delete(item)
        default:
            break
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        if notificationIdArr.count != 0 {
            self.removeNotification(identifiers: self.notificationIdArr)
            self.notificationIdArr.removeAll()
        }
        //<<------------register notification------------
        notificationContent.title = notificationTitle
        notificationContent.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(notificationTimeInterval), repeats: false)
        let request = UNNotificationRequest(identifier: "\(notificationId)", content: notificationContent, trigger: trigger)
        notificationCenter.add(request) { (true) in
            print("registered")
        }
        //------------register notification------------>>
        updateTaskNumberProgrees()
        //<<------------set timer------------
        setTimerForFirstLaterTask()
        //------------set timer------------>>
        hideTimeAdjustCollectionView()
    }
    
    func showCalendarView() {
        if fromTimeAdjustView == false {
            selectedTimeContainer = timeStampSlicing(timeStamp: String(getCurrentStamp()))
        }
        if Int(selectedTimeContainer.month) == Int(currentTimeContainer.month){
            calendarViewPreMonthButton_UI.isEnabled = false
        }else{
            calendarViewPreMonthButton_UI.isEnabled = true
        }
        selectedTimeContainer.minute = String(Int(selectedTimeContainer.minute)!+5)
        calendarDayArr = calendarDay(year: Int(selectedTimeContainer.year)!, month: Int(selectedTimeContainer.month)!)
        calendarCollectionView_UI.reloadData()
        calendarViewDateButton_UI.setTitle("\(selectedTimeContainer.day) \(convertEnglishMonth(month: Int(selectedTimeContainer.month)!)) | \(selectedTimeContainer.hour):\(selectedTimeContainer.minute)", for: .normal)
        calendarView_UI.isHidden = false
        view.bringSubviewToFront(calendarView_UI)
        UIView.animate(withDuration: 0.25) {
            self.calendarView_UI.alpha = 1
        }
    }
    
    func showPreMonthCalendarCollectionView() {
        if Int(selectedTimeContainer.month) == 1{
            selectedTimeContainer.month = "12"
            selectedTimeContainer.year = String(Int(selectedTimeContainer.year)! - 1)
        }else{
            selectedTimeContainer.month = String(Int(selectedTimeContainer.month)! - 1)
        }
        if Int(selectedTimeContainer.month) == Int(currentTimeContainer.month){
            calendarViewPreMonthButton_UI.isEnabled = false
        }else{
            calendarViewPreMonthButton_UI.isEnabled = true
        }
        if Int(selectedTimeContainer.month) == Int(currentTimeContainer.month) {
            selectedTimeContainer.day = String(Int(currentTimeContainer.day)!)
        }
        calendarDayArr = calendarDay(year: Int(selectedTimeContainer.year)!, month: Int(selectedTimeContainer.month)!)
        calendarCollectionView_UI.reloadData()
        calendarViewDateButton_UI.setTitle("\(selectedTimeContainer.day) \(convertEnglishMonth(month: Int(selectedTimeContainer.month)!)) | \(selectedTimeContainer.hour):\(selectedTimeContainer.minute)", for: .normal)
    }
    
    func showNextMonthCalendarCollectionView() {
        if Int(selectedTimeContainer.month) == 12{
            selectedTimeContainer.month = "1"
            selectedTimeContainer.year = String(Int(selectedTimeContainer.year)! + 1)
        }else{
            selectedTimeContainer.month = String(Int(selectedTimeContainer.month)! + 1)
        }
        if Int(selectedTimeContainer.month) == Int(currentTimeContainer.month){
            calendarViewPreMonthButton_UI.isEnabled = false
        }else{
            calendarViewPreMonthButton_UI.isEnabled = true
        }
        calendarDayArr = calendarDay(year: Int(selectedTimeContainer.year)!, month: Int(selectedTimeContainer.month)!)
        calendarCollectionView_UI.reloadData()
        calendarViewDateButton_UI.setTitle("\(selectedTimeContainer.day) \(convertEnglishMonth(month: Int(selectedTimeContainer.month)!)) | \(selectedTimeContainer.hour):\(selectedTimeContainer.minute)", for: .normal)
    }
    
    func hideCalendarView() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.calendarView_UI.alpha = 0
        }) { (true) in
            self.calendarView_UI.isHidden = true
        }
    }
    
}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if todo_UI.isSelected {
            return 1
        }else if later_UI.isSelected{
            return laterDates.count
        }else{
            return completeDates.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if todo_UI.isSelected{
            return 0
        }else{
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if later_UI.isSelected{
            let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell") as? CustomHomeTableViewSectionCell
            switch themeSwitcher{
            case true:
                cell?.backgroundColor = UIColor(named: "DarkColor")
                cell?.dateLabel_UI.textColor = UIColor.white
            case false:
                cell?.backgroundColor = UIColor.white
                cell?.dateLabel_UI.textColor = UIColor(named: "DarkColor")
            }
            cell?.dateLabel_UI.addBorder(side: .left, thickness: 2, color: UIColor(named: "LaterColor")!)
            cell?.dateLabel_UI.addBorder(side: .right, thickness: 2, color: UIColor(named: "LaterColor")!)
            cell?.dateLabel_UI.addBorder(side: .bottom, thickness: 2, color: UIColor(named: "LaterColor")!)
            cell?.dateLabel_UI.roundCorners([.bottomLeft,.bottomRight,.topRight], radius: 10)
            cell?.bottomLineView_UI.roundCorners([.topRight,.bottomRight], radius: 10)
            cell?.bottomLineView_UI.backgroundColor = UIColor(named: "LaterColor")
            let monthStartIndex = laterDates[section].index(laterDates[section].startIndex, offsetBy: 5)
            let monthEndIndex = laterDates[section].index(laterDates[section].startIndex, offsetBy: 7)
            let month = String(laterDates[section][monthStartIndex ..< monthEndIndex])
            
            let dayStartIndex = laterDates[section].index(laterDates[section].endIndex, offsetBy: -2)
            let dayEndIndex = laterDates[section].index(laterDates[section].endIndex, offsetBy: 0)
            let day = String(laterDates[section][dayStartIndex ..< dayEndIndex])
            
            if currentTimeContainer.day == day{
                cell?.dateLabel_UI.text = "Later Today"
            }else if Int(currentTimeContainer.day)! - 1 == Int(day){
                cell?.dateLabel_UI.text = "Yesterday"
            }else if Int(currentTimeContainer.day)! + 1 == Int(day){
                cell?.dateLabel_UI.text = "Tomorrow"
            }else if laterDates[section] == "UNSPECIFIED"{
                cell?.dateLabel_UI.text = "UNSPECIFIED"
            }else{
                cell?.dateLabel_UI.text = "\(convertEnglishMonth(month: Int(month)!))" + " " + "\(day)"
            }
            return cell
        }else if todo_UI.isSelected{
            return nil
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell") as? CustomHomeTableViewSectionCell
            switch themeSwitcher{
            case true:
                cell?.backgroundColor = UIColor(named: "DarkColor")
                cell?.dateLabel_UI.textColor = UIColor.white
            case false:
                cell?.backgroundColor = UIColor.white
                cell?.dateLabel_UI.textColor = UIColor(named: "DarkColor")
            }
            cell?.dateLabel_UI.addBorder(side: .left, thickness: 2, color: UIColor(named: "CompleteColor")!)
            cell?.dateLabel_UI.addBorder(side: .right, thickness: 2, color: UIColor(named: "CompleteColor")!)
            cell?.dateLabel_UI.addBorder(side: .bottom, thickness: 2, color: UIColor(named: "CompleteColor")!)
            cell?.dateLabel_UI.roundCorners([.bottomLeft,.topLeft,.bottomRight,.topRight], radius: 10)
            cell?.bottomLineView_UI.roundCorners([.topRight,.bottomRight], radius: 10)
            cell?.bottomLineView_UI.backgroundColor = UIColor(named: "CompleteColor")

            let monthStartIndex = completeDates[section].index(completeDates[section].startIndex, offsetBy: 5)
            let monthEndIndex = completeDates[section].index(completeDates[section].startIndex, offsetBy: 7)
            let month = String(completeDates[section][monthStartIndex ..< monthEndIndex])

            let dayStartIndex = completeDates[section].index(completeDates[section].endIndex, offsetBy: -2)
            let dayEndIndex = completeDates[section].index(completeDates[section].endIndex, offsetBy: 0)
            let day = String(completeDates[section][dayStartIndex ..< dayEndIndex])

            if currentTimeContainer.day == day{
                cell?.dateLabel_UI.text = "Today"
            }else if Int(currentTimeContainer.day)! - 1 == Int(day){
                cell?.dateLabel_UI.text = "Yesterday"
            }else{
                cell?.dateLabel_UI.text = "\(convertEnglishMonth(month: Int(month)!))" + " " + "\(day)"
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if later_UI.isSelected {
            return laterTaskGroup[section].count
        }else if todo_UI.isSelected {
            return todoSorting.count
        }else{
            return completeTaskGroup[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? customHomeTableViewCell
        cell!.selectedBackgroundView = UIView()
        cell?.tagLabel.isHidden = true
        cell?.tagImg.isHidden = true
        cell?.noteImg_UI.isHidden = true
        cell?.stepsCountLabel_UI.isHidden = true
        cell!.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell!.bounds.size.width)
        
        switch themeSwitcher {
        case true:
            cell?.backgroundColor = UIColor(named: "DarkColor")
            cell?.taskLabel_UI.textColor = UIColor.white
            cell?.tagLabel.textColor = UIColor.white
            cell?.stepsCountLabel_UI.textColor = UIColor.white
            cell?.selectedBackgroundView?.backgroundColor = UIColor(named: "DarkColor")
            cell?.selectedView_UI.backgroundColor = UIColor(named: "DarkColor")
        case false:
            cell?.selectedBackgroundView?.backgroundColor = UIColor.white
            cell?.selectedView_UI.backgroundColor = UIColor.white
        }
        
        if later_UI.isSelected {
            //handle time
            if laterTaskGroup[indexPath.section][indexPath.row].time == 2147483647{
                cell?.timeLabel_UI.isHidden = true
            }else{
                cell?.timeLabel_UI.isHidden = false
                cell?.timeLabel_UI.textColor = UIColor(named: "LaterColor")
                let timeSlicing = timeStampSlicing(timeStamp: String(laterTaskGroup[indexPath.section][indexPath.row].time))
                cell?.timeLabel_UI.text = "\(timeSlicing.hour):\(timeSlicing.minute)"
            }
            //handle tag
            if laterTaskGroup[indexPath.section][indexPath.row].tags?.count != 0{
                var str:String = ""
                cell?.tagImg.isHidden = false
                cell?.tagLabel.isHidden = false
                for i in 0..<laterTaskGroup[indexPath.section][indexPath.row].tags!.count{
                    var newStr:String = ""
                    //最后一个
                    if i == laterTaskGroup[indexPath.section][indexPath.row].tags!.count - 1{
                        newStr = "\(laterTaskGroup[indexPath.section][indexPath.row].tags![i])"
                    }else{
                        newStr = "\(laterTaskGroup[indexPath.section][indexPath.row].tags![i]),"
                    }
                    str = str + newStr
                }
                cell?.tagLabel.text = str
            }
            //handle steps
            if laterTaskGroup[indexPath.section][indexPath.row].steps?.count != 0{
                //handle stepsCountLabel_UI layer
                cell?.stepsCountLabel_UI.isHidden = false
                cell?.stepsCountLabel_UI.layer.masksToBounds = true
                cell?.stepsCountLabel_UI.layer.cornerRadius = 3.0
                cell?.stepsCountLabel_UI.layer.borderColor = UIColor(named: "LaterColor")?.cgColor
                cell?.stepsCountLabel_UI.layer.borderWidth = 1.0
                cell?.stepsCountLabel_UI.text = String(laterTaskGroup[indexPath.section][indexPath.row].steps!.count)
            }
            //handle notes
            if laterTaskGroup[indexPath.section][indexPath.row].note != ""{
                cell?.noteImg_UI.isHidden = false
            }
            if selectedArr.contains(IndexPath(row: indexPath.row, section: indexPath.section)){
                cell?.selectedView_UI.backgroundColor = UIColor(named: "LaterColor")
            }
            
            cell!.taskLabel_UI.text = "\(laterTaskGroup[indexPath.section][indexPath.row].name ?? "-")"
            cell?.point_UI.setImage(UIImage(named: "laterPoint"), for: .normal)
            cell!.point_UI.addTarget(self, action: #selector(laterPointButtonClick(button:)), for: .touchUpInside)
            //repeat
            if laterTaskGroup[indexPath.section][indexPath.row].repeatInterval != "Never"{
                cell?.repeatImg_UI.isHidden  = false
            }
        }else if todo_UI.isSelected {
            cell?.timeLabel_UI.isHidden = true
            //handle tag
            if todoTaskGroup[indexPath.section][indexPath.row].tags?.count != 0{
                var str:String = ""
                cell?.tagImg.isHidden = false
                cell?.tagLabel.isHidden = false
                for i in 0..<todoTaskGroup[indexPath.section][indexPath.row].tags!.count{
                    var newStr:String = ""
                    //最后一个
                    if i == todoTaskGroup[indexPath.section][indexPath.row].tags!.count - 1{
                        newStr = "\(todoTaskGroup[indexPath.section][indexPath.row].tags![i])"
                    }else{
                        newStr = "\(todoTaskGroup[indexPath.section][indexPath.row].tags![i]),"
                    }
                    str = str + newStr
                }
                cell?.tagLabel.text = str
            }
            //handle steps
            if todoTaskGroup[indexPath.section][indexPath.row].steps?.count != 0{
                //handle stepsCountLabel_UI layer
                cell?.stepsCountLabel_UI.isHidden = false
                cell?.stepsCountLabel_UI.layer.masksToBounds = true
                cell?.stepsCountLabel_UI.layer.cornerRadius = 3.0
                cell?.stepsCountLabel_UI.layer.borderColor = UIColor(named: "TodoColor")?.cgColor
                cell?.stepsCountLabel_UI.layer.borderWidth = 1.0
                cell?.stepsCountLabel_UI.text = String(todoTaskGroup[indexPath.section][indexPath.row].steps!.count)
            }
            //handle notes
            if todoTaskGroup[indexPath.section][indexPath.row].note != ""{
                cell?.noteImg_UI.isHidden = false
            }
            if selectedArr.contains(IndexPath(row: indexPath.row, section: indexPath.section)){
                cell?.selectedView_UI.backgroundColor = UIColor(named: "TodoColor")
            }
            //repeat
            if todoTaskGroup[indexPath.section][indexPath.row].repeatInterval != "Never"{
                cell?.repeatImg_UI.isHidden  = false
            }
            cell!.taskLabel_UI.text = "\(todoSorting[indexPath.row].name ?? "-")"
            cell?.point_UI.setImage(UIImage(named: "point"), for: .normal)
            cell!.point_UI.addTarget(self, action: #selector(todoPointButtonClick(button:)), for: .touchUpInside)
        }else{
            //handle time
            cell?.timeLabel_UI.isHidden = false
            cell?.timeLabel_UI.textColor = UIColor(named: "CompleteColor")
            let timeSlicing = timeStampSlicing(timeStamp: String(completeTaskGroup[indexPath.section][indexPath.row].time))
            cell?.timeLabel_UI.text = "\(timeSlicing.hour):\(timeSlicing.minute)"
            //handle tag
            if completeTaskGroup[indexPath.section][indexPath.row].tags?.count != 0{
                var str:String = ""
                cell?.tagImg.isHidden = false
                cell?.tagLabel.isHidden = false
                for i in 0..<completeTaskGroup[indexPath.section][indexPath.row].tags!.count{
                    var newStr:String = ""
                    //最后一个
                    if i == completeTaskGroup[indexPath.section][indexPath.row].tags!.count - 1{
                        newStr = "\(completeTaskGroup[indexPath.section][indexPath.row].tags![i])"
                    }else{
                        newStr = "\(completeTaskGroup[indexPath.section][indexPath.row].tags![i]),"
                    }
                    str = str + newStr
                }
                cell?.tagLabel.text = str
            }
            //handle steps
            if completeTaskGroup[indexPath.section][indexPath.row].steps?.count != 0{
                //handle stepsCountLabel_UI layer
                cell?.stepsCountLabel_UI.isHidden = false
                cell?.stepsCountLabel_UI.layer.masksToBounds = true
                cell?.stepsCountLabel_UI.layer.cornerRadius = 3.0
                cell?.stepsCountLabel_UI.layer.borderColor = UIColor(named: "CompleteColor")?.cgColor
                cell?.stepsCountLabel_UI.layer.borderWidth = 1.0
                cell?.stepsCountLabel_UI.text = String(completeTaskGroup[indexPath.section][indexPath.row].steps!.count)
            }
            //handle notes
            if completeTaskGroup[indexPath.section][indexPath.row].note != ""{
                cell?.noteImg_UI.isHidden = false
            }
            if selectedArr.contains(IndexPath(row: indexPath.row, section: indexPath.section)){
                cell?.selectedView_UI.backgroundColor = UIColor(named: "CompleteColor")
            }
            //repeat
            if completeTaskGroup[indexPath.section][indexPath.row].repeatInterval != "Never"{
                cell?.repeatImg_UI.isHidden  = false
            }
            cell!.taskLabel_UI.text = "\(completeTaskGroup[indexPath.section][indexPath.row].name ?? "-")"
            cell?.point_UI.setImage(UIImage(named: "completePoint"), for: .normal)
            cell!.point_UI.addTarget(self, action: #selector(completePointButtonClick(button:)), for: .touchUpInside)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Multiple choice
        if moreButtons[0].isSelected{
            self.tableView_UI.allowsMultipleSelection = true
            self.tableView_UI.allowsSelection = true
            self.tableView_UI.allowsMultipleSelectionDuringEditing = true
            //selectedArr is null
            if selectedArr.count == 0{
                selectedArr.append(IndexPath(row: indexPath.row, section: indexPath.section))
            }
            //selectedArr is not null
            else{
                var flag = true
                for i in 0..<selectedArr.count{
                    //selectedArr删数据(取消选中)
                    if IndexPath(row: indexPath.row, section: indexPath.section) == selectedArr[i]{
                        selectedArr.remove(at: i)
                        flag = false
                        break
                    }else{
                        flag = true
                    }
                }
                //selectedArr加数据（选中)
                if flag == true{
                    selectedArr.append(IndexPath(row: indexPath.row, section: indexPath.section))
                }
            }
            
            //sekectedArr不为空时隐藏multipleFunctionsView_UI
            if selectedArr.count != 0{
                if multipleFunctionsView_UI.isHidden == true{
                    multipleFunctionsViewShow()
                }
            }
            //sekectedArr为空时隐藏multipleFunctionsView_UI
            else{
                multipleFunctionsViewHide()
            }
            tableView_UI.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .fade)
        }else{
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailViewController") as? DetailViewController{
                if later_UI.isSelected{
                    vc.laterSingle = laterTaskGroup[indexPath.section][indexPath.row]
                    vc.index = IndexPath(row: indexPath.row, section: indexPath.section)
                    vc.filterText = searchTxt_UI.text ?? ""
                    vc.selectedFilterTagArr = selectedFilterTagArr
                    vc.currentTable = currentTable
                    vc.editingTaskIndex = IndexPath(row: indexPath.row, section: indexPath.section)
                    self.present(vc, animated: true, completion: nil)
                }else if todo_UI.isSelected{
                    vc.todoSingle = todoTaskGroup[indexPath.section][indexPath.row]
                    vc.index = IndexPath(row: indexPath.row, section: indexPath.section)
                    vc.filterText = searchTxt_UI.text ?? ""
                    vc.selectedFilterTagArr = selectedFilterTagArr
                    vc.currentTable = currentTable
                    vc.editingTaskIndex = IndexPath(row: indexPath.row, section: indexPath.section)
                    self.present(vc, animated: true, completion: nil)
                }else{
                    vc.completeSingle = completeTaskGroup[indexPath.section][indexPath.row]
                    vc.index = IndexPath(row: indexPath.row, section: indexPath.section)
                    vc.filterText = searchTxt_UI.text ?? ""
                    vc.selectedFilterTagArr = selectedFilterTagArr
                    vc.currentTable = currentTable
                    vc.editingTaskIndex = IndexPath(row: indexPath.row, section: indexPath.section)
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        if moreButtons[0].isSelected{
//            self.tableView_UI.allowsMultipleSelection = true
//            self.tableView_UI.allowsMultipleSelectionDuringEditing = true
//            for i in 0..<selectedArr.count{
//                if selectedArr[i] == indexPath.row{
//                    selectedArr.remove(at: i)
//                    break
//                }
//            }
//            print(selectedArr)
//        }
//    }
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //SwipeAction for menu leading
        if todo_UI.isSelected == true {
            let complete = UIContextualAction(style: .destructive, title: "") { (action, view, compeletionHandler) in
                var position = Int()
                if self.completeTaskContainer.count == 0{
                    position = 0
                }else{
                    var sorting = self.completeTaskContainer.sorted(by: { (p1, p2) -> Bool in
                        p2.position > p1.position
                    })
                    if self.selectedOptions[0] == false{
                        //Insert at begining
                        position = Int(sorting[0].position - 1)
                    }else{
                        //Append at ending
                        position = Int(sorting[sorting.count-1].position + 1)
                    }
                }
                let container = CompleteTask(context: self.context)
                let section = indexPath.section
                let row = indexPath.row
                container.name = self.todoTaskGroup[section][row].name
                container.note = self.todoTaskGroup[section][row].note
                container.repeatInterval = self.todoTaskGroup[section][row].repeatInterval
                container.status = self.todoTaskGroup[section][row].status
                container.steps = self.todoTaskGroup[section][row].steps
                container.tags = self.todoTaskGroup[section][row].tags
                container.time = Int32(getCurrentStamp())
                container.position = Int32(position)
                
                self.context.delete(self.todoTaskGroup[section][row])
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                _ = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { (timer) in
                    self.performFilter()
                }
                self.updateTaskNumberProgrees()
                compeletionHandler(true)
            }
            complete.backgroundColor = UIColor(named: "CompleteColor")
            complete.image = UIImage(named: "Check")
            let swipeConfiguration = UISwipeActionsConfiguration(actions: [complete])
            return swipeConfiguration
        }
//            SwipeAction for later leading
        else if later_UI.isSelected == true{
            let todo = UIContextualAction(style: .destructive, title: "") { (action, view, compeletionHandler) in
                var position = Int()
                if self.todoTaskContainer.count == 0{
                    position = 0
                }else{
                    var sorting = self.todoTaskContainer.sorted(by: { (p1, p2) -> Bool in
                        p2.position > p1.position
                    })
                    if self.selectedOptions[0] == false{
                        //Insert at begining
                        position = Int(sorting[0].position - 1)
                    }else{
                        //Append at ending
                        position = Int(sorting[sorting.count-1].position + 1)
                    }
                }
                let container = TodoTask(context: self.context)
                container.name = self.laterTaskGroup[indexPath.section][indexPath.row].name
                container.note = self.laterTaskGroup[indexPath.section][indexPath.row].note
                container.repeatInterval = self.laterTaskGroup[indexPath.section][indexPath.row].repeatInterval
                container.status = self.laterTaskGroup[indexPath.section][indexPath.row].status
                container.steps = self.laterTaskGroup[indexPath.section][indexPath.row].steps
                container.tags = self.laterTaskGroup[indexPath.section][indexPath.row].tags
                container.time = Int32(getCurrentStamp())
                container.position = Int32(position)
                self.notificationIdArr.append(String(self.laterTaskGroup[indexPath.section][indexPath.row].position))
                self.context.delete(self.laterTaskGroup[indexPath.section][indexPath.row])
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                self.removeNotification(identifiers: self.notificationIdArr)
                self.notificationIdArr.removeAll()
                self.setTimerForFirstLaterTask()
                _ = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { (timer) in
                    self.performFilter()
                }
                self.updateTaskNumberProgrees()
                compeletionHandler(true)
            }
            todo.backgroundColor = UIColor(named: "TodoColor")
            todo.image = UIImage(named: "menu_22.769230769231px_1223077_easyicon.net")
            let swipeConfiguration = UISwipeActionsConfiguration(actions: [todo])
            return swipeConfiguration
        }
//            SwipeAction for compelte leading
        else{
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //SwipeAction for menu trailing
        if todo_UI.isSelected == true{
            let later = UIContextualAction(style: .destructive, title: "") { (action, view, compeletionHandler) in
                self.editingTaskIndex = IndexPath(row: indexPath.row, section: indexPath.section)
                self.showTimeAdjustCollectionView()
                compeletionHandler(true)
            }
            later.backgroundColor = UIColor(named: "LaterColor")
            later.image = UIImage(named: "Alarm")
            let swipeConfiguration = UISwipeActionsConfiguration(actions: [later])
            return swipeConfiguration
        }
            //SwipeAction for later trailing
        else if later_UI.isSelected == true{
            let later = UIContextualAction(style: .destructive, title: "") { (action, view, compeletionHandler) in
                self.editingTaskIndex = IndexPath(row: indexPath.row, section: indexPath.section)
                self.showTimeAdjustCollectionView()
                compeletionHandler(true)
            }
            later.image = UIImage(named: "Alarm")
            later.backgroundColor = UIColor(named: "LaterColor")
            let swipeConfiguration = UISwipeActionsConfiguration(actions: [later])
            return swipeConfiguration
        }
            //SwipeAction for compelte trailing
        else{
            let todo = UIContextualAction(style: .destructive, title: "") { (action, view, compeletionHandler) in
                var position = Int()
                if self.todoTaskContainer.count == 0{
                    position = 0
                }else{
                    var sorting = self.todoTaskContainer.sorted(by: { (p1, p2) -> Bool in
                        p2.position > p1.position
                    })
                    if self.selectedOptions[0] == false{
                        //Insert at begining
                        position = Int(sorting[0].position - 1)
                    }else{
                        //Append at ending
                        position = Int(sorting[sorting.count-1].position + 1)
                    }
                }
                let container = TodoTask(context: self.context)
                container.name = self.completeTaskGroup[indexPath.section][indexPath.row].name
                container.note = self.completeTaskGroup[indexPath.section][indexPath.row].note
                container.repeatInterval = self.completeTaskGroup[indexPath.section][indexPath.row].repeatInterval
                container.status = self.completeTaskGroup[indexPath.section][indexPath.row].status
                container.steps = self.completeTaskGroup[indexPath.section][indexPath.row].steps
                container.tags = self.completeTaskGroup[indexPath.section][indexPath.row].tags
                container.time = Int32(getCurrentStamp())
                container.position = Int32(position)
                self.context.delete(self.completeTaskGroup[indexPath.section][indexPath.row])
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                _ = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { (timer) in
                    self.performFilter()
                }
                self.updateTaskNumberProgrees()
                compeletionHandler(true)
            }
            todo.backgroundColor = UIColor(named: "TodoColor")
            todo.image = UIImage(named: "menu_22.769230769231px_1223077_easyicon.net")
            let swipeConfiguration = UISwipeActionsConfiguration(actions: [todo])
            return swipeConfiguration
        }
    }
    
    
    
}

extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case tagCollectionView_UI:
            return tags.count + 1
        case timeAdjustCollectionView_UI:
            return adjustTimeTitleArr.count
        case calendarCollectionView_UI:
            return calendarDayArr.count + 7
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case tagCollectionView_UI:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
            if indexPath.row == tags.count{
                cell.tagNameLabel_UI.text = "+"
            }else{
                cell.tagNameLabel_UI.text = tags[indexPath.row].tags
            }
            if addTask_txt.isEnabled{
                //selected
                if selectedTaskTagArr.contains(indexPath.row){
                    switch themeSwitcher{
                    case true:
                        cell.backgroundColor = UIColor.white
                        cell.tagNameLabel_UI.textColor = UIColor(named: "DarkColor")
                    case false:
                        cell.backgroundColor = UIColor.black
                        cell.tagNameLabel_UI.textColor = UIColor.white
                    }
                }
                //not selected
                else{
                    switch themeSwitcher{
                    case true:
                        cell.backgroundColor = UIColor(named: "DarkColor")
                        cell.tagNameLabel_UI.textColor = UIColor.white
                    case false:
                        cell.backgroundColor = UIColor.white
                        cell.tagNameLabel_UI.textColor = UIColor.black
                    }
                }
            }else{
                if selectedFilterTagArr.contains(indexPath.row){
                    switch themeSwitcher{
                    case true:
                        cell.backgroundColor = UIColor.white
                        cell.tagNameLabel_UI.textColor = UIColor(named: "DarkColor")
                    case false:
                        cell.backgroundColor = UIColor.black
                        cell.tagNameLabel_UI.textColor = UIColor.white
                    }
                }else{
                    switch themeSwitcher{
                    case true:
                        cell.backgroundColor = UIColor(named: "DarkColor")
                        cell.tagNameLabel_UI.textColor = UIColor.white
                    case false:
                        cell.backgroundColor = UIColor.white
                        cell.tagNameLabel_UI.textColor = UIColor.black
                    }
                }
            }
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 15.0
            switch themeSwitcher{
            case true:
                cell.layer.borderColor = UIColor.white.cgColor
            case false:
                cell.layer.borderColor = UIColor(named: "DarkColor")?.cgColor
            }
            
            cell.layer.borderWidth = 1.0
            return cell
        case timeAdjustCollectionView_UI:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ViewControllerAdjustTimeCollectionViewCell
            switch themeSwitcher{
            case true:
                cell.img_UI.image = UIImage(named: adjustTimeDarkTitleArr[indexPath.row])
            case false:
                cell.img_UI.image = UIImage(named: adjustTimeTitleArr[indexPath.row])
            }
            cell.label_UI.text = adjustTimeTitleArr[indexPath.row]
            return cell
        case calendarCollectionView_UI:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCalendarCollectionViewCell
            var disableFlag = false
            var normalFlag = false
            switch indexPath.row {
            case 0:
                cell.label_UI.text = "sun"
                cell.label_UI.textColor = UIColor(named: "LaterColor")
                switch themeSwitcher{
                case true:
                    cell.label_UI.backgroundColor = UIColor(named: "DarkColor")
                case false:
                    cell.label_UI.backgroundColor = UIColor.white
                }
            case 1:
                cell.label_UI.text = "mon"
                cell.label_UI.textColor = UIColor(named: "LaterColor")
                switch themeSwitcher{
                case true:
                    cell.label_UI.backgroundColor = UIColor(named: "DarkColor")
                case false:
                    cell.label_UI.backgroundColor = UIColor.white
                }
            case 2:
                cell.label_UI.text = "tue"
                cell.label_UI.textColor = UIColor(named: "LaterColor")
                switch themeSwitcher{
                case true:
                    cell.label_UI.backgroundColor = UIColor(named: "DarkColor")
                case false:
                    cell.label_UI.backgroundColor = UIColor.white
                }
            case 3:
                cell.label_UI.text = "wed"
                cell.label_UI.textColor = UIColor(named: "LaterColor")
                switch themeSwitcher{
                case true:
                    cell.label_UI.backgroundColor = UIColor(named: "DarkColor")
                case false:
                    cell.label_UI.backgroundColor = UIColor.white
                }
            case 4:
                cell.label_UI.text = "thu"
                cell.label_UI.textColor = UIColor(named: "LaterColor")
                switch themeSwitcher{
                case true:
                    cell.label_UI.backgroundColor = UIColor(named: "DarkColor")
                case false:
                    cell.label_UI.backgroundColor = UIColor.white
                }
            case 5:
                cell.label_UI.text = "fri"
                cell.label_UI.textColor = UIColor(named: "LaterColor")
                switch themeSwitcher{
                case true:
                    cell.label_UI.backgroundColor = UIColor(named: "DarkColor")
                case false:
                    cell.label_UI.backgroundColor = UIColor.white
                }
            case 6:
                cell.label_UI.text = "sat"
                cell.label_UI.textColor = UIColor(named: "LaterColor")
                switch themeSwitcher{
                case true:
                    cell.label_UI.backgroundColor = UIColor(named: "DarkColor")
                case false:
                    cell.label_UI.backgroundColor = UIColor.white
                }
            default:
                cell.label_UI.layer.masksToBounds = true
                cell.label_UI.layer.cornerRadius = 15
                
                if Int(selectedTimeContainer.month) == Int(currentTimeContainer.month) {
                    let indexOfLastDay = calendarDayArr.lastIndex(of: Int(daysOfThisMonth(year: Int(currentTimeContainer.year)!, month: Int(currentTimeContainer.month)!)))
                    if calendarDayArr[indexPath.row - 7] == 0{
                        cell.label_UI.text = ""
                    }else{
                        cell.label_UI.text = "\(calendarDayArr[indexPath.row - 7])"
                    }
                    if indexPath.row - 7 < calendarDayArr.firstIndex(of: Int(currentTimeContainer.day)!)!{
                        disableFlag = true
                    }else if indexPath.row - 7 > indexOfLastDay!{
                        normalFlag = true
                    }else{
                        disableFlag = false
                        normalFlag = false
                    }
                    if disableFlag == true{
                        cell.isUserInteractionEnabled = false
                        cell.label_UI.textColor = UIColor.lightGray
                    }else if normalFlag == true{
                        cell.isUserInteractionEnabled = true
                        cell.label_UI.textColor = UIColor.lightGray
                    }
                    else{
                        cell.isUserInteractionEnabled = true
                        switch themeSwitcher{
                        case true:
                            cell.label_UI.textColor = UIColor.white
                        case false:
                            cell.label_UI.textColor = UIColor(named: "DarkColor")
                        }
//                        cell.label_UI.textColor = UIColor.white
                    }
                }else{
                    let indexOfFirstDay = calendarDayArr.firstIndex(of: 1)
                    let indexOfLastDay = calendarDayArr.lastIndex(of: Int(daysOfThisMonth(year: Int(selectedTimeContainer.year)!, month: Int(selectedTimeContainer.month)!)))
                    cell.label_UI.text = "\(calendarDayArr[indexPath.row - 7])"
//                    cell.label_UI.textColor = UIColor.black
                    if indexPath.row - 7 < indexOfFirstDay! || indexPath.row - 7 > indexOfLastDay!{
                        disableFlag = true
                    }
                    if disableFlag == true{
                        cell.isUserInteractionEnabled = true
                        cell.label_UI.textColor = UIColor.lightGray
                    }else{
                        cell.isUserInteractionEnabled = true
                        switch themeSwitcher{
                        case true:
                            cell.label_UI.textColor = UIColor.white
                        case false:
                            cell.label_UI.textColor = UIColor(named: "DarkColor")
                        }
                    }
                }
                
                var index = Int()
                if Int(selectedTimeContainer.day)! > daysOfThisMonth(year: Int(selectedTimeContainer.year)!, month: Int(selectedTimeContainer.month)!){
                    selectedTimeContainer.day = String(daysOfThisMonth(year: Int(selectedTimeContainer.year)!, month: Int(selectedTimeContainer.month)!))
                }
                if Int(selectedTimeContainer.day)! > 15{
                    index = calendarDayArr.lastIndex(of: Int(selectedTimeContainer.day)!)!
                }else{
                    index = calendarDayArr.firstIndex(of: Int(selectedTimeContainer.day)!)!
                }
                if indexPath.row - 7 == index{
                    preDateIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
                    cell.label_UI.backgroundColor = UIColor(named: "LaterColor")
                }else{
                    switch themeSwitcher{
                    case true:
                        cell.label_UI.backgroundColor = UIColor(named: "DarkColor")
                    case false:
                        cell.label_UI.backgroundColor = UIColor.white
                    }
                }
                
            }
            return cell
        default:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case tagCollectionView_UI:
            if indexPath.row == tags.count {
                addTagButtonClick()
            }else{
                if addTask_txt.isEnabled{
                    selectedTaskTagArr = tagCellClick(id: 0, index: indexPath.row)
                    selectedTaskTagArr.sort(by:<)
                }else{
                    selectedFilterTagArr = tagCellClick(id: 1, index: indexPath.row)
                    selectedFilterTagArr.sort(by:<)
                    if selectedFilterTagArr.count == 0{
                        tagFilterViewClearButton_UI.tintColor = UIColor.gray
                    }else{
                        tagFilterViewClearButton_UI.tintColor = UIColor.black
                    }
                    performFilter()
                    if selectedFilterTagArr.count == 0{
                        moreButtons[1].isSelected = false
                    }else{
                        moreButtons[1].isSelected = true
                    }
                }
            }
            tagCollectionView_UI.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
        case timeAdjustCollectionView_UI:
            timeDidChange = true
            newTimeContainer = timeStampSlicing(timeStamp: String(getCurrentStamp()))
            thisMonthDays = daysOfThisMonth(year: Int(newTimeContainer.year)!, month: Int(newTimeContainer.month)!)
            switch indexPath.row{
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
                print(newTimeContainer.hour)
                updateLaterTask()
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
                updateLaterTask()
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
                updateLaterTask()
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
                updateLaterTask()
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
                updateLaterTask()
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
                updateLaterTask()
            case 6:
                newTimeContainer = timeStampSlicing(timeStamp: "2147483647")
                updateLaterTask()
            case 7:
                showCalendarView()
            case 8:
                newTimeContainer.second = String(Int(newTimeContainer.second)! + 10)
                if Int(newTimeContainer.second)! >= 60{
                    newTimeContainer.second = String(Int(newTimeContainer.second)! - 60)
                    newTimeContainer.minute = String(Int(newTimeContainer.minute)! + 1)
                }
                if Int(newTimeContainer.minute)! >= 60{
                    newTimeContainer.hour = String(Int(newTimeContainer.hour)! + 1)
                    newTimeContainer.minute = "00"
                }
                if Int(newTimeContainer.hour)! >= 24{
                    newTimeContainer.day = String(Int(newTimeContainer.day)! + 1)
                    newTimeContainer.hour = "00"
                }
                updateLaterTask()
            default:
                break
            }
            
        case calendarCollectionView_UI:
            let indexOfFirstDay = calendarDayArr.firstIndex(of: 1)
            let indexOfLastDay = calendarDayArr.lastIndex(of: Int(daysOfThisMonth(year: Int(selectedTimeContainer.year)!, month: Int(selectedTimeContainer.month)!)))
            //calendar中的前几天
            if indexPath.row - 7 < indexOfFirstDay!{
                selectedTimeContainer.day = String(calendarDayArr[indexPath.row - 7])
                showPreMonthCalendarCollectionView()
            }
                //calendar中的后几天
            else if indexPath.row - 7 > indexOfLastDay!{
                selectedTimeContainer.day = String(calendarDayArr[indexPath.row - 7])
                showNextMonthCalendarCollectionView()
            }else{
                selectedTimeContainer.day = String(calendarDayArr[indexPath.row - 7])
                collectionView.reloadItems(at: [preDateIndexPath])
                collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: indexPath.section)])
            }
            calendarViewDateButton_UI.setTitle("\(selectedTimeContainer.day) \(convertEnglishMonth(month: Int(selectedTimeContainer.month)!)) | \(selectedTimeContainer.hour):\(selectedTimeContainer.minute)", for: .normal)
        default:
            break
        }
        
    }
    
    
    
}

extension ViewController:UICollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case tagCollectionView_UI:
            return 10
        case timeAdjustCollectionView_UI:
            return 5
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case tagCollectionView_UI:
            return 0
        case timeAdjustCollectionView_UI:
            return 5
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch collectionView {
        case tagCollectionView_UI:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case timeAdjustCollectionView_UI:
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case tagCollectionView_UI:
            var width = 0
            if indexPath.row == tags.count{
                width = 30
            }else{
                width = tags[indexPath.row].tags!.count * 15
            }
            return CGSize(width: width, height: 30)
        case timeAdjustCollectionView_UI:
            return CGSize(width: 90, height: 90)
        case calendarCollectionView_UI:
            return CGSize(width: 40, height: 40)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
}

extension CALayer {
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: thickness)
            
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.bounds.height - thickness,  width: self.bounds.width, height: thickness)
            
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0,  width: thickness, height: self.bounds.height)
            
        case UIRectEdge.right:
            border.frame = CGRect(x: self.bounds.width - thickness, y: 0,  width: thickness, height: self.bounds.height)
            
        default:
            break
        }
        border.backgroundColor = color.cgColor;
        self.addSublayer(border)
    }
}

extension UIView {
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
