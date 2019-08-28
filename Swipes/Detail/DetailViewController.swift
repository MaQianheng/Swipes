//
//  DetailViewController.swift
//  Swipes
//
//  Created by 马乾亨 on 4/5/19.
//  Copyright © 2019 CS3432. All rights reserved.
//

import UIKit
import UserNotifications

public enum ShakeDirection: Int {
    case horizontal  //水平抖动
    case vertical  //垂直抖动
}

class DetailCustomTimeAdjustCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var img_UI: UIImageView!
    @IBOutlet weak var label_UI: UILabel!
}

class detailCustomCollectionViewCell: UICollectionViewCell {
    @IBOutlet var leftView_UI:UIView!
    @IBOutlet var rightView_UI:UIView!
    @IBOutlet var timeTitleLabel_UI:UILabel!
}

class detailCustomeTableViewCell: UITableViewCell {
    @IBOutlet var iconBtn_UI: UIButton!
    @IBOutlet var stepTxt_UI:UITextField!
    @IBOutlet var lineView_UI:UIView!
    @IBOutlet weak var bottomView_UI: UIView!
}

class DetailViewControllerCustomTagCollectionViewCell: UICollectionViewCell {
    @IBOutlet var tagLabel_UI:UILabel!
}

class DetailViewController: UIViewController,UITextFieldDelegate,UNUserNotificationCenterDelegate {
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
    var tagsContainer:[Tags]{
        do{
            return try context.fetch(Tags.fetchRequest())
        }catch{
            print("Couldn't fetch data")
        }
        return [Tags]()
    }
    
    //<<---------------Variable---------------
    var todoSingle:TodoTask?
    var laterSingle:LaterTask?
    var completeSingle:CompleteTask?
    var index = IndexPath()
    var repeatButtonContainer:[UIButton] = []
    var tagString:String = "Add tags"
    var noteString:String = ""
    
    var repeatTimeTitleArr:[String] = ["Never","Day","Workday","Week","Month","Year"]
    var adjustTimeTitleArr:[String] = ["Later +3h","This Evening","Tomorrow","Sunday","This Weekend","Next Week","Unspecified","Pick A Date","5 seconds test"]
    var adjustTimeDarkTitleArr:[String] = ["Later +3h Dark","This Evening Dark","Tomorrow Dark","Sunday Dark","This Weekend Dark","Next Week Dark","Unspecified Dark","Pick A Date Dark","5 seconds test"]
    
    var selectedOptions:[Bool] = [false,false,false,false,false,false]
    
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.light))
    //0->todo,1->later,2->complete
    var currentTable = Int()
    var name = String()
    var repeatStr = String()
    var stepsArr = [String]()
    var selectedTagsArr = [String]()
    var moreStepsIsShowing = Bool()
    
    var originalStepsTableViewFrame = CGRect()
    var originalMoreStepsButtonFrame = CGRect()
    var newStepsTableViewFrame = CGRect()
    
    let textView = UITextView()
    let textViewRetrunButton = UIButton(type: .system)
    
    var selectedTagArrIndex = [Int]()
    
    var rotateAnimation = UIViewPropertyAnimator()
    
    var currentTimeContainer = timeSlicing()
    var newTimeContainer = timeSlicing()
    var thisMonthDays = Int()
    let weekday = Calendar.current.component(.weekday, from: Date())
    var date = String()
    var laterSorting:[LaterTask] = []
    
    let notificationCenter = UNUserNotificationCenter.current()
    let notificationContent = UNMutableNotificationContent()
    
    var fromAdjustView = false
    
    var filterText = String()
    var selectedFilterTagArr = [Int]()
    
    var selectedTimeContainer = timeSlicing()
    var calendarDayArr = [Int]()
    var preDateIndexPath = IndexPath()
    var fromTimeAdjustView = false
    var editingTaskIndex = IndexPath()
    
    var themeSwitcher = false
    //---------------Variable--------------->>

    //<<---------------UI---------------
    @IBOutlet weak var nameTxt_UI: UITextField!
    @IBOutlet weak var timeBtn_UI: UIButton!
    @IBOutlet weak var repeatBtn_UI: UIButton!
    @IBOutlet weak var tagButton_UI: UIButton!
    @IBOutlet weak var noteBtn_UI: UIButton!
    @IBOutlet weak var progress_UI: UIProgressView!
    @IBOutlet weak var progressBack_UI: UIView!
    @IBOutlet weak var namePoint_UI: UIButton!
    
    @IBOutlet weak var timeLabel_UI: UILabel!
    
    @IBOutlet weak var repeatTimeCollectionView_UI: UICollectionView!
    
    @IBOutlet weak var stepsTableView_UI: UITableView!
    
    @IBOutlet weak var moreStepsButton_UI: UIButton!
    @IBOutlet weak var moreStepsTextButton_UI: UIButton!
    
    @IBOutlet weak var addStepIconButton_UI: UIButton!
    @IBOutlet weak var addStepText_UI: UITextField!
    @IBOutlet weak var addStepIconTopView_UI: UIView!
    
    @IBOutlet weak var taskNameIconBottomView_UI: UIView!
    
    
    @IBOutlet weak var tagCollectionView_UI: UICollectionView!
    @IBOutlet weak var tagViewBackButton_UI: UIButton!
    @IBOutlet weak var tagViewTrashButton_UI: UIButton!
    
    @IBOutlet weak var timeAdjustCollectionView_UI: UICollectionView!
    
    @IBOutlet weak var calendarView_UI: UIView!
    @IBOutlet weak var calendarCollectionView_UI: UICollectionView!
    @IBOutlet weak var calendarViewBackButton_UI: UIButton!
    @IBOutlet weak var calendarViewConfirmButton_UI: UIButton!
    @IBOutlet weak var calendarViewPreMonthButton_UI: UIButton!
    @IBOutlet weak var calendarViewNextMonthButton_UI: UIButton!
    @IBOutlet weak var calendarViewDateButton_UI: UIButton!
    
    @IBOutlet weak var backButton_UI: UIButton!
    @IBOutlet weak var shareButton_UI: UIButton!
    @IBOutlet weak var deleteButton_UI: UIButton!
    
    @IBOutlet weak var addStepMaskView_UI: UIView!
    
    //---------------UI--------------->>
    
    //<<---------------Action---------------
    @IBAction func shareBtn_Action(_ sender: Any) {
        let activityController: UIActivityViewController
        if self.todoSingle != nil{
            let name = self.todoSingle?.name
            activityController = UIActivityViewController(activityItems: [name ?? "-"], applicationActivities: nil)
        }else if self.laterSingle != nil{
            let name = self.laterSingle?.name
            activityController = UIActivityViewController(activityItems: [name ?? "-"], applicationActivities: nil)
        }else{
            let name = self.completeSingle?.name
            activityController = UIActivityViewController(activityItems: [name ?? "-"], applicationActivities: nil)
        }
        self.present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func deleteBtn_Action(_ sender: Any) {
        let alert = UIAlertController(title: "Delete 1 task", message: "Are you sure you want to permanently delete this task?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            (alert) in
            switch self.currentTable{
            case 0:
                let item = self.todoSingle
                self.context.delete(item!)
            case 1:
                let item = self.laterSingle
                let viewcontroller = ViewController()
                viewcontroller.removeNotification(identifiers: [(String(item!.position))])
                self.context.delete(item!)
            case 2:
                let item = self.completeSingle
                self.context.delete(item!)
            default:
                break
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "viewController") as? ViewController{
                vc.currentTable = self.currentTable
                self.present(vc, animated: true, completion: nil)
            }
        }))
        present(alert,animated: true,completion: nil)
    }
    
    @IBAction func backBtn_Action(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "viewController") as? ViewController{
            switch currentTable{
            case 0:
                vc.currentTable = 0
            case 1:
                vc.currentTable = 1
            case 2:
                vc.currentTable = 2
            default:
                break
            }
            vc.filterText = filterText
            vc.selectedFilterTagArr = selectedFilterTagArr
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func repeatBtn_Action(_ sender: Any) {
        if repeatBtn_UI.isSelected == false {
            repeatBtn_UI.isSelected = true
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                self.repeatTimeCollectionView_UI.alpha = 1
                self.tagButton_UI.transform = CGAffineTransform(translationX: 0.0, y: self.tagButton_UI.frame.height)
                self.noteBtn_UI.transform = CGAffineTransform(translationX: 0.0, y: self.noteBtn_UI.frame.height)
            }, completion: nil)
        }else{
            repeatBtn_UI.isSelected = false
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                self.repeatTimeCollectionView_UI.alpha = 0
                self.tagButton_UI.transform = CGAffineTransform(translationX: 0.0, y: -self.tagButton_UI.frame.height+30)
                self.noteBtn_UI.transform = CGAffineTransform(translationX: 0.0, y: -self.noteBtn_UI.frame.height+30)
            }, completion: nil)
        }
    }
    
    @IBAction func timeBtn_Action(_ sender: Any) {
        showTimeAdjustCollectionView()
    }
    
    
    @IBAction func moreStepsButton_Action(_ sender: Any) {
        if moreStepsButton_UI.isSelected{
            hideMoreSteps()
        }else{
            showMoreSteps()
        }
    }
    
    @IBAction func moreStepsTextButton_Action(_ sender: Any) {
        if moreStepsTextButton_UI.isSelected {
            hideMoreSteps()
        }else{
            showMoreSteps()
        }
    }
    
    @IBAction func noteButton_Action(_ sender: Any) {
        if noteString != ""{
            textView.text = noteString
        }
        self.textView.isHidden = false
        self.textViewRetrunButton.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.textView.alpha = 1
            self.textViewRetrunButton.alpha = 1
        }
        textView.becomeFirstResponder()
    }
    
    @IBAction func tagButton_Action(_ sender: Any) {
        //cancel
        if tagButton_UI.isSelected == true{
            hideTagView()
        }
        //touch
        else{
            showTagView()
        }
    }
    
    @IBAction func tagViewBackButton_Action(_ sender: Any) {
        hideTagView()
    }
    
    @IBAction func tagViewTrashButton_Action(_ sender: Any) {
        //not selected
        if tagViewTrashButton_UI.isSelected == true {
            tagIsNotEditing()
        }
        //selected
        else{
            tagIsEditing()
        }
        
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
    @IBAction func calendarViewPreMonthButton_Action(_ sender: Any) {
        showPreMonthCalendarCollectionView()
    }
    @IBAction func calendarViewNextMonthButton_Action(_ sender: Any) {
        showNextMonthCalendarCollectionView()
    }
    @IBAction func calendarViewDateButton_Action(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "timeAdjustViewController") as! TimeAdjustViewController
        vc.preTimeContainer = selectedTimeContainer
        vc.fromDateView = true
        vc.currentTable = currentTable
        vc.editingTaskIndex = editingTaskIndex
        vc.adjustTimeType = 7
        vc.previousController = 1
        switch currentTable {
        case 0:
            vc.todoSingle = todoSingle
        case 1:
            vc.laterSingle = laterSingle
        case 2:
            vc.completeSingle = completeSingle
        default:
            break
        }
        present(vc,animated: false,completion: nil)
    }
    
    //---------------Action--------------->>
    
    //<<---------------viewDidLoad---------------
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
        themeSwitcher = UserDefaults.standard.bool(forKey:"theme")
        //---------Get users defalut options setting--------->>
        
        switch themeSwitcher {
        case true:
            view.backgroundColor = UIColor(named: "DarkColor")
            stepsTableView_UI.backgroundColor = UIColor(named: "DarkColor")
            addStepMaskView_UI.backgroundColor = UIColor(named: "DarkColor")
            tagCollectionView_UI.backgroundColor = UIColor(named: "BlurDarkColor")
            textView.backgroundColor = UIColor(named: "DarkColor")
            timeAdjustCollectionView_UI.backgroundColor = UIColor(named: "DarkColor")
            repeatTimeCollectionView_UI.backgroundColor = UIColor(named: "DarkColor")
            
            backButton_UI.tintColor = .white
            shareButton_UI.tintColor = .white
            deleteButton_UI.tintColor = .white
            moreStepsButton_UI.tintColor = .white
            moreStepsTextButton_UI.tintColor = .white
            tagViewBackButton_UI.tintColor = .white
            tagViewTrashButton_UI.tintColor = .white
            textViewRetrunButton.tintColor = .white
            
            timeBtn_UI.setTitleColor(.white, for: .normal)
            noteBtn_UI.setTitleColor(.white, for: .normal)
            repeatBtn_UI.setTitleColor(.white, for: .normal)
            tagButton_UI.setTitleColor(.white, for: .normal)
            moreStepsTextButton_UI.setTitleColor(.white, for: .normal)
            
            nameTxt_UI.textColor = .white
            addStepText_UI.textColor = .white
            textView.textColor = .white
            
            addStepText_UI.attributedPlaceholder = NSAttributedString(string: "Add action step",attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            
            addStepIconButton_UI.layer.borderColor = UIColor.white.cgColor
            
            calendarView_UI.backgroundColor = UIColor(named: "DarkColor")
            calendarCollectionView_UI.backgroundColor = UIColor(named: "DarkColor")
            calendarViewBackButton_UI.tintColor = UIColor.white
            calendarViewConfirmButton_UI.tintColor = UIColor.white
            calendarViewPreMonthButton_UI.tintColor = UIColor.white
            calendarViewNextMonthButton_UI.tintColor = UIColor.white
            calendarViewDateButton_UI.setTitleColor(UIColor.white, for: .normal)
            
        case false:
            shareButton_UI.tintColor = .black
            deleteButton_UI.tintColor = .black
            moreStepsButton_UI.tintColor = .black
            moreStepsTextButton_UI.tintColor = .black
            
            tagViewBackButton_UI.tintColor = .black
            tagViewTrashButton_UI.tintColor = .black
            
            textViewRetrunButton.tintColor = .black
            
            backButton_UI.tintColor = .black
        }
        
        moreStepsButton_UI.layer.masksToBounds = true
        moreStepsButton_UI.layer.cornerRadius = 15
        
        currentTimeContainer = timeStampSlicing(timeStamp: String(getCurrentStamp()))
        
        //timeAdjustCollectionView_UI
        timeAdjustCollectionView_UI.roundCorners([.topLeft,.topRight,.bottomLeft,.bottomRight], radius: 30)
        let timeAdjustLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(timeAdjustLongPressed(sender:)))
        timeAdjustCollectionView_UI.addGestureRecognizer(timeAdjustLongPressRecognizer)
        
        //keyboard
        let center:NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //Note edit components
        textView.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: view.bounds.width, height: view.bounds.height)
        textViewRetrunButton.frame = CGRect(x: view.bounds.width - 50, y: view.bounds.height - 50, width: 30, height: 30)
        textViewRetrunButton.setImage(UIImage(named: "arrowRight"), for: .normal)
        textViewRetrunButton.addTarget(self, action: #selector(textViewEditEnd(button:)), for: .touchUpInside)
        textView.isHidden = true
        textViewRetrunButton.isHidden = true
        view.addSubview(textView)
        view.addSubview(textViewRetrunButton)
        
        self.hideKeyboardWhenTappedAround()
        
        nameTxt_UI.delegate = self
        
        originalStepsTableViewFrame = stepsTableView_UI.frame
        originalMoreStepsButtonFrame = moreStepsButton_UI.frame
        
        //blurView
        view.addSubview(blurView)
        blurView.isHidden = true
        blurView.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height)
        let blurViewTap = UITapGestureRecognizer(target: self, action: #selector(blurClick(tap:)))
        blurView.addGestureRecognizer(blurViewTap)

        repeatTimeCollectionView_UI.alpha = 0
        
        addStepText_UI.delegate = self
        addStepTextIsNotFirstResponderStatus()
        addStepText_UI.addTarget(self, action: #selector(addStepTextFieldIsFirstResponder(_:)), for: .editingDidBegin)
        
        switch currentTable {
        case 0:
            progress_UI.progress = 0.005
            progress_UI.tintColor = UIColor(named: "TodoColor")
            progress_UI.backgroundColor = UIColor.white
            progressBack_UI.backgroundColor = UIColor(named: "TodoColor")
            namePoint_UI.setImage(UIImage(named: "point"), for: .normal)
            taskNameIconBottomView_UI.backgroundColor = UIColor(named: "TodoColor")
            addStepIconTopView_UI.backgroundColor = UIColor(named: "TodoColor")
            //taskId
            currentTable = 0
            //name
            name = todoSingle!.name!
            //Time
            let todoTimeContainer = timeStampSlicing(timeStamp: String(todoSingle!.time))
            if currentTimeContainer.day == todoTimeContainer.day{
                timeBtn_UI.setTitle("Today \(todoTimeContainer.hour):\(todoTimeContainer.minute)", for: .normal)
            }else if Int(currentTimeContainer.day)! + 1 == Int(todoTimeContainer.day){
                timeBtn_UI.setTitle("Tomorrow \(todoTimeContainer.hour):\(todoTimeContainer.minute)", for: .normal)
            }else if Int(currentTimeContainer.day)! - 1 == Int(todoTimeContainer.day){
                timeBtn_UI.setTitle("Yesterday \(todoTimeContainer.hour):\(todoTimeContainer.minute)", for: .normal)
            }else if todoSingle?.time == 2147483647{
                repeatBtn_UI.isEnabled = false
                timeBtn_UI.setTitle("UNSPECIFIED", for: .normal)
            }else{
                timeBtn_UI.setTitle("\(convertEnglishMonth(month: Int(todoTimeContainer.month)!)) \(todoTimeContainer.day),  \(todoTimeContainer.hour):\(todoTimeContainer.minute)", for: .normal)
            }
            //Tag
            selectedTagsArr = todoSingle!.tags!
            //step arr
            stepsArr = todoSingle!.steps!
            
            repeatStr = todoSingle!.repeatInterval!
            
            //note
            noteString = todoSingle!.note!
        case 1:
            progress_UI.progress = 100.0
            progress_UI.tintColor = UIColor(named: "LaterColor")
            progress_UI.backgroundColor = UIColor(named: "LaterColor")
            progressBack_UI.backgroundColor = UIColor(named: "LaterColor")
            namePoint_UI.setImage(UIImage(named: "laterPoint"), for: .normal)
            taskNameIconBottomView_UI.backgroundColor = UIColor(named: "LaterColor")
            addStepIconTopView_UI.backgroundColor = UIColor(named: "LaterColor")
            //taskId
            currentTable = 1
            //name
            name = laterSingle!.name!
            //Time
            let laterTimeContainer = timeStampSlicing(timeStamp: String(laterSingle!.time))
            if currentTimeContainer.day == laterTimeContainer.day{
                timeBtn_UI.setTitle("Today \(laterTimeContainer.hour):\(laterTimeContainer.minute)", for: .normal)
            }else if Int(currentTimeContainer.day)! + 1 == Int(laterTimeContainer.day){
                timeBtn_UI.setTitle("Tomorrow \(laterTimeContainer.hour):\(laterTimeContainer.minute)", for: .normal)
            }else if Int(currentTimeContainer.day)! - 1 == Int(laterTimeContainer.day){
                timeBtn_UI.setTitle("Yesterday \(laterTimeContainer.hour):\(laterTimeContainer.minute)", for: .normal)
            }else if laterSingle?.time == 2147483647{
                repeatBtn_UI.isEnabled = false
                timeBtn_UI.setTitle("UNSPECIFIED", for: .normal)
            }else{
                timeBtn_UI.setTitle("\(convertEnglishMonth(month: Int(laterTimeContainer.month)!)) \(laterTimeContainer.day),  \(laterTimeContainer.hour):\(laterTimeContainer.minute)", for: .normal)
            }
            //tag
            selectedTagsArr = laterSingle!.tags!
            //step
            stepsArr = laterSingle!.steps!
            repeatStr = laterSingle!.repeatInterval!
            //note
            noteString = laterSingle!.note!
        case 2:
            progress_UI.progress = 100.0
            progress_UI.tintColor = UIColor(named: "CompleteColor")
            progress_UI.backgroundColor = UIColor(named: "CompleteColor")
            progressBack_UI.backgroundColor = UIColor(named: "CompleteColor")
            namePoint_UI.setImage(UIImage(named: "completePoint"), for: .normal)
            taskNameIconBottomView_UI.backgroundColor = UIColor(named: "CompleteColor")
            addStepIconTopView_UI.backgroundColor = UIColor(named: "CompleteColor")
            //taskId
            currentTable = 2
            //name
            name = completeSingle!.name!
            //Time
            let completeTimeContainer = timeStampSlicing(timeStamp: String(completeSingle!.time))
            if currentTimeContainer.day == completeTimeContainer.day{
                timeBtn_UI.setTitle("Today \(completeTimeContainer.hour):\(completeTimeContainer.minute)", for: .normal)
            }else if Int(currentTimeContainer.day)! + 1 == Int(completeTimeContainer.day){
                timeBtn_UI.setTitle("Tomorrow \(completeTimeContainer.hour):\(completeTimeContainer.minute)", for: .normal)
            }else if Int(currentTimeContainer.day)! - 1 == Int(completeTimeContainer.day){
                timeBtn_UI.setTitle("Yesterday \(completeTimeContainer.hour):\(completeTimeContainer.minute)", for: .normal)
            }else if completeSingle?.time == 2147483647{
                repeatBtn_UI.isEnabled = false
                timeBtn_UI.setTitle("UNSPECIFIED", for: .normal)
            }else{
                timeBtn_UI.setTitle("\(convertEnglishMonth(month: Int(completeTimeContainer.month)!)) \(completeTimeContainer.day),  \(completeTimeContainer.hour):\(completeTimeContainer.minute)", for: .normal)
            }
            //tag
            selectedTagsArr = completeSingle!.tags!
            //step
            stepsArr = completeSingle!.steps!
            
            repeatBtn_UI.isEnabled = false
            
            repeatStr = completeSingle!.repeatInterval!
            
            //note
            noteString = completeSingle!.note!
        default:
            break
        }
        //name
        nameTxt_UI.text = name
        
        //more steps button
        moreStepsTextButton_UI.setTitle("See all \(stepsArr.count) actions", for: .normal)
        
        //handle selected tags Index
        for i in 0..<selectedTagsArr.count{
            for j in 0..<tagsContainer.count{
                if selectedTagsArr[i] == tagsContainer[j].tags{
                    selectedTagArrIndex.append(j)
                    break
                }
            }
        }
        
        //tag
        sortTagsBaseTagArrIndex()
        
        repeatBtn_UI.setTitle(repeatStr, for: .normal)
        repeatBtn_UI.setTitle("Repeat every", for: .selected)

        //note
        if noteString != "" {
            noteBtn_UI.setTitle(noteString, for: .normal)
        }
        
        tagCollectionView_UI.reloadData()
        
    }
    
    //---------------viewDidLoad--------------->>
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self,name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.removeObserver(self,name: UIResponder.keyboardWillHideNotification,object: nil)
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
                            vc.currentTable = currentTable
                            vc.todoSingle = todoSingle!
                        case 1:
                            vc.currentTable = currentTable
                            vc.laterSingle = laterSingle!
                        case 2:
                            vc.currentTable = currentTable
                            vc.completeSingle = completeSingle!
                        default:
                            break
                        }
                        vc.previousController = 1
                        self.present(vc,animated: true,completion: nil)
                    }
                }
            }
        }
    }
    
    @objc func keyboardDidShow(notification:Notification){
        let info:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if textView.isFirstResponder{
            if keyboardSize.minY < textViewRetrunButton.frame.maxY{
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                    self.textViewRetrunButton.transform = self.textViewRetrunButton.transform.translatedBy(x: 0, y: -(self.textViewRetrunButton.frame.maxY - keyboardSize.minY))
                }, completion: nil)
            }
        }
        
    }
    
    @objc func keyboardWillHide(notification:Notification){
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
    }
    
    @objc func textViewEditEnd(button:UIButton){
        noteString = textView.text
        switch currentTable{
        case 0:
            todoSingle!.note = noteString
        case 1:
            laterSingle!.note = noteString
        case 2:
            completeSingle!.note = noteString
        default:
            break
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        textView.resignFirstResponder()
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.textView.alpha = 0
            self.textViewRetrunButton.alpha = 0
        }) { (true) in
            self.textView.isHidden = true
            self.textViewRetrunButton.isHidden = true
        }
        if noteString == ""{
            noteBtn_UI.setTitle("Add notes", for: .normal)
        }else{
            noteBtn_UI.setTitle(noteString, for: .normal)
        }
    }
    
    @objc func blurClick(tap:UITapGestureRecognizer){
        if timeBtn_UI.isSelected {
            hideCalendarView()
            hideTimeAdjustCollectionView()
        }else if tagButton_UI.isSelected{
            hideTagView()
        }
        
    }
    
    @objc func addStepTextFieldIsFirstResponder(_ textField: UITextField) {
        if addStepText_UI.isFirstResponder{
            addStepTextIsFirstResponderStatus()
        }else{
            addStepTextIsNotFirstResponderStatus()
        }
        if moreStepsIsShowing == false {
            self.showMoreSteps()
        }
    }
    
    func sortTagsBaseTagArrIndex() {
        selectedTagsArr.removeAll()
        for i in 0..<selectedTagArrIndex.count{
            let item = tagsContainer[selectedTagArrIndex[i]].tags
            selectedTagsArr.append(item!)
        }
        
        //tag
        if self.selectedTagsArr.count == 0{
            self.tagButton_UI.setTitle("Add Tags", for: .normal)
        }else{
            self.tagString = ""
            for i in 0..<self.selectedTagsArr.count{
                var newStr = self.selectedTagsArr[i]
                if i == (self.selectedTagsArr.count) - 1{
                    newStr = "\(self.selectedTagsArr[i])"
                }else{
                    newStr = "\(self.selectedTagsArr[i]),"
                }
                self.tagString = self.tagString + newStr
            }
            self.tagButton_UI.setTitle(self.tagString, for: .normal)
        }
        
        print(selectedTagsArr)
        
        switch self.currentTable{
        case 0:
            self.todoSingle!.tags! = selectedTagsArr
        case 1:
            self.laterSingle!.tags! = selectedTagsArr
        case 2:
            self.completeSingle!.tags! = selectedTagsArr
        default:
            break
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func addTagHandler() {
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
                for i in 0..<self.tagsContainer.count{
                    if self.tagsContainer[i].tags == text{
                        tagExist = true
                        //两个都选中的情况
                        //已经选中的情况 不要重复添加 移除
                        if self.selectedTagArrIndex.contains(i){
                            let index = self.selectedTagArrIndex.firstIndex(of: i)
                            self.selectedTagArrIndex.remove(at: index!)
                        }else{
                            self.selectedTagArrIndex.append(i)
                        }
                        break
                    }
                }
                if tagExist == false{
                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    let container = Tags(context: context)
                    container.tags = text
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                }
                //sort
                self.selectedTagArrIndex.sort(by:<)
                self.tagCollectionView_UI.reloadData()
                self.dynamicCollectionViewHeight()
            }
        }))
        present(alertView,animated: true,completion: nil)
    }
    
    func showTimeAdjustCollectionView() {
        timeBtn_UI.isSelected = true
        blurView.isHidden = false
        timeAdjustCollectionView_UI.isHidden = false
        timeLabel_UI.isHidden = false
        timeAdjustCollectionView_UI.alpha = 0
        timeLabel_UI.alpha = 0
        view.bringSubviewToFront(timeLabel_UI)
        view.bringSubviewToFront(timeAdjustCollectionView_UI)
        UIView.animate(withDuration: 0.05, delay: 0, options: .curveEaseIn, animations: {
            self.blurView.alpha = 1
        }) { (true) in
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                self.timeAdjustCollectionView_UI.alpha = 1
                self.timeLabel_UI.alpha = 1
            }, completion: nil)
        }
    }
    
    func hideTimeAdjustCollectionView() {
        timeBtn_UI.isSelected = false
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.timeLabel_UI.alpha = 0
            self.timeAdjustCollectionView_UI.alpha = 0
        }) { (true) in
            self.timeLabel_UI.isHidden = true
            self.timeAdjustCollectionView_UI.isHidden = true
            UIView.animate(withDuration: 0.05, delay: 0, options: .curveEaseIn, animations: {
                self.blurView.alpha = 0
            }, completion: { (true) in
                self.blurView.isHidden = true
            })
        }
    }
    
    func dynamicCollectionViewHeight() {
        let maxWidth = view.frame.width
        var tagCollectionViewItemWidthArr = [CGFloat]()
        var rowWidth = CGFloat()
        var rowCount = 1
        for i in 0..<tagsContainer.count{
            let itemWidth = tagsContainer[i].tags!.count * 15
            tagCollectionViewItemWidthArr.append(CGFloat(itemWidth))
        }
        for i in 0..<tagCollectionViewItemWidthArr.count{
            rowWidth = rowWidth+tagCollectionViewItemWidthArr[i] + 50
            if rowWidth > maxWidth{
                rowWidth = tagCollectionViewItemWidthArr[i] + 50
                rowCount += 1
            }
        }
        UIView.animate(withDuration: 0.25) {
            self.tagCollectionView_UI.constraints[self.tagCollectionView_UI.constraints.count-1].constant = CGFloat(rowCount * 30 + 10)
        }
    }
    
    func showTagView() {
        tagButton_UI.isSelected = true
        blurView.isHidden = false
        tagCollectionView_UI.isHidden = false
        tagViewBackButton_UI.isHidden = false
        tagViewTrashButton_UI.isHidden = false
        blurView.alpha = 0
        tagCollectionView_UI.alpha = 0
        tagViewBackButton_UI.alpha = 0
        tagViewTrashButton_UI.alpha = 0
        UIView.animate(withDuration: 0.05, delay: 0, options: .curveEaseIn, animations: {
            self.blurView.alpha = 1
            self.view.bringSubviewToFront(self.tagCollectionView_UI)
            self.view.bringSubviewToFront(self.tagViewBackButton_UI)
            self.view.bringSubviewToFront(self.tagViewTrashButton_UI)
        }) { (true) in
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                self.tagCollectionView_UI.alpha = 1
                self.tagViewBackButton_UI.alpha = 1
                self.tagViewTrashButton_UI.alpha = 1
            }, completion: nil)
        }
        
        dynamicCollectionViewHeight()
    }
    
    func hideTagView() {
        tagButton_UI.isSelected = false
        tagIsNotEditing()
        sortTagsBaseTagArrIndex()
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.tagCollectionView_UI.alpha = 0
            self.tagViewBackButton_UI.alpha = 0
            self.tagViewTrashButton_UI.alpha = 0
        }) { (true) in
            self.tagCollectionView_UI.isHidden = true
            self.tagViewBackButton_UI.isHidden = true
            self.tagViewTrashButton_UI.isHidden = true
            UIView.animate(withDuration: 0.05, delay: 0, options: .curveEaseIn, animations: {
                self.blurView.alpha = 0
            }, completion: { (true) in
                self.blurView.isHidden = true
            })
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.blurView.alpha = 0
        }) { (true) in
            self.blurView.isHidden = true
        }
    }
    
    func updateSteps() {
        var newStepArr = [String]()
        for i in 0..<stepsTableView_UI.numberOfRows(inSection: 0){
            let cell = stepsTableView_UI.cellForRow(at: IndexPath(row: i, section: 0)) as! detailCustomeTableViewCell
            if i == stepsTableView_UI.numberOfRows(inSection: 0){
                cell.stepTxt_UI.text = ""
            }
            let newStepStr = cell.stepTxt_UI.text
            if newStepStr == ""{
                continue
            }
            newStepArr.append(newStepStr!)
        }
        if addStepText_UI.text != ""{
            newStepArr.append(addStepText_UI.text!)
        }
        switch currentTable{
        case 0:
            todoSingle?.steps = newStepArr
        case 1:
            laterSingle?.steps = newStepArr
        case 2:
            completeSingle?.steps = newStepArr
        default:
            break
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        stepsArr = newStepArr
        
        let numberOfSteps = stepsArr.count + 1
        var height = numberOfSteps * 30
        if height > Int(view.frame.maxY - originalStepsTableViewFrame.maxY){
            height = Int(view.frame.maxY - originalStepsTableViewFrame.maxY - 50)
        }
        stepsTableView_UI.reloadData()
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
            self.stepsTableView_UI.constraints[4].constant = CGFloat(height)
        }
        
        moreStepsTextButton_UI.setTitle("See all \(stepsArr.count) actions", for: .normal)
    }
    
    func addStepTextIsNotFirstResponderStatus() {
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
            self.addStepIconButton_UI.layer.masksToBounds = true
            self.addStepIconButton_UI.layer.cornerRadius = 5.0
            switch self.themeSwitcher{
            case true:
                self.addStepIconButton_UI.layer.borderColor = UIColor.white.cgColor
                self.addStepIconButton_UI.setTitleColor(.white, for: .normal)
                self.addStepText_UI.attributedPlaceholder = NSAttributedString(string: "Add action step",attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            case false:
                self.addStepIconButton_UI.layer.borderColor = UIColor(named: "DarkColor")?.cgColor
                self.addStepIconButton_UI.setTitleColor(UIColor(named: "DarkColor"), for: .normal)
                self.addStepText_UI.attributedPlaceholder = NSAttributedString(string: "Add action step",attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "DarkColor")!])
            }
            self.addStepIconButton_UI.layer.borderWidth = 1.0
            self.addStepIconButton_UI.setTitle("+", for: .normal)
        }
    }
    
    func tagIsNotEditing() {
        tagViewTrashButton_UI.setImage(UIImage(named: "trash"), for: .normal)
        tagViewTrashButton_UI.isSelected = false
//        for i in 0..<tagsContainer.count{
//            tagCollectionView_UI.reloadItems(at: [IndexPath(row: i, section: 0)])
//        }
        tagCollectionView_UI.reloadData()
    }
    
    func tagIsEditing() {
        tagViewTrashButton_UI.setImage(UIImage(named: "cancel_bold"), for: .normal)
        tagViewTrashButton_UI.isSelected = true
        for i in 0..<tagsContainer.count{
            tagCollectionView_UI.reloadItems(at: [IndexPath(row: i, section: 0)])
            let cell = tagCollectionView_UI.cellForItem(at: IndexPath(row: i, section: 0)) as! DetailViewControllerCustomTagCollectionViewCell
            rotateAnimationLoop(cell: cell.tagLabel_UI)
        }
    }
    
    func addStepTextIsFirstResponderStatus() {
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
            self.addStepIconButton_UI.layer.masksToBounds = true
            self.addStepIconButton_UI.layer.cornerRadius = 5.0
            switch self.currentTable{
            case 0:
                self.addStepIconButton_UI.layer.borderColor = UIColor(named: "TodoColor")?.cgColor
            case 1:
                self.addStepIconButton_UI.layer.borderColor = UIColor(named: "LaterColor")?.cgColor
            case 2:
                self.addStepIconButton_UI.layer.borderColor = UIColor(named: "CompleteColor")?.cgColor
            default:
                break
            }
            self.addStepIconButton_UI.layer.borderWidth = 3.0
            self.addStepIconButton_UI.setTitle("", for: .normal)
            self.addStepText_UI.placeholder = ""
        }
    }
    
    func hideMoreSteps() {
        moreStepsButton_UI.isSelected = false
        moreStepsTextButton_UI.isSelected  = false
        stepsTableView_UI.isScrollEnabled = false
        moreStepsIsShowing = false
        addStepText_UI.resignFirstResponder()
        addStepTextIsNotFirstResponderStatus()
        self.stepsTableView_UI.reloadData()
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
            self.moreStepsButton_UI.alpha = 0
            self.stepsTableView_UI.constraints[4].constant = 90
            self.moreStepsButton_UI.frame = CGRect(x: self.originalMoreStepsButtonFrame.minX, y: self.originalStepsTableViewFrame.maxY + 5, width: self.moreStepsButton_UI.frame.width, height: self.moreStepsButton_UI.frame.height)
        }) { (true) in
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.moreStepsButton_UI.transform = self.moreStepsButton_UI.transform.rotated(by: -CGFloat(Double.pi))
                self.timeBtn_UI.alpha = 1
                self.noteBtn_UI.alpha = 1
                self.tagButton_UI.alpha = 1
                self.repeatBtn_UI.alpha = 1
                self.moreStepsTextButton_UI.alpha = 1
                self.moreStepsButton_UI.alpha = 1
            })
        }
    }
    
    func showMoreSteps() {
        moreStepsButton_UI.isSelected = true
        moreStepsTextButton_UI.isSelected  = true
        stepsTableView_UI.isScrollEnabled = true
        moreStepsIsShowing = true
        let numberOfSteps = stepsArr.count + 1
        var height = numberOfSteps * 30
        if height > Int(view.frame.maxY - originalStepsTableViewFrame.maxY){
            height = Int(view.frame.maxY - originalStepsTableViewFrame.maxY - 50)
        }
        self.stepsTableView_UI.reloadData()
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
            self.moreStepsButton_UI.transform = self.moreStepsButton_UI.transform.rotated(by: CGFloat(Double.pi))
            self.moreStepsButton_UI.alpha = 0
            self.moreStepsTextButton_UI.alpha = 0
        }) { (true) in
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.timeBtn_UI.alpha = 0
                self.noteBtn_UI.alpha = 0
                self.tagButton_UI.alpha = 0
                self.repeatBtn_UI.alpha = 0
                self.repeatTimeCollectionView_UI.alpha = 0
                self.moreStepsButton_UI.alpha = 1
                self.stepsTableView_UI.constraints[4].constant = CGFloat(height)
                self.moreStepsButton_UI.frame = CGRect(x: self.originalMoreStepsButtonFrame.minX, y: self.stepsTableView_UI.frame.maxY + 5, width: self.moreStepsButton_UI.frame.width, height: self.moreStepsButton_UI.frame.height)
            })
        }
    }
    
    func showCalendarView() {
        if fromTimeAdjustView == false {
            selectedTimeContainer = timeStampSlicing(timeStamp: String(getCurrentStamp()))
        }
        if selectedTimeContainer.month.count < 2 {
            selectedTimeContainer.month = "0\(selectedTimeContainer.month)"
        }
        if selectedTimeContainer.day.count < 2{
            selectedTimeContainer.day = "0\(selectedTimeContainer.day)"
        }
        if selectedTimeContainer.hour.count < 2{
            selectedTimeContainer.hour = "0\(selectedTimeContainer.hour)"
        }
        if selectedTimeContainer.minute.count < 2{
            selectedTimeContainer.minute = "0\(selectedTimeContainer.minute)"
        }
        if Int(selectedTimeContainer.month) == Int(currentTimeContainer.month){
            calendarViewPreMonthButton_UI.isEnabled = false
        }else{
            calendarViewPreMonthButton_UI.isEnabled = true
        }
        if Int(selectedTimeContainer.minute)! - 5 <= Int(currentTimeContainer.minute)!{
            selectedTimeContainer.minute = String(Int(selectedTimeContainer.minute)!+5)
        }
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
        laterSorting = laterTaskContainer
        laterSorting.sort { (p1, p2) -> Bool in
            return p2.position > p1.position
        }
        var position = Int()
        if self.laterTaskContainer.count == 0{
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
        let notificationId = Int32(position)
        let notificationTimeInterval = dateToTimeStamp(date: date) - getCurrentStamp()
        switch currentTable {
        case 0:
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let container = LaterTask(context: context)
            let item = todoSingle
            notificationTitle = item!.name!
            container.name = item?.name
            container.note = item?.note
            container.repeatInterval = item?.repeatInterval
            container.status = item?.status
            container.steps = item?.steps
            container.tags = item?.tags
            container.time = Int32(dateToTimeStamp(date: date))
            container.position = Int32(position)
            self.context.delete(item!)
        case 1:
            let item = laterSingle
            let vc = storyboard?.instantiateViewController(withIdentifier: "viewController") as! ViewController
            vc.notificationIdArr.append(String(item!.position))
            vc.removeNotification(identifiers: vc.notificationIdArr)
            vc.notificationIdArr.removeAll()
            notificationTitle = item!.name!
            item?.time = Int32(dateToTimeStamp(date: date))
            item?.position = Int32(position)
        case 2:
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let container = LaterTask(context: context)
            let item = completeSingle
            notificationTitle = item!.name!
            container.name = item?.name
            container.note = item?.note
            container.repeatInterval = item?.repeatInterval
            container.status = item?.status
            container.steps = item?.steps
            container.tags = item?.tags
            container.time = Int32(dateToTimeStamp(date: date))
            container.position = Int32(position)
            self.context.delete(item!)
        default:
            break
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        let viewController = ViewController()
        viewController.prepareTodoLaterTask()
        viewController.setTimerForFirstLaterTask()
        //<<------------register notification------------
        if let vc = storyboard?.instantiateViewController(withIdentifier: "viewController") as? ViewController{
            vc.notificationContent.title = notificationTitle
            vc.notificationContent.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(notificationTimeInterval), repeats: false)
            let request = UNNotificationRequest(identifier: "\(notificationId)", content: vc.notificationContent, trigger: trigger)
            vc.notificationCenter.add(request) { (true) in
                print("registered")
            }
        }
        //------------register notification------------>>
        currentTable = 1
        laterSorting = laterTaskContainer
        laterSorting.sort { (p1, p2) -> Bool in
            return p2.position > p1.position
        }
        if self.selectedOptions[0] == false{
            //Insert at begining
            laterSingle = laterSorting[0]
        }else{
            //Append at ending
            laterSingle = laterSorting[laterSorting.count]
        }
        progress_UI.progress = 100.0
        progress_UI.tintColor = UIColor(named: "LaterColor")
        progress_UI.backgroundColor = UIColor(named: "LaterColor")
        progressBack_UI.backgroundColor = UIColor(named: "LaterColor")
        namePoint_UI.setImage(UIImage(named: "laterPoint"), for: .normal)
        taskNameIconBottomView_UI.backgroundColor = UIColor(named: "LaterColor")
        addStepIconTopView_UI.backgroundColor = UIColor(named: "LaterColor")
        //Time
        let laterTimeContainer = timeStampSlicing(timeStamp: String(laterSingle!.time))
        if currentTimeContainer.day == laterTimeContainer.day{
            timeBtn_UI.setTitle("Today \(laterTimeContainer.hour):\(laterTimeContainer.minute)", for: .normal)
        }else if Int(currentTimeContainer.day)! + 1 == Int(laterTimeContainer.day){
            timeBtn_UI.setTitle("Tomorrow \(laterTimeContainer.hour):\(laterTimeContainer.minute)", for: .normal)
        }else if Int(currentTimeContainer.day)! - 1 == Int(laterTimeContainer.day){
            timeBtn_UI.setTitle("Yesterday \(laterTimeContainer.hour):\(laterTimeContainer.minute)", for: .normal)
        }else if laterSingle?.time == 2147483647{
            repeatBtn_UI.isEnabled = false
            timeBtn_UI.setTitle("UNSPECIFIED", for: .normal)
        }else{
            timeBtn_UI.setTitle("\(convertEnglishMonth(month: Int(laterTimeContainer.month)!)) \(laterTimeContainer.day),  \(laterTimeContainer.hour):\(laterTimeContainer.minute)", for: .normal)
        }
        tagCollectionView_UI.reloadData()
        stepsTableView_UI.reloadData()
        hideTimeAdjustCollectionView()
    }
    
    func hideCalendarView() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.calendarView_UI.alpha = 0
        }) { (true) in
            self.calendarView_UI.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if nameTxt_UI.isFirstResponder{
            if nameTxt_UI.text == ""{
                nameTxt_UI.text = name
            }else{
                switch currentTable{
                case 0:
                    todoSingle?.name = nameTxt_UI.text
                case 1:
                    laterSingle?.name = nameTxt_UI.text
                case 2:
                    completeSingle?.name = nameTxt_UI.text
                default:
                    break
                }
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
            nameTxt_UI.resignFirstResponder()
        }else if addStepText_UI.isFirstResponder{
            if addStepText_UI.text == ""{
                //输入为空表示要收回steps table
                //如果
                addStepText_UI.resignFirstResponder()
                addStepTextIsNotFirstResponderStatus()
                hideMoreSteps()
            }else{
                updateSteps()
                addStepText_UI.text = ""
            }
        }else{
            updateSteps()
        }
        return true
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
    
    func rotateAnimationLoop(cell:UILabel) {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.repeat,.autoreverse], animations: {
            cell.transform = .init(rotationAngle: 0.05)
            cell.transform = .init(rotationAngle: -0.05)
        }, completion: {(true) in
            cell.transform = .identity
        })
    }
    
    
    
}
//<<------------------------Table View Extension------------------------
extension DetailViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stepsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! detailCustomeTableViewCell
        cell.selectedBackgroundView = UIView()
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width)
        switch themeSwitcher {
        case true:
            cell.selectedBackgroundView?.backgroundColor = UIColor(named: "DarkColor")
            cell.stepTxt_UI.textColor = .lightGray
            cell.backgroundColor = UIColor(named: "DarkColor")
        case false:
            cell.selectedBackgroundView?.backgroundColor = UIColor.white
            cell.stepTxt_UI.textColor = .gray
            cell.backgroundColor = .white
        }
        cell.stepTxt_UI.delegate = self
        cell.stepTxt_UI.text = stepsArr[indexPath.row]
        cell.iconBtn_UI.layer.masksToBounds = true
        cell.iconBtn_UI.layer.cornerRadius = 5.0
        cell.iconBtn_UI.layer.borderWidth = 3.0
        cell.stepTxt_UI.addTarget(self, action: #selector(addStepTextFieldIsFirstResponder(_:)), for: .editingDidBegin)
        
        switch currentTable {
        case 0:
            cell.lineView_UI.backgroundColor = UIColor(named: "TodoColor")
            cell.bottomView_UI.backgroundColor = UIColor(named: "TodoColor")
            cell.iconBtn_UI.layer.borderColor = UIColor(named: "TodoColor")?.cgColor
        case 1:
            cell.lineView_UI.backgroundColor = UIColor(named: "LaterColor")
            cell.bottomView_UI.backgroundColor = UIColor(named: "LaterColor")
            cell.iconBtn_UI.layer.borderColor = UIColor(named: "LaterColor")?.cgColor
        case 2:
            cell.lineView_UI.backgroundColor = UIColor(named: "CompleteColor")
            cell.bottomView_UI.backgroundColor = UIColor(named: "CompleteColor")
            cell.iconBtn_UI.layer.borderColor = UIColor(named: "CompleteColor")?.cgColor
        default:
            break
        }
        
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! detailCustomeTableViewCell
//        cell.stepTxt_UI.becomeFirstResponder()
//        print(indexPath.row)
//
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if moreStepsButton_UI.isSelected||moreStepsTextButton_UI.isSelected{
            return 30
        }else{
            if indexPath.row == 0 {
                return 30
            }else{
                return 0
            }
        }
//        return 30
    }
    
    
}
//------------------------Table View Extension------------------------>>


//<<------------------------Collection View Extension------------------------
extension DetailViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.repeatTimeCollectionView_UI{
            return repeatTimeTitleArr.count
        }else if collectionView == tagCollectionView_UI{
            return tagsContainer.count + 1
        }else if collectionView == calendarCollectionView_UI{
            return calendarDayArr.count + 7
        }
        else{
            return adjustTimeTitleArr.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.repeatTimeCollectionView_UI {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! detailCustomCollectionViewCell
            var repeatInterval = String()
            switch currentTable{
            case 0:
                if todoSingle?.repeatInterval != "Never"{
                    repeatInterval = returnRepatType(str: todoSingle!.repeatInterval!)
                }else{
                    repeatInterval = todoSingle!.repeatInterval!
                }
            case 1:
                if laterSingle?.repeatInterval != "Never"{
                    repeatInterval = returnRepatType(str: laterSingle!.repeatInterval!)
                }else{
                    repeatInterval = laterSingle!.repeatInterval!
                }
            default:
                break
            }
            print(repeatInterval)
            switch indexPath.row{
            case 0:
                if repeatInterval == repeatTimeTitleArr[0]{
                    cell.timeTitleLabel_UI.backgroundColor = UIColor(named: "TodoColor")
                }else{
                    switch themeSwitcher{
                    case true:
                        cell.timeTitleLabel_UI.backgroundColor = UIColor(named: "DarkColor")
                        cell.timeTitleLabel_UI.textColor = .white
                    case false:
                        cell.timeTitleLabel_UI.backgroundColor = .white
                        cell.timeTitleLabel_UI.textColor = .black
                    }
                }
            case 1:
                if repeatInterval == repeatTimeTitleArr[1]{
                    cell.timeTitleLabel_UI.backgroundColor = UIColor(named: "TodoColor")
                }else{
                    switch themeSwitcher{
                    case true:
                        cell.timeTitleLabel_UI.backgroundColor = UIColor(named: "DarkColor")
                        cell.timeTitleLabel_UI.textColor = .white
                    case false:
                        cell.timeTitleLabel_UI.backgroundColor = .white
                        cell.timeTitleLabel_UI.textColor = .black
                    }
                }
            case 2:
                if repeatInterval == repeatTimeTitleArr[2]{
                    cell.timeTitleLabel_UI.backgroundColor = UIColor(named: "TodoColor")
                }else{
                    switch themeSwitcher{
                    case true:
                        cell.timeTitleLabel_UI.backgroundColor = UIColor(named: "DarkColor")
                        cell.timeTitleLabel_UI.textColor = .white
                    case false:
                        cell.timeTitleLabel_UI.backgroundColor = .white
                        cell.timeTitleLabel_UI.textColor = .black
                    }
                }
            case 3:
                if repeatInterval == repeatTimeTitleArr[3]{
                    cell.timeTitleLabel_UI.backgroundColor = UIColor(named: "TodoColor")
                }else{
                    switch themeSwitcher{
                    case true:
                        cell.timeTitleLabel_UI.backgroundColor = UIColor(named: "DarkColor")
                        cell.timeTitleLabel_UI.textColor = .white
                    case false:
                        cell.timeTitleLabel_UI.backgroundColor = .white
                        cell.timeTitleLabel_UI.textColor = .black
                    }
                }
            case 4:
                if repeatInterval == repeatTimeTitleArr[4]{
                    cell.timeTitleLabel_UI.backgroundColor = UIColor(named: "TodoColor")
                }else{
                    switch themeSwitcher{
                    case true:
                        cell.timeTitleLabel_UI.backgroundColor = UIColor(named: "DarkColor")
                        cell.timeTitleLabel_UI.textColor = .white
                    case false:
                        cell.timeTitleLabel_UI.backgroundColor = .white
                        cell.timeTitleLabel_UI.textColor = .black
                    }
                }
            case 5:
                if repeatInterval == repeatTimeTitleArr[5]{
                    cell.timeTitleLabel_UI.backgroundColor = UIColor(named: "TodoColor")
                }else{
                    switch themeSwitcher{
                    case true:
                        cell.timeTitleLabel_UI.backgroundColor = UIColor(named: "DarkColor")
                        cell.timeTitleLabel_UI.textColor = .white
                    case false:
                        cell.timeTitleLabel_UI.backgroundColor = .white
                        cell.timeTitleLabel_UI.textColor = .black
                    }
                }
            default:
                break
            }
            cell.leftView_UI.backgroundColor = UIColor.gray
            cell.rightView_UI.backgroundColor = UIColor.gray
            cell.timeTitleLabel_UI.text = repeatTimeTitleArr[indexPath.row]
            return cell
        }else if collectionView == tagCollectionView_UI{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DetailViewControllerCustomTagCollectionViewCell
            if indexPath.row == tagsContainer.count{
                cell.tagLabel_UI.text = "+"
                switch themeSwitcher{
                case true:
                    cell.tagLabel_UI.textColor = .white
                case false:
                    cell.tagLabel_UI.textColor = UIColor(named: "DarkColor")
                }
            }else{
                cell.tagLabel_UI.text = tagsContainer[indexPath.row].tags
                if selectedTagArrIndex.contains(indexPath.row){
                    switch themeSwitcher{
                    case true:
                        cell.tagLabel_UI.backgroundColor = .white
                        cell.tagLabel_UI.textColor = UIColor(named: "DarkColor")
                    case false:
                        cell.tagLabel_UI.backgroundColor = UIColor(named: "DarkColor")
                        cell.tagLabel_UI.textColor = .white
                    }
                }else{
                    switch themeSwitcher{
                    case true:
                        cell.tagLabel_UI.backgroundColor = UIColor(named: "DarkColor")
                        cell.tagLabel_UI.textColor = .white
                    case false:
                        cell.tagLabel_UI.backgroundColor = .white
                        cell.tagLabel_UI.textColor = UIColor(named: "DarkColor")
                    }
                }
            }
            cell.tagLabel_UI.layer.masksToBounds = true
            cell.tagLabel_UI.layer.cornerRadius = 15.0
            switch themeSwitcher{
            case true:
                cell.tagLabel_UI.layer.borderColor = UIColor.white.cgColor
            case false:
                cell.tagLabel_UI.layer.borderColor = UIColor.black.cgColor
            }
            cell.tagLabel_UI.layer.borderWidth = 1.0
            return cell
        }else if collectionView == calendarCollectionView_UI{
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
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DetailCustomTimeAdjustCollectionViewCell
            switch themeSwitcher{
            case true:
                cell.img_UI.image = UIImage(named: adjustTimeDarkTitleArr[indexPath.row])
            case false:
                cell.img_UI.image = UIImage(named: adjustTimeTitleArr[indexPath.row])
            }
            cell.label_UI.text = adjustTimeTitleArr[indexPath.row]
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case repeatTimeCollectionView_UI:
            var name = String()
            var time = Int32()
            var position = Int32()
            var repeatInterval = String()
            var taskTimeContainer = timeSlicing()
            var dateComponents = DateComponents()
            switch currentTable{
            case 0:
                name = todoSingle!.name!
                time = todoSingle!.time
                position = todoSingle!.position
            case 1:
                name = laterSingle!.name!
                time = laterSingle!.time
                position = laterSingle!.position
            case 2:
                name = completeSingle!.name!
                time = completeSingle!.time
                position = completeSingle!.position
            default:
                break
            }
            taskTimeContainer = timeStampSlicing(timeStamp: String(time))
            let vc = storyboard?.instantiateViewController(withIdentifier: "viewController") as! ViewController
            vc.removeNotification(identifiers: ["repeat\(position)"])
            switch indexPath.row{
            case 0:
                repeatInterval = "Never"
            //every day
            case 1:
                dateComponents.hour = Int(taskTimeContainer.hour)
                dateComponents.minute = Int(taskTimeContainer.minute)
                dateComponents.second = Int(taskTimeContainer.second)
                repeatInterval = "Day-\(taskTimeContainer.hour):\(taskTimeContainer.minute)"
                vc.notificationContent.title = "Day repeat \(name)"
                let trigger = UNCalendarNotificationTrigger( dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "repeat\(position)", content: vc.notificationContent, trigger: trigger)
                vc.notificationContent.sound = .default
                vc.notificationCenter.add(request) {(true) in
                    print("repeat registered")
                }
            //mon-fri
            case 2:
                dateComponents.weekday = 2
                dateComponents.weekday = 3
                dateComponents.weekday = 4
                dateComponents.weekday = 5
                dateComponents.weekday = 6
                dateComponents.hour = Int(taskTimeContainer.hour)
                dateComponents.minute = Int(taskTimeContainer.minute)
                dateComponents.second = Int(taskTimeContainer.second)
                repeatInterval = "Workday-\(taskTimeContainer.hour):\(taskTimeContainer.minute)"
                vc.notificationContent.title = "Workday repeat \(name)"
                let trigger = UNCalendarNotificationTrigger( dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "repeat\(position)", content: vc.notificationContent, trigger: trigger)
                vc.notificationContent.sound = .default
                vc.notificationCenter.add(request) {(true) in
                    print("repeat registered")
                }
            //specific weekday
            case 3:
                let weekDay = Calendar.current.component(.weekday, from: timeStringToDate("\(taskTimeContainer.year)-\(taskTimeContainer.month)-\(taskTimeContainer.day) \(taskTimeContainer.hour):\(taskTimeContainer.minute):\(taskTimeContainer.second)"))
                dateComponents.weekday = weekDay
                dateComponents.hour = Int(taskTimeContainer.hour)
                dateComponents.minute = Int(taskTimeContainer.minute)
                dateComponents.second = Int(taskTimeContainer.second)
                repeatInterval = "Week-\(weekDay)-\(taskTimeContainer.hour):\(taskTimeContainer.minute)"
                vc.notificationContent.title = "Week repeat \(name)"
                let trigger = UNCalendarNotificationTrigger( dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "repeat\(position)", content: vc.notificationContent, trigger: trigger)
                vc.notificationContent.sound = .default
                vc.notificationCenter.add(request) {(true) in
                    print("repeat registered")
                }
            //specific day
            case 4:
                dateComponents.day = Int(taskTimeContainer.day)
                dateComponents.hour = Int(taskTimeContainer.hour)
                dateComponents.minute = Int(taskTimeContainer.minute)
                dateComponents.second = Int(taskTimeContainer.second)
                repeatInterval = "Month-\(taskTimeContainer.day)-\(taskTimeContainer.hour):\(taskTimeContainer.minute)"
                vc.notificationContent.title = "Month repeat \(name)"
                let trigger = UNCalendarNotificationTrigger( dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "repeat\(position)", content: vc.notificationContent, trigger: trigger)
                vc.notificationContent.sound = .default
                vc.notificationCenter.add(request) {(true) in
                    print("repeat registered")
                }
            //specific month
            case 5:
                dateComponents.month = Int(taskTimeContainer.month)
                dateComponents.day = Int(taskTimeContainer.day)
                dateComponents.hour = Int(taskTimeContainer.hour)
                dateComponents.minute = Int(taskTimeContainer.minute)
                dateComponents.second = Int(taskTimeContainer.second)
                repeatInterval = "Year-\(taskTimeContainer.month)-\(taskTimeContainer.day)-\(taskTimeContainer.hour):\(taskTimeContainer.minute)"
                vc.notificationContent.title = "Year repeat \(name)"
                let trigger = UNCalendarNotificationTrigger( dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "repeat\(position)", content: vc.notificationContent, trigger: trigger)
                vc.notificationContent.sound = .default
                vc.notificationCenter.add(request) {(true) in
                    print("repeat registered")
                }
            default:
                break
            }
            
            switch currentTable{
            case 0:
                todoSingle?.repeatInterval = repeatInterval
            case 1:
                laterSingle?.repeatInterval = repeatInterval
            case 2:
                completeSingle?.repeatInterval = repeatInterval
            default:
                break
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            repeatBtn_UI.setTitle(repeatInterval, for: .normal)
            repeatTimeCollectionView_UI.reloadData()
        case tagCollectionView_UI:
            if tagViewTrashButton_UI.isSelected{
                if indexPath.row == tagsContainer.count{
                    print("Cannot")
                }else{
                    let deleteTagAlertView = UIAlertController(title: "Delete tag: \(tagsContainer[indexPath.row].tags ?? "-")", message: "This can't be undone", preferredStyle: .alert)
                    deleteTagAlertView.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    deleteTagAlertView.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (alert) in
                        let item = self.tagsContainer[indexPath.row]
                        for i in 0..<self.todoTaskContainer.count{
                            var newTagsArr = self.todoTaskContainer[i].tags
                            for j in 0..<newTagsArr!.count{
                                if newTagsArr![j] == item.tags{
                                    newTagsArr?.remove(at: j)
                                    break
                                }
                            }
                            self.todoTaskContainer[i].tags = newTagsArr
                        }
                        for i in 0..<self.laterTaskContainer.count{
                            var newTagsArr = self.laterTaskContainer[i].tags
                            for j in 0..<newTagsArr!.count{
                                if newTagsArr![j] == item.tags{
                                    newTagsArr?.remove(at: j)
                                    break
                                }
                            }
                            self.laterTaskContainer[i].tags = newTagsArr
                        }
                        for i in 0..<self.completeTaskContainer.count{
                            var newTagsArr = self.completeTaskContainer[i].tags
                            for j in 0..<newTagsArr!.count{
                                if newTagsArr![j] == item.tags{
                                    newTagsArr?.remove(at: j)
                                    break
                                }
                            }
                            self.completeTaskContainer[i].tags = newTagsArr
                        }
                        self.context.delete(item)
                        (UIApplication.shared.delegate as! AppDelegate).saveContext()
                        self.tagCollectionView_UI.deleteItems(at: [IndexPath(row: indexPath.row, section: 0)])
                        self.dynamicCollectionViewHeight()
                        
                        if self.selectedTagArrIndex.contains(indexPath.row){
                            let index = self.selectedTagArrIndex.firstIndex(of: indexPath.row)
                            self.selectedTagArrIndex.remove(at: index!)
                            self.selectedTagArrIndex.sort(by:<)
                        }
                    }))
                    present(deleteTagAlertView,animated: true,completion: nil)
                }
            }else{
                if indexPath.row == tagsContainer.count{
                    addTagHandler()
                }else{
                    if selectedTagArrIndex.contains(indexPath.row){
                        let index = selectedTagArrIndex.firstIndex(of: indexPath.row)
                        selectedTagArrIndex.remove(at: index!)
                        selectedTagArrIndex.sort(by:<)
                    }else{
                        selectedTagArrIndex.append(indexPath.row)
                        selectedTagArrIndex.sort(by:<)
                    }
                    tagCollectionView_UI.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
                }
            }
        case timeAdjustCollectionView_UI:
            newTimeContainer = timeStampSlicing(timeStamp: String(getCurrentStamp()))
            thisMonthDays = daysOfThisMonth(year:Int(newTimeContainer.year)!, month: Int(newTimeContainer.month)!)
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

extension DetailViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case tagCollectionView_UI:
            return 10
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch collectionView {
        case tagCollectionView_UI:
            return 10
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch collectionView {
        case timeAdjustCollectionView_UI:
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        case calendarCollectionView_UI:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        case tagCollectionView_UI:
//            return(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case repeatTimeCollectionView_UI:
            let width = view.frame.width / 6
            return CGSize(width: width, height: 30)
        case tagCollectionView_UI:
            var width = 0
            if indexPath.row == tagsContainer.count{
                width = 30
            }else{
                width = tagsContainer[indexPath.row].tags!.count * 15
            }
            return CGSize(width: width, height: 30)
        case calendarCollectionView_UI:
            return CGSize(width: 40, height: 40)
        default:
            return CGSize(width: 90, height: 90)
        }
        
    }
}
//------------------------Collection View Extension------------------------>>

//<<------------------------Dissmiss Keyboard Extension------------------------
extension DetailViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        addStepTextIsNotFirstResponderStatus()
        view.endEditing(true)
    }
}
//------------------------Dissmiss Keyboard Extension------------------------>>

extension UIView {
    /**
     扩展UIView增加抖动方法
     
     @param direction：抖动方向（默认是水平方向）
     @param times：抖动次数（默认5次）
     @param interval：每次抖动时间（默认0.1秒）
     @param delta：抖动偏移量（默认2）
     @param completion：抖动动画结束后的回调
     */
    public func shake(direction: ShakeDirection = .horizontal, times: Int = 5,
                      interval: TimeInterval = 0.1, delta: CGFloat = 2,
                      completion: (() -> Void)? = nil) {
        //播放动画
        UIView.animate(withDuration: interval, animations: { () -> Void in
            switch direction {
            case .horizontal:
                self.layer.setAffineTransform( CGAffineTransform(translationX: delta, y: 0))
                break
            case .vertical:
                self.layer.setAffineTransform( CGAffineTransform(translationX: 0, y: delta))
                break
            }
        }) { (complete) -> Void in
            //如果当前是最后一次抖动，则将位置还原，并调用完成回调函数
            if (times == 0) {
                UIView.animate(withDuration: interval, animations: { () -> Void in
                    self.layer.setAffineTransform(CGAffineTransform.identity)
                }, completion: { (complete) -> Void in
                    completion?()
                })
            }
                //如果当前不是最后一次抖动，则继续播放动画（总次数减1，偏移位置变成相反的）
            else {
                self.shake(direction: direction, times: times - 1,  interval: interval,
                           delta: delta * -1, completion:completion)
            }
        }
    }
}
extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}
