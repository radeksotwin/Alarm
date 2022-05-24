//
//  AppManager.swift
//  AlarmTest
//
//  Created by Rdm on 19/05/2022.
//

import Foundation
import UserNotifications


class AlarmManager {
    
    public static let shared = AlarmManager()
    
    func scheduleAlarm(with alarmData: Alarm) {
        let forChosenDays: [String] = alarmData.repetition.components(separatedBy: "/")
        let awakeHour = Date.dateToHourString(date: alarmData.awakeTime)
        let labelText = alarmData.labelText
        let id = alarmData.id
        
        AlarmNotification.fireUpOn(weekday: nil, at: awakeHour, labelText: labelText, alarmId: id, shouldRepeat: nil)
        
        /// Days sequence mapped by DateComponents. Starting from Sunday(1) to Saturday(7)
        for day in forChosenDays {
            if day == "Monday" {
                AlarmNotification.fireUpOn(weekday: 2, at: awakeHour, labelText: labelText, alarmId: id, shouldRepeat: true)
            }
            if day == "Tuesday" {
                AlarmNotification.fireUpOn(weekday: 3, at: awakeHour, labelText: labelText, alarmId: id, shouldRepeat: true)
            }
            if day == "Wednesday" {
                AlarmNotification.fireUpOn(weekday: 4, at: awakeHour, labelText: labelText, alarmId: id, shouldRepeat: true)
            }
            if day == "Thursday" {
                AlarmNotification.fireUpOn(weekday: 5, at: awakeHour, labelText: labelText, alarmId: id, shouldRepeat: true)
            }
            if day == "Friday" {
                AlarmNotification.fireUpOn(weekday: 6, at: awakeHour, labelText: labelText, alarmId: id, shouldRepeat: true)
            }
            if day == "Saturday" {
                AlarmNotification.fireUpOn(weekday: 7, at: awakeHour, labelText: labelText, alarmId: id, shouldRepeat: true)
            }
            if day == "Sunday" {
                AlarmNotification.fireUpOn(weekday: 1, at: awakeHour, labelText: labelText, alarmId: id, shouldRepeat: true)
            }
        }
    }
    
    func switchAlarmToState(alarm: Alarm, isActive: Bool) {
        alarm.isActive = isActive
        PersistanceService.saveContext()
    }
    
    func removeRepeatingPendingNotification(with id: String, dayTag: Int) {
        let dayTagMap = [0:2,
                         1:3,
                         2:4,
                         3:5,
                         4:6,
                         5:7,
                         6:1]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id + "-\((dayTagMap[dayTag])!)"])
    }
    
    func removePendingAlarmNotification(with id: String, on weekDays: String) {
        let weekDaysMap: [String : Int] = ["Sunday" : 1,
                                           "Monday" : 2,
                                           "Tuesday" : 3,
                                           "Wednesday" : 4,
                                           "Thursday" : 5,
                                           "Friday" : 6,
                                           "Saturday" : 7,
                                           "" : 0]
        if weekDays != "" {
            let repeatingAlarmDaysArray = weekDays.components(separatedBy: "/")
            for day in repeatingAlarmDaysArray {
                guard weekDaysMap[day] != nil else { return }
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id + "-\((weekDaysMap[day])!)"])
            }
        }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
//        print("Notification request with id: \(id) successfully removed")
    }

}

