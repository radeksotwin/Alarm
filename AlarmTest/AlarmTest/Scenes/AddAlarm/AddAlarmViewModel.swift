//
//  AddAlarmViewModel.swift
//  AlarmTest
//
//  Created by Rdm on 23/05/2022.
//

import Foundation

final class AddAlarmViewModel {
    var awakeTime = ObservableObject<Date>(Date().addingTimeInterval(60*60*2))
    var id = ObservableObject<String>("")
    var labelText = ObservableObject<String>("")
    var repetition = ObservableObject<String>("")
    var isActive = ObservableObject<Bool>(true)
    var isNewAlarm = ObservableObject<Bool>(false)
    var alarmModel = AddAlarm.AlarmModel()
    var alarmToSave: ObservableObject<Alarm?> = ObservableObject(nil)
    var pickedAlarmToDelete: Alarm?
    var repetitionDaysArray: [String] = []
    var alarmDeletionCallBack: (() -> Void)?
    
    func saveAlarm() {
        if alarmToSave.value == nil {
            alarmToSave.value = Alarm(context: PersistanceService.context)
        }
        /// Remove old pending notification request before merging new alarmModel into alarmToSave data
        AlarmManager.shared.removePendingAlarmNotification(with: alarmModel.id, on: alarmModel.repetition)
        ///
        alarmToSave.value = mergeAlarmModelToAlarmToSave(alarmModel: alarmModel, alarmToSave: alarmToSave.value!)
        ///
        PersistanceService.saveContext()
        ///
        Alert.showAlert(subTitle: "Alarm has been saved.")
        /// Schedule edited alarm when is active
        if alarmToSave.value!.isActive == true {
            AlarmManager.shared.scheduleAlarm(with: alarmToSave.value!)
        } else {
            AlarmManager.shared.removePendingAlarmNotification(with: alarmToSave.value!.id, on: alarmToSave.value!.repetition)
        }
        /// Post notification to Main view controller to reload table view data
        NotificationCenter.default.post(name: NSNotification.Name.saveButtonTapped, object: nil, userInfo: nil)
    }
    
    func translateDayNameToDayPrefix(dayName: String) -> String {
        switch dayName {
        case "Monday":
            return dayName.substring(toIndex: 2)
        case "Tuesday":
            return dayName.substring(toIndex: 2)
        case "Wednesday":
            return dayName.substring(toIndex: 2)
        case "Thursday":
            return dayName.substring(toIndex: 2)
        case "Friday":
            return dayName.substring(toIndex: 2)
        case "Saturday":
            return dayName.substring(toIndex: 3)
        case "Sunday":
            return dayName.substring(toIndex: 2)
        default:
            return ""
        }
    }
    
    func dayMarkingLogic(dayName: String) {
        if repetitionDaysArray.contains(dayName) {
            repetitionDaysArray.removeAll(where: { $0 == dayName })
        } else {
            repetitionDaysArray.append(dayName)
        }
    }
    
    func updateAlarmIdAndRemoveOldPendingNotifications(withText: String, date: Date) {
        AlarmManager.shared.removePendingAlarmNotification(with: alarmModel.id, on: alarmModel.repetition)
        let stringToId = withText.replacingOccurrences(of: " ", with: "-")
        let hourString = Date.dateToHourString(date: date)
        self.alarmModel.id = "AlarmID-\(stringToId)-\(hourString)"
    }
    
    func mergeAlarmModelToAlarmToSave(alarmModel: AddAlarm.AlarmModel, alarmToSave: Alarm) -> Alarm {
        alarmToSave.awakeTime = alarmModel.awakeTime
        alarmToSave.labelText = alarmModel.labelText
        alarmToSave.repetition = alarmModel.repetition
        alarmToSave.isActive = alarmModel.isActive
        alarmToSave.id = alarmModel.id
        return alarmToSave
    }
    
    func fillUpAlarmModel(alarm: Alarm) -> AddAlarm.AlarmModel {
        var alarmModel = AddAlarm.AlarmModel()
        alarmModel.awakeTime = alarm.awakeTime
        alarmModel.labelText = alarm.labelText
        alarmModel.repetition = alarm.repetition
        alarmModel.isActive = alarm.isActive
        alarmModel.id = alarm.id
        return alarmModel
    }
}
