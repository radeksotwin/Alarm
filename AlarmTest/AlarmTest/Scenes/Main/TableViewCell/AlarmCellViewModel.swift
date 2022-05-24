//
//  AlarmCellViewModel.swift
//  AlarmTest
//
//  Created by Rdm on 23/05/2022.
//

import Foundation

final class AlarmCellViewModel {
    
    var alarm: ObservableObject<Alarm?> = ObservableObject(nil)
    
    init(model: Alarm) {
        self.alarm.value = model
    }
}
