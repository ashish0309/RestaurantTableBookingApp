//
//  ViewController.swift
//  AshishTableBookingApp
//
//  Created by ashish singh on 2/28/18.
//  Copyright © 2018 ashish. All rights reserved.
//

import UIKit
import Firebase

class TableBookingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    static let waitingCustomerCellIdentifier = "waitingCustomerCell"
    static let defaultCellIdentifier = "defaultCell"
    var ref: DatabaseReference!
    var bookingView: TableBookingView!
    var tableDataSource = TableBookingTableViewDataSource()
    @IBOutlet weak var tableView: UITableView!
    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        tableView.delegate = self
        tableView.dataSource = self
        let bookButtonAction = { [weak self]  in
            guard let phoneNo = self?.bookingView.phoneNumberField.text, let name = self?.bookingView.nameField.text else {
                return
            }
            if ASFirebaseDataSource.database.checkPhoneNumberPresentForNewCustomerInWaitingQueue(phoneNo: phoneNo) {
                let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                Utilities.showAlert(title: "Error", message: "Customer can't be added to waiting queue since customer with phone number \(phoneNo) exists in the queue", actions: [action], presentingController: self)
                return
            }
            ASFirebaseDataSource.database.addNewCustomerInWaitingQueue(name: name, phoneNumber: phoneNo, state: TableState.Waiting.rawValue)
            self?.bookingView.resetFields()
            //self?.tableView.reloadData()
        }
        bookingView = TableBookingView(tapCallBack: bookButtonAction)
        bookingView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 170)
        tableView.tableHeaderView = bookingView
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        activityIndicator.backgroundColor = UIColor.white
        activityIndicator.frame = view.bounds
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.initialDataFetchNotification(notification:)),
                                               name: Notification.Name(ASFirebaseDataSource.InitialDataFetch),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.waitingCustomersDataChangedNotification),
                                               name: Notification.Name(ASFirebaseDataSource.WaitingCustomersModified),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.totalTablesChangedNotification),
                                               name: Notification.Name(ASFirebaseDataSource.TotalTablesChanged),
                                               object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCountOfVacantTables()
        bookingView.enableDisableAddCustomersButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.title = ""
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableDataSource.heightForRow(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewModel = tableDataSource.bookingViewModelFor(section: indexPath.section)
        var cell = tableView.dequeueReusableCell(withIdentifier: tableViewModel.cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: tableViewModel.cellStyle, reuseIdentifier: tableViewModel.cellIdentifier)
        }
        cell?.accessoryType = tableViewModel.disclosure
        cell?.textLabel?.text = tableViewModel.text
        cell?.textLabel?.textColor = tableViewModel.textColor
        cell?.detailTextLabel?.text = tableViewModel.detailText
        cell?.detailTextLabel?.textColor = tableViewModel.detailTextColor
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == TableRows.WaitingCustomers.rawValue {
            let waitingCustomersVC = WaitingCustomerTableViewController(nibName: nil, bundle: nil)
            navigationController?.pushViewController(waitingCustomersVC, animated: true)
        }
        else if indexPath.section == TableRows.SearchWaitingCustomers.rawValue{
            let searchWaitingCustomerVC = SearchWaitingCustomersViewController(nibName: nil, bundle: nil)
            navigationController?.pushViewController(searchWaitingCustomerVC, animated: true)
        }
        else if indexPath.section == TableRows.ReleaseTable.rawValue {
            ASFirebaseDataSource.database.updateOccupiedTable(value: -1)
        }
        else if indexPath.section == TableRows.AssignTable.rawValue {
            ASFirebaseDataSource.database.updateOccupiedTable(value: 1)
        }
    }
    
    @objc func initialDataFetchNotification(notification: Notification){
        if let notificationDict = notification.userInfo as? [String:Any] {
            if let allFetched = notificationDict[ASFirebaseDataSource.AllfetchedKey] as? Bool,  allFetched {
                activityIndicator.stopAnimating()
                updateCountOfVacantTables()
                reloadTableView()
            }
        }
    }
    
    @objc func waitingCustomersDataChangedNotification(notification: Notification){
        updateCountOfVacantTables()
        reloadTableView()
    }
    
    @objc func totalTablesChangedNotification(notification: Notification){
        updateCountOfVacantTables()
        reloadTableView()
    }
    
    func reloadTableView() {
        if ASFirebaseDataSource.database.allTablesOccupied() {
            tableView.tableHeaderView = bookingView
        }
        else {
            tableView.tableHeaderView = nil
        }
        tableView.reloadData()
    }
    func updateCountOfVacantTables() {
        navigationItem.title = tableDataSource.headerTitle
        //needed to refresh the title
        navigationController?.navigationBar.layoutIfNeeded()
    }
    
    deinit {
        
    }
    
}

