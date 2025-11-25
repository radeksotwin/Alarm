//
//  AddAlarmViewController.swift
//  AlarmTest
//
//  Created by Rdm on 16/05/2022.
//

import UserNotifications
import UIKit
import SCLAlertView


class DayButton: UIButton {
    var isDaySelected: Bool?
}


final class AddAlarmViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var navigationItemObject: UINavigationItem!
    @IBOutlet weak var awakeTimePicker: UIDatePicker!
    @IBOutlet weak var labelPropertyContentLabel: UILabel!
    @IBOutlet weak var labelContentTextField: UITextField!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var repetitionView: UIView!
    @IBOutlet var weekDaysLabelsCollection: [UILabel]!
    @IBOutlet var weekButtonsCollection: [DayButton]!
    @IBOutlet weak var weekDayButtonsStackView: UIStackView!
    @IBOutlet weak var activitySwitch: UISwitch!
    @IBOutlet weak var deleteAlarmButton: UIButton!
    @IBOutlet weak var labelAccessoryIV: UIImageView!
    @IBOutlet weak var repetitionAccessoryIV: UIImageView!
    @IBOutlet weak var labelViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var repetitionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var viewObjectsCollection: [UIView]!
    
    private static let identifier = "AddAlarmViewController"
    private let daysOfTheWeek = ["Monday",
                                 "Tuesday",
                                 "Wednesday",
                                 "Thursday",
                                 "Friday",
                                 "Saturday",
                                 "Sunday"]
    
    let viewModel = AddAlarmViewModel()
    private var isLabelRowExpanded = false
    private var isRepetitionRowExpanded = false
    var saveAlarmObserver: NSObjectProtocol?
    var alarmDeletionCallBack: (() -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        holdAlarmContent()
        setupTextFieldDelegate()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        navigationItemObject.title = viewModel.isNewAlarm.value ? "Add Alarm" : "Edit Alarm"
        deleteAlarmButton.isHidden = viewModel.isNewAlarm.value ? true : false
    }

    @IBAction func saveAlarmTapped(_ sender: UIBarButtonItem) {
        viewModel.saveAlarm()
        ///
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dayButtonTapped(_ sender: DayButton) {
        guard let title = sender.titleLabel?.text else { return }
        let dayTag = sender.tag
        
        /// Mark labels and buttons as highlighted or not
        if sender.isDaySelected == true {
            sender.backgroundColor = .darkGray
            sender.isDaySelected = false
            configureDayLabelOn(index: dayTag, dayName: title, isSelected: false)
            
            /// Remove pending notifications after day unchecking
            AlarmManager.shared.removeRepeatingPendingNotification(with: viewModel.alarmModel.id, dayTag: dayTag)
        } else {
            sender.backgroundColor = .systemOrange
            sender.isDaySelected = true
            configureDayLabelOn(index: dayTag, dayName: title, isSelected: true)
        }
        
        var dayName: String = ""
        /// Recognize which button has been tapped, edit alarm repetition days and update them into array
        switch title {
        case "Mo":
            dayName = daysOfTheWeek[0]
            viewModel.dayMarkingLogic(dayName: dayName)
        case "Tu":
            dayName = daysOfTheWeek[1]
            viewModel.dayMarkingLogic(dayName: dayName)
        case "We":
            dayName = daysOfTheWeek[2]
            viewModel.dayMarkingLogic(dayName: dayName)
        case "Th":
            dayName = daysOfTheWeek[3]
            viewModel.dayMarkingLogic(dayName: dayName)
        case "Fr":
            dayName = daysOfTheWeek[4]
            viewModel.dayMarkingLogic(dayName: dayName)
        case "Sat":
            dayName = daysOfTheWeek[5]
            viewModel.dayMarkingLogic(dayName: dayName)
        case "Su":
            dayName = daysOfTheWeek[6]
            viewModel.dayMarkingLogic(dayName: dayName)
        default:
            break
        }
        
        let onDays = viewModel.repetitionDaysArray.joined(separator: "/")
        updateRepetition(onDays: onDays)
    }
    
    @IBAction func deleteAlarmTapped(_ sender: UIButton) {
        /// Send signal about alarm deletion to Main ViewController and remove
        viewModel.alarmDeletionCallBack?()
        AlarmManager.shared.removePendingAlarmNotification(with: viewModel.alarmModel.id, on: viewModel.alarmModel.repetition)
        Alert.showAlert(subTitle: "Alarm has been deleted.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func timePickerValueChanged(_ sender: UIDatePicker) {
        let pickedDate = sender.date
        updateTime(date: pickedDate)
        viewModel.updateAlarmIdAndRemoveOldPendingNotifications(withText: viewModel.alarmModel.labelText, date: pickedDate)
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        updateLabelText(text: text)
        viewModel.updateAlarmIdAndRemoveOldPendingNotifications(withText: text, date: viewModel.alarmModel.awakeTime)
    }
    
    @IBAction func alarmActivitySwitched(_ sender: UISwitch) {
        let isActive = sender.isOn
        updateActivity(isActive: isActive)
    }
    
    @IBAction func labelViewButtonTapped(_ sender: UIButton) {
        isLabelRowExpanded.toggle()
        labelViewHeightConstraint.constant = isLabelRowExpanded ? 94 : 45
        let rotation: CGFloat = isLabelRowExpanded ? 1.57 : 0
        
        UIView.animate(withDuration: 0.3, animations: {
            self.labelAccessoryIV.transform = CGAffineTransform(rotationAngle: rotation)
            self.labelContentTextField.alpha = self.isLabelRowExpanded ? 1 : 0
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func repetitionViewButtonTapped(_ sender: UIButton) {
        isRepetitionRowExpanded.toggle()
        repetitionViewHeightConstraint.constant = isRepetitionRowExpanded ? 94 : 45
        let rotation: CGFloat = isRepetitionRowExpanded ? 1.57 : 0
        UIView.animate(withDuration: 0.3, animations: {
            self.repetitionAccessoryIV.transform = CGAffineTransform(rotationAngle: rotation)
            self.weekDayButtonsStackView.alpha = self.isRepetitionRowExpanded ? 1 : 0
            self.view.layoutIfNeeded()
        })
    }
    
    /// Update alarm properties
    func updateTime(date: Date) {
        viewModel.alarmModel.awakeTime = date
    }
    
    func updateLabelText(text: String) {
        viewModel.alarmModel.labelText = text
        self.labelPropertyContentLabel.text = text
    }
    
    func updateRepetition(onDays: String) {
        viewModel.alarmModel.repetition = onDays
    }
    
    func updateActivity(isActive: Bool) {
        viewModel.alarmModel.isActive = isActive
    }
    
    /// Configure appearance of day labels and buttons according to selected days
    func highlightSelectedObjects(selectedDays: String) {
        let chosenDays: [String] = selectedDays.components(separatedBy: "/")
        for chosenDay in chosenDays {
            if daysOfTheWeek.first(where: { $0 == chosenDay }) != nil {
                guard let dayIndex = daysOfTheWeek.firstIndex(of: chosenDay) else { return }
                let dayButton = weekButtonsCollection[dayIndex]
                let dayPrefix = viewModel.translateDayNameToDayPrefix(dayName: chosenDay)
                dayButton.isDaySelected = true
                dayButton.backgroundColor = .systemOrange
                self.configureDayLabelOn(index: dayIndex, dayName: dayPrefix, isSelected: true)
            }
        }
    }
    
    func configureDayLabelOn(index: Int, dayName: String, isSelected: Bool) {
        let selectedAtb = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .heavy)]
        let unselectedAtb = [NSAttributedString.Key.foregroundColor : UIColor.lightGray, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 10, weight: .regular)]
        let atb = isSelected ? selectedAtb : unselectedAtb
        let atbString = NSMutableAttributedString(string: dayName, attributes: atb)
        weekDaysLabelsCollection[index].attributedText = atbString
    }
    
    /// Fill alarm properties with alarmToSave object or assign default values if alarm is about to be created
    func holdAlarmContent() {
        if let alarm = viewModel.alarmToSave.value {
            DispatchQueue.main.async {
                self.highlightSelectedObjects(selectedDays: alarm.repetition)
                self.awakeTimePicker.setDate(alarm.awakeTime, animated: true)
                self.labelContentTextField.text = alarm.labelText
                self.labelPropertyContentLabel.text = alarm.labelText
                self.activitySwitch.isOn = alarm.isActive
            }
        } else {
            let awakeHour = Date.dateToHourString(date: viewModel.alarmModel.awakeTime)
            viewModel.alarmModel.id = "AlarmID-Alarm-\(awakeHour)"
            viewModel.alarmModel.labelText = "Alarm"
            viewModel.alarmModel.isActive = true
            DispatchQueue.main.async {
                self.labelPropertyContentLabel.text = "Alarm"
                self.labelContentTextField.text = "Alarm"
            }
        }
    }
    
    func setupView() {
        for object in viewObjectsCollection {
            object.setCornerRadius(value: 8)
        }
        
        for btn in weekButtonsCollection {
            let value = btn.frame.height / 2
            btn.setCornerRadius(value: value)
        }

        awakeTimePicker.setDate(.now + (60*60*2), animated: true)
        awakeTimePicker.locale = .current
        awakeTimePicker.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        labelView.clipsToBounds = true
        repetitionView.clipsToBounds = true
        labelContentTextField.alpha = 0
        weekDayButtonsStackView.alpha = 0
    }
    
    func setupTextFieldDelegate() {
        labelContentTextField.delegate = self
    }
}


extension AddAlarmViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}




