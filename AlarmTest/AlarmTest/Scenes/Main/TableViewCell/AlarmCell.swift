//
//  AlarmCell.swift
//  AlarmTest
//
//  Created by Rdm on 16/05/2022.
//

import SCLAlertView
import UIKit


class AlarmCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var alarmSwitch: UISwitch!
    
    var viewModel: AlarmCellViewModel?
    weak var mainViewController: MainViewController?
    static let identifier = "AlarmCell"

    override func awakeFromNib() {
        super.awakeFromNib()
     
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func alarmActivitySwitched(_ sender: UISwitch) {
        guard let vc = mainViewController else { return }
        guard let alarm = viewModel?.alarm.value else {
            return
        }
       
        AlarmManager.shared.switchAlarmToState(alarm: alarm, isActive: sender.isOn)
     
        if alarm.isActive {
            AlarmManager.shared.scheduleAlarm(with: alarm)
        } else {
            AlarmManager.shared.removePendingAlarmNotification(with: alarm.id, on: alarm.repetition)
        }
        vc.viewModel.loadAlarms()
        vc.alarmsTableView.reloadData()
    }
    
    func setupView(viewModel: AlarmCellViewModel) {
        guard let viewModel = viewModel as? AlarmCellViewModel,
              let awakeTime = viewModel.alarm.value?.awakeTime,
              let labelText = viewModel.alarm.value?.labelText,
              let isActive = viewModel.alarm.value?.isActive else {
                  return
              }
        
        self.viewModel = viewModel
        
        timeLabel.text = Date.dateToHourString(date: awakeTime)
        infoLabel.text = labelText
        alarmSwitch.isOn = isActive
        
        if isActive {
            timeLabel.alpha = 1
            infoLabel.alpha = 1
        } else {
            timeLabel.alpha = 0.4
            infoLabel.alpha = 0.4
        }
    }
}

