//
//  ViewController.swift
//  AlarmTest
//
//  Created by Rdm on 16/05/2022.
//

import UIKit
import AVFoundation
import CoreData
import UserNotifications


final class MainViewController: UIViewController {

    @IBOutlet weak var alarmsTableView: UITableView!
    
    let sections = ["Active", "Inactive"]
    let viewModel: MainViewModel = MainViewModel()
    var saveAlarmObserver: NSObjectProtocol?
    var deleteAlarmObserver: NSObjectProtocol?
    var alarmNotificationFiredObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegateAndDataSource()
        viewModel.loadAlarms()
        setObservers()
        setupBinders()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [""])
    }
    
    func setupBinders() {
//        viewModel.active.bind { [weak self] arr in
//        }
//        viewModel.inactive.bind { [weak self] arr in
//        }
//        viewModel.pickedAlarm.bind { [weak self] ala in
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        alarmsTableView.reloadData()
    }
    
    /// Pass data to AddAlarm view controller and configure before segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? AddAlarmViewController {
            dest.viewModel.isNewAlarm.value = true
            dest.navigationItem.title = "Add Alarm"
            if let cell = sender as? AlarmCell, let addAlarmVc = segue.destination as? AddAlarmViewController {
                guard let alarm = cell.viewModel!.alarm.value,
                      let indexPath = alarmsTableView.indexPath(for: cell) else { return }
                addAlarmVc.navigationItem.title = "Edit Alarm"
                addAlarmVc.viewModel.alarmModel = addAlarmVc.viewModel.fillUpAlarmModel(alarm: alarm)
                addAlarmVc.viewModel.alarmToSave.value = alarm
                addAlarmVc.viewModel.pickedAlarmToDelete = alarm
                addAlarmVc.viewModel.repetitionDaysArray = Alarm.alarmRepetitionStringToArray(repetitionString: alarm.repetition)
                addAlarmVc.viewModel.isNewAlarm.value = false
                addAlarmVc.viewModel.alarmDeletionCallBack = { [weak self] in
                    guard let me = self else { return }
                    switch indexPath.section {
                    case 0:
                        me.viewModel.active.value.remove(at: indexPath.row)
                    case 1:
                        me.viewModel.inactive.value.remove(at: indexPath.row)
                    default:
                        break
                    }
                    AlarmManager.shared.removePendingAlarmNotification(with: alarm.id, on: alarm.repetition)
                    me.viewModel.deleteAlarm()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.4, execute: {
                        me.alarmsTableView.deleteRows(at: [indexPath], with: .automatic)
                        me.alarmsTableView.reloadData()
                    })
                }
            }
        }
    }
    
    @IBAction func routeToAddAlarm(_ sender: UIBarButtonItem) {
        
    }
    
    deinit {
        removeObservers()
    }
    
    
    func setupDelegateAndDataSource() {
        alarmsTableView.delegate = self
        alarmsTableView.dataSource = self
    }

    func setObservers() {
        saveAlarmObserver = NotificationCenter.default.addObserver(forName: Notification.Name.saveButtonTapped, object: nil, queue: .main, using: { [weak self] _ in
            guard let me = self else { return }
            me.viewModel.loadAlarms()
            DispatchQueue.main.async {
                me.alarmsTableView.reloadData()
            }
        })
        
        deleteAlarmObserver = NotificationCenter.default.addObserver(forName: Notification.Name.deleteButtonTapped, object: nil, queue: .main, using: { [weak self] _ in
            guard let me = self else { return }
            me.viewModel.loadAlarms()
        })
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(saveAlarmObserver)
        NotificationCenter.default.removeObserver(deleteAlarmObserver)
//        NotificationCenter.default.removeObserver(alarmNotificationFiredObserver)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let alarmCell = tableView.cellForRow(at: indexPath) as! AlarmCell
        viewModel.pickedAlarm.value = (alarmCell.viewModel?.alarm.value)!
        performSegue(withIdentifier: "toAddAlarmVC", sender: alarmCell)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: SectionHeaderCell.identifier) as! SectionHeaderCell
        switch section {
        case 0:
            if viewModel.active.value.count >= 1 {
                header.sectionNameLabel.text = sections[section]
            } else {
                header.sectionNameLabel.text = "No Active Alarms"
            }
        case 1:
            if viewModel.inactive.value.count >= 1 {
                header.sectionNameLabel.text = sections[section]
            } else {
                header.sectionNameLabel.text = "No Inactive Alarms"
            }
        default:
            break
        }
        return header.contentView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModel.active.value.count
        case 1:
            return viewModel.inactive.value.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlarmCell.identifier, for: indexPath) as! AlarmCell
        
        switch indexPath.section {
        case 0:
            let alarmModel = viewModel.active.value[indexPath.row]
            let viewModel = AlarmCellViewModel(model: alarmModel)
            cell.setupView(viewModel: viewModel)
            cell.mainViewController = self
        case 1:
            let alarmModel = viewModel.inactive.value[indexPath.row]
            let viewModel = AlarmCellViewModel(model: alarmModel)
            cell.setupView(viewModel: viewModel)
            cell.mainViewController = self
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let ip = indexPath
        let alarmCell = tableView.cellForRow(at: indexPath) as! AlarmCell
        let id = alarmCell.viewModel?.alarm.value?.id
        let repetition = alarmCell.viewModel?.alarm.value?.repetition
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") {  [weak self] (action, indexPath, error) in
            guard let me = self else { return }
            switch ip.section {
            case 0:
                me.viewModel.pickAlarmToDelete(alarm: me.viewModel.active.value[ip.row])
                me.viewModel.active.value.remove(at: ip.row)
            case 1:
                me.viewModel.pickAlarmToDelete(alarm: me.viewModel.inactive.value[ip.row])
                me.viewModel.inactive.value.remove(at: ip.row)
            default:
                break
            }
            
            tableView.deleteRows(at: [ip], with: .automatic)
            AlarmManager.shared.removePendingAlarmNotification(with: id!, on: repetition!)
            me.viewModel.deleteAlarm()
            me.alarmsTableView.reloadData()
            print("@@@@@  Alarm deleted  @@@@@")
        }
    
        deleteAction.backgroundColor = .red
        let actions = UISwipeActionsConfiguration(actions: [deleteAction])
        actions.performsFirstActionWithFullSwipe = false
        return actions
    }
    
}

