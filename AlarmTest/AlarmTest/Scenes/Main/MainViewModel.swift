//
//  MainViewModel.swift
//  AlarmTest
//
//  Created by Rdm on 16/05/2022.
//

import Foundation
import CoreData


final class MainViewModel {
    
    var active: ObservableObject<[Alarm]> = ObservableObject([])
    var inactive: ObservableObject<[Alarm]> = ObservableObject([])
    var pickedAlarm: ObservableObject<Alarm?> = ObservableObject(nil)

    
    func fetchAlarms(completion: ([Alarm]) -> Void) {
        let fetchRequest: NSFetchRequest<Alarm> = Alarm.fetchRequest()
        do {
            let alarmsArray = try PersistanceService.context.fetch(fetchRequest)
            completion(alarmsArray)
        } catch let error {
            print("Error fetching CoreData objects", error)
        }
    }
    
    func loadAlarms() {
        fetchAlarms { [weak self] (alarmsArray) in
            guard let me = self else { return }
            me.active.value = groupActiveAlarms(alarmsArray: alarmsArray)
            me.inactive.value = groupInactiveAlarms(alarmsArray: alarmsArray)
        }
    }
    
    func pickAlarmToDelete(alarm: Alarm) {
        self.pickedAlarm.value = alarm
    }
    
    func deleteAlarm() {
        PersistanceService.context.delete(pickedAlarm.value!)
        PersistanceService.saveContext()
        Alert.showAlert(subTitle: "Alarm has been deleted.")
        loadAlarms()
    }
    
    func groupActiveAlarms(alarmsArray: [Alarm]) -> [Alarm] {
        var active: [Alarm] = []
        for element in alarmsArray {
            if element.isActive {
                active.append(element)
            }
        }
        return active
    }
    
    func groupInactiveAlarms(alarmsArray: [Alarm]) -> [Alarm] {
        var inactive: [Alarm] = []
        for element in alarmsArray {
            if !element.isActive {
                inactive.append(element)
            }
        }
        return inactive
    }
}
