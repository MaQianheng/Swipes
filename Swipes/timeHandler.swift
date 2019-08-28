//
//  timeHandler.swift
//  Swipes
//
//  Created by 马乾亨 on 1/5/19.
//  Copyright © 2019 CS3432. All rights reserved.
//

import Foundation
class timeSlicing {
    var year = String()
    var month = String()
    var day = String()
    var hour = String()
    var minute = String()
    var second = String()
}
//获取当前时间戳
func getCurrentStamp() -> Int {
    let date = Date()
    let timeInterval: Int = Int(date.timeIntervalSince1970)
    return timeInterval
}

//时间戳转字符串
func timeStampToStringDetail(_ timeStamp: String) -> String {
    let string = NSString(string: timeStamp)
    let timeSta: TimeInterval = string.doubleValue
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let date = Date(timeIntervalSince1970: timeSta)
    return dateFormatter.string(from: date)
}

// MARK: 将时间戳转换为年月日
func timeStampToString(_ timeStamp: String) -> String {
    let string = NSString(string: timeStamp)
    let timeSta: TimeInterval = string.doubleValue
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy/MM/dd"
    let date = Date(timeIntervalSince1970: timeSta)
    return dateFormatter.string(from: date)
}

//字符串转日期
func timeStringToDate(_ dateStr: String) -> Date {
    print(dateStr)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let date = dateFormatter.date(from: dateStr)
    return date!
}

//比较时间先后
func compareOneDay(oneDay: Date, withAnotherDay anotherDay:Date) -> Int {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let oneDayStr: String = dateFormatter.string(from: oneDay)
    let anotherDayStr: String = dateFormatter.string(from: anotherDay)
    let dateA = dateFormatter.date(from: oneDayStr)
    let dateB = dateFormatter.date(from: anotherDayStr)
    let result: ComparisonResult = (dateA?.compare(dateB!))!
    if result == ComparisonResult.orderedDescending {
        //OneDay > AnotherDay
        return 1
    }else if result == ComparisonResult.orderedAscending {
        //OneDay < AnotherDay
        return 2
        //相等
    }else {
        ////OneDay = AnotherDay
        return 0
    }
}

//时间和当前时间比较
func compareCurrentTime(str: String) -> String {
    let tiemDate = timeStringToDate(str)
    let currentDate = NSDate()
    let tiemInterval = currentDate.timeIntervalSince(tiemDate)
    var temp: Double = 0
    var result: String = ""
    if tiemInterval/60 < 1 {
        result = "Just now"
    }else if tiemInterval/60 < 60 {
        temp = tiemInterval/60
        result = "\(Int(temp)) minutes ago"
    }else if tiemInterval/60/60 < 24 {
        temp = tiemInterval/60/60
        result = "\(Int(temp)) hours ago"
    }else if tiemInterval/60/60/24 < 30 {
        temp = tiemInterval/60/60/24
        result = "\(Int(temp)) days ago"
    }else if tiemInterval/(60 * 60 * 24 * 30) < 12 {
        temp = tiemInterval/(60 * 60 * 24 * 30)
        result = "\(Int(temp)) months ago"
    }else {
        temp = tiemInterval/(12 * 30 * 24 * 60 * 60)
        result = "\(Int(temp)) years ago"
    }
    return result
}

//日期转时间戳
func dateToTimeStamp(date:String) -> Int {
    let datefmatter = DateFormatter()
    datefmatter.dateFormat="yyyy-MM-dd HH:mm:ss"
    let receivedDate = datefmatter.date(from: date)
    let dateStamp:TimeInterval = receivedDate!.timeIntervalSince1970
    let dateStr:Int = Int(dateStamp)
    return dateStr
}

//时间分组
func dateGrouping(dtArr:[String]) -> [String]{
    var dateArr:[String] = []
    var result:[String] = []
    for i in 0..<dtArr.count{
        dateArr.append(timeStampToString(dtArr[i]))
    }
    dateArr.sort{(p1,p2) -> Bool in
        return p1<p2
    }
    for value in dateArr {
        if result.contains(value) == false {
            result.append(value)
        }
    }
    return result
}

//timeStamp -> time slicing
func timeStampSlicing(timeStamp:String) -> timeSlicing{
    let result = timeSlicing()
    
    let timeString = timeStampToStringDetail(timeStamp)
    
    let yearStartIndex = timeString.index(timeString.startIndex, offsetBy: 0)
    let yearEndIndex = timeString.index(timeString.endIndex, offsetBy:-15)
    let year = timeString[yearStartIndex ..< yearEndIndex]
    
    let monthStartIndex = timeString.index(timeString.startIndex, offsetBy: 5)
    let monthEndIndex = timeString.index(timeString.endIndex, offsetBy:-12)
    let month = timeString[monthStartIndex ..< monthEndIndex]
    
    let dayStartIndex = timeString.index(timeString.startIndex, offsetBy: 8)
    let dayEndIndex = timeString.index(timeString.endIndex, offsetBy: -9)
    let day = timeString[dayStartIndex ..< dayEndIndex]
    
    let timeHourStartIndex = timeString.index(timeString.startIndex, offsetBy: 11)
    let timeHourEndIndex = timeString.index(timeString.endIndex, offsetBy: -6)
    let timeHour = timeString[timeHourStartIndex ..< timeHourEndIndex]
    
    let timeMinuteStartIndex = timeString.index(timeString.startIndex,offsetBy: 14)
    let timeMinuteEndIndex = timeString.index(timeString.endIndex,offsetBy: -3)
    let timeMinute = timeString[timeMinuteStartIndex ..< timeMinuteEndIndex]
    
    let timeSecondStartIndex = timeString.index(timeString.startIndex,offsetBy: 17)
    let timeSecondEndIndex = timeString.index(timeString.endIndex,offsetBy: 0)
    let timeSecond = timeString[timeSecondStartIndex ..< timeSecondEndIndex]
    result.year = String(year)
    result.month = String(month)
    result.day = String(day)
    result.hour = String(timeHour)
    result.minute = String(timeMinute)
    result.second = String(timeSecond)
    return result
}

func timeToDate(){}

//Return English Month
func convertEnglishMonth(month:Int) -> String {
    var result = String()
    switch month {
    case 01:
        result = "Jan"
    case 02:
        result = "Feb"
    case 03:
        result = "Mar"
    case 04:
        result = "Apr"
    case 05:
        result = "May"
    case 06:
        result = "Jun"
    case 07:
        result = "Jul"
    case 08:
        result = "Aug"
    case 09:
        result = "Sep"
    case 10:
        result = "Oct"
    case 11:
        result = "Nov"
    case 12:
        result = "Dec"
    default:
        break
    }
    return result
}

func convertEnglishWeekDay(day:Int) -> String{
    var result = String()
    switch day {
    case 1:
        result = "Sun"
    case 2:
        result = "Mon"
    case 3:
        result = "Tue"
    case 4:
        result = "Wed"
    case 5:
        result = "Thu"
    case 6:
        result = "Fri"
    case 7:
        result = "Sat"
    default:
        break
    }
    return result
}

func daysOfThisMonth(year:Int,month:Int) -> Int{
    var result = Int()
    switch month {
    case 1,3,5,7,8,10,12:
        result = 31
    case 2:
        if (year%4 == 0 && year%100 != 0)||(year%400 == 0) {
            result = 29
        }else{
            result = 28
        }
    case 4,6,9,11:
        result = 30
    default:
        break
    }
    return result
}

func returnRepatType(str:String) -> String {
    if str == "Never" {
        return "Never"
    }else{
        let startIndex = str.index(str.startIndex,offsetBy: 0)
        let position = str.positionOf(sub: "-")
        let endIndex = str.index(str.endIndex,offsetBy: position - str.count)
        let result = str[startIndex ..< endIndex]
        return String(result)
    }
}

func calendarDay(year:Int,month:Int) -> [Int]{
    let calendar = Calendar.current
    var preYear = Int()
    var preMonth = Int()
    let currentDate = timeStampSlicing(timeStamp: String(getCurrentStamp()))
    preYear = year - 1
    if month == 1 {
        preMonth = 12
    }else{
        preMonth = month - 1
    }
    //2019-06-09 00:00:00
    //weekday : 1->sun....7->sat
    var lastSunOfPreMonth = Int()
    var dayArr = [Int]()
    //如果输入的是1月
    if preMonth == 12 {
        for i in (0..<daysOfThisMonth(year: preYear, month: preMonth) + 1).reversed(){
            let weekDay = calendar.component(Calendar.Component.weekday, from: timeStringToDate("\(preYear)-\(preMonth)-\(i) 00:00:00"))
            if weekDay == 1 {
                lastSunOfPreMonth = i
                break
            }
        }
        if calendar.component(Calendar.Component.weekday, from: timeStringToDate("\(preYear)-\(preMonth)-\(daysOfThisMonth(year: preYear, month: preMonth)) 00:00:00")) != 7 {
            for i in lastSunOfPreMonth..<daysOfThisMonth(year: preYear, month: preMonth) + 1{
                if month == Int(currentDate.month){
                    dayArr.append(0)
                }else{
                    dayArr.append(i)
                }
            }
        }
    }else{
        for i in (0..<daysOfThisMonth(year: year, month: preMonth) + 1).reversed(){
            let weekDay = calendar.component(Calendar.Component.weekday, from: timeStringToDate("\(year)-\(preMonth)-\(i) 00:00:00"))
            if weekDay == 1 {
                lastSunOfPreMonth = i
                break
            }
        }
        if calendar.component(Calendar.Component.weekday, from: timeStringToDate("\(year)-\(preMonth)-\(daysOfThisMonth(year: year, month: preMonth)) 00:00:00")) != 7 {
            for i in lastSunOfPreMonth..<daysOfThisMonth(year: year, month: preMonth) + 1{
                if month == Int(currentDate.month){
                    dayArr.append(0)
                }else{
                    dayArr.append(i)
                }
            }
        }
    }
    for i in 1..<daysOfThisMonth(year: year, month: month) + 1{
        dayArr.append(i)
    }
    let lastWeekDayOfThisMonth = calendar.component(.weekday, from: timeStringToDate("\(year)-\(month)-\(daysOfThisMonth(year: year, month: month)) 00:00:00"))
    for i in 1..<7 - lastWeekDayOfThisMonth + 1{
        dayArr.append(i)
    }
    return dayArr
}

extension String {
    //返回第一次出现的指定子字符串在此字符串中的索引
    //（如果backwards参数设置为true，则返回最后出现的位置）
    func positionOf(sub:String, backwards:Bool = false)->Int {
        var pos = -1
        if let range = range(of:sub, options: backwards ? .backwards : .literal ) {
            if !range.isEmpty {
                pos = self.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
}
