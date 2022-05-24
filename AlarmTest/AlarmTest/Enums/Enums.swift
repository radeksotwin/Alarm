//
//  Enums.swift
//  AlarmTest
//
//  Created by Rdm on 18/05/2022.
//

import SCLAlertView
import UIKit


enum Alert {
    static func showAlert(subTitle: String) {
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!)
        let alert = SCLAlertView(appearance: appearance)
        
        alert.showInfo("Success!", subTitle: subTitle, closeButtonTitle: "Done", timeout: .none, colorStyle: 0x242424, colorTextButton: 0xFFF2E4, circleIconImage: nil, animationStyle: .topToBottom)
    }
}

enum AlarmNotification {
    static func fireUpOn(weekday: Int?, at: String, labelText: String, alarmId: String, shouldRepeat: Bool?) {
        let components = at.components(separatedBy: ":")
        var dateComponents = DateComponents()
        dateComponents.calendar?.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        dateComponents.hour = Int(components[0])
        dateComponents.minute = Int(components[1])
        dateComponents.weekday = weekday ?? nil
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: shouldRepeat ?? false)
        let content = UNMutableNotificationContent()
        content.sound = .defaultRingtone
        content.title = "Your Alarm"
        content.body = labelText
        
        var id = alarmId
        if weekday != nil {
            id = alarmId + "-\((weekday)!)"
        }
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error != nil {
                print("Error")
            }
        })
    }
}


