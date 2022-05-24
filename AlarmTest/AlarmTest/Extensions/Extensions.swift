//
//  Extensions.swift
//  AlarmTest
//
//  Created by Rdm on 16/05/2022.
//

import UIKit


extension Notification.Name {
    static let saveButtonTapped = NSNotification.Name("SaveButtonClicked")
    static let deleteButtonTapped = NSNotification.Name("DeleteButtonTapped")
    static let alaramActivitySwitched = NSNotification.Name("AlarmActivitySwitched")
}

extension String {
    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

extension UIView {
    func setCornerRadius(value: CGFloat) {
        self.layer.cornerRadius = value
    }
}

extension Date {
    var localizedDescription: String {
           return description(with: .current)
       }

    static func hourStringToDate(string: String) -> Date {
        let dateFormatter = DateFormatter()
        guard let date = dateFormatter.date(from: string) else { return Date() }
        return date
    }
    
   static func dateToHourString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        return dateFormatter.string(from: date)
    }
    
    static func dateToDayString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
}


