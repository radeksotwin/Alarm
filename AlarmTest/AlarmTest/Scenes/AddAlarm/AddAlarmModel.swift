//
//  AddAlarmModel.swift
//  AlarmTest
//
//  Created by Rdm on 16/05/2022.
//

import Foundation


enum AddAlarm {
    struct AlarmModel {
        var awakeTime: Date = Date().addingTimeInterval(60*60*2)
        var id: String = ""
        var labelText: String = ""
        var repetition: String = ""
        var isActive: Bool = true
    }
}


