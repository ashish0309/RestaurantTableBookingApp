//
//  CustomerViewController.swift
//  AshishTableBookingApp
//
//  Created by ashish singh on 3/3/18.
//  Copyright © 2018 ashish. All rights reserved.
//

import UIKit

class CustomerViewController: UIViewController {
    var label = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        label.textAlignment = .center
        label.frame = view.bounds
        label.backgroundColor = UIColor.white
        label.text = "Fetching your wait time..."
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.initialDataFetchNotification(notification:)),
                                               name: Notification.Name(ASFirebaseDataSource.InitialDataFetch),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.customerAssignedTable(notification:)),
                                               name: Notification.Name(ASFirebaseDataSource.CustomerAssignedTable),
                                               object: nil)
    }
    
    @objc func initialDataFetchNotification(notification: Notification) {
        guard let notificationDict = notification.userInfo as? [String:Any] else {
            return
        }
        guard let allFetched = notificationDict[ASFirebaseDataSource.AllfetchedKey] as? Bool,
            allFetched else {
                label.text = "You are not in the waiting queue"
                return
        }
        if let waitTime = Utilities.getCustomerWaitTime() {
            label.text = "Your wait time is \(waitTime)"
        }
    }
    
    @objc func customerAssignedTable(notification: Notification) {
        guard let notificationDict = notification.userInfo as? [String: String],
            let phoneNo = notificationDict[Utilities.phonenumber] else {
                return
        }
        if Utilities.isCustomerAssignedTableHasUserPhoneNo(phoneNumber: phoneNo) {
            label.text = Utilities.assignedtableText
            NotificationCenter.default.removeObserver(self)
        }
        else if let waitTime = Utilities.getCustomerWaitTime(){
            label.text = "Your wait time is \(waitTime)"
        }
    }
    
    deinit {
        
    }
}

