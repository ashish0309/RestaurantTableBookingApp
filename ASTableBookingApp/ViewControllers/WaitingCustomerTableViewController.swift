//
//  WaitingCustomerTableViewController.swift
//  AshishTableBookingApp
//
//  Created by ashish singh on 3/1/18.
//  Copyright © 2018 ashish. All rights reserved.
//

import UIKit

class WaitingCustomerTableViewController: UITableViewController {
    let defaultCellIdentifier = "defaultCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCountOfVacantTables()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.waitingCustomersDataChangedNotification),
                                               name: Notification.Name(ASFirebaseDataSource.WaitingCustomersModified),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.totalTablesChangedNotification),
                                               name: Notification.Name(ASFirebaseDataSource.TotalTablesChanged),
                                               object: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ASFirebaseDataSource.database.waitingCustomers!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let waitingCustomer = ASFirebaseDataSource.database.waitingCustomers![indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: defaultCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: defaultCellIdentifier)
        }
        let name = indexPath.row == 0 ? String(waitingCustomer.customerName.prefix(8)) : waitingCustomer.customerName
        cell?.detailTextLabel?.text = ""
        cell?.textLabel?.attributedText = Utilities.getStyledStringFor(name: name, phoneNumber: waitingCustomer.phoneNumber)
        if indexPath.row == 0 && ASFirebaseDataSource.database.vacantTablesCount() > 0 {
            cell?.detailTextLabel?.text = "Reserve Table"
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
            cell?.detailTextLabel?.textColor = UIColor.blue
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == 0 && ASFirebaseDataSource.database.vacantTablesCount() > 0 else {
            return
        }
        let waitingCustomer = ASFirebaseDataSource.database.waitingCustomers![indexPath.row]
        ASFirebaseDataSource.database.reserveTable(customer: waitingCustomer)
        tableView.reloadData()
    }
    
    @objc func totalTablesChangedNotification(notification: Notification){
        updateCountOfVacantTables()
        tableView.reloadData()
    }
    
    @objc func waitingCustomersDataChangedNotification(notification: Notification){
        updateCountOfVacantTables()
        tableView.reloadData()
    }
    
    func updateCountOfVacantTables() {
        guard let _ = ASFirebaseDataSource.database.waitingCustomers else {
            return
        }
        let count = "\(ASFirebaseDataSource.database.vacantTablesCount())"
        let title = "Vacant Tables Count: \(count)"
        navigationItem.title = title
        //needed to refresh the title
        navigationController?.navigationBar.layoutIfNeeded()
    }
    
    deinit {
        
    }
}

