//
//  File.swift
//  AshishTableBookingApp
//
//  Created by ashish singh on 3/1/18.
//  Copyright © 2018 ashish. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class ASFirebaseDataSource {
    static let WaitingCustomersModified = "Waiting_Customers_Modified"
    static let InitialDataFetch = "Initial_Data_Fetch"
    static let CustomerAssignedTable = "Customer_Assigned_Table"
    static let TotalTablesChanged = "Total_Tables_Changed"
    static let AllfetchedKey = "allfetched"
    static let database = ASFirebaseDataSource()
    
    private var ref: DatabaseReference!
    private var waitingQueueRef: DatabaseReference!
    var totalTableCount: Int?
    var occupiedTableCount: Int?
    var waitingCustomers: [WaitingCustomers]?
    
    init() {
        ref = Database.database().reference()
        waitingQueueRef = ref.child("waiting_queue")
        waitingQueueRef.observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let newCustomer = WaitingCustomers(snapshot: snapshot) else { return }
            let index = self?.findIndexOfWaitingCustomer(customer: newCustomer)
            if index == nil {
                var waitingCustomerCopy = self?.waitingCustomers
                waitingCustomerCopy?.append(newCustomer)
                self?.waitingCustomers = waitingCustomerCopy
                NotificationCenter.default.post(name: Notification.Name(ASFirebaseDataSource.WaitingCustomersModified), object: nil)
            }
        })
        
        waitingQueueRef.observe(.childRemoved, with: { [weak self] (snapshot) -> Void in
            guard let changedCustomer = WaitingCustomers(snapshot: snapshot) else
            {
                return
            }
            if let index = self?.findIndexOfWaitingCustomer(customer: changedCustomer) {
                var waitingCustomerCopy = self?.waitingCustomers
                waitingCustomerCopy?.remove(at: index)
                self?.waitingCustomers = waitingCustomerCopy
                NotificationCenter.default.post(name: Notification.Name(ASFirebaseDataSource.WaitingCustomersModified), object: nil)
                NotificationCenter.default.post(name: Notification.Name(ASFirebaseDataSource.CustomerAssignedTable),
                                                object:nil,
                                                userInfo: [Utilities.phonenumber: changedCustomer.phoneNumber])
            }
        })
        
        let inventoryRef = ref.child("Inventory")
        inventoryRef.observe(.value, with: { [weak self] (snapshot) in
            guard let dSnapShot = snapshot.value as? [String:Any],
                let newTotalTablesCount = dSnapShot["TotalTables"] as? Int,
                let newOccupiedTablesCount = dSnapShot["OccupiedTables"] as? Int else {
                    return
            }
            self?.totalTableCount = newTotalTablesCount
            self?.occupiedTableCount = newOccupiedTablesCount
            NotificationCenter.default.post(name: Notification.Name(ASFirebaseDataSource.TotalTablesChanged),
                                            object: nil)
        })
        
        fetchInitialRequiredData()
    }
    
    private func fetchInitialRequiredData() {
        getAllWaitingCustomers()
        getTablesCount()
    }
    
    func addNewCustomerInWaitingQueue(name: String, phoneNumber: String,  state: String) {
        let key = ref.child("waiting_queue").childByAutoId().key
        let new_queue_item = ["name": name,
                              "phoneNumber": phoneNumber,
                              "state": state]
        let childUpdates = ["/waiting_queue/\(key)": new_queue_item]
        ref.updateChildValues(childUpdates)
        if var customersCopy = waitingCustomers {
            customersCopy.append(WaitingCustomers(phoneNumber: phoneNumber,
                                                  name: name,
                                                  state: .Waiting, key: key))
            waitingCustomers = customersCopy
            NotificationCenter.default.post(name: Notification.Name(ASFirebaseDataSource.WaitingCustomersModified),
                                            object: nil)
        }
    }
    
    private func getTablesCount() {
        let inventoryRef = ref.child("Inventory")
        inventoryRef.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            if let dSnapShot = snapshot.value as? [String:Any] {
                self?.totalTableCount = dSnapShot["TotalTables"] as? Int
                self?.occupiedTableCount = dSnapShot["OccupiedTables"] as? Int
                NotificationCenter.default.post(name: Notification.Name(ASFirebaseDataSource.InitialDataFetch), object: nil, userInfo: [ASFirebaseDataSource.AllfetchedKey: self?.waitingCustomers != nil])
            }
        }) { (error) in
            NotificationCenter.default.post(name: Notification.Name(ASFirebaseDataSource.InitialDataFetch), object: nil, userInfo: ["error": true])
        }
    }
    
    
    private func getAllWaitingCustomers() {
        var waitingCustomers = [WaitingCustomers]()
        waitingQueueRef.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            for childSnapshot in snapshot.children {
                guard let dSnapShot = childSnapshot as? DataSnapshot,
                    let waitingCustomer = WaitingCustomers(snapshot: dSnapShot) else {
                        continue
                }
                if waitingCustomer.state == .Waiting {
                    waitingCustomers.append(waitingCustomer)
                }
            }
            self?.waitingCustomers = waitingCustomers
            NotificationCenter.default.post(name: Notification.Name(ASFirebaseDataSource.InitialDataFetch),
                                            object: nil,
                                            userInfo: [ASFirebaseDataSource.AllfetchedKey: self?.totalTableCount != nil])
        }) { (error) in
            NotificationCenter.default.post(name: Notification.Name(ASFirebaseDataSource.InitialDataFetch),
                                            object: nil,
                                            userInfo: ["error": true])
        }
    }
    
    func reserveTable(customer: WaitingCustomers) {
        if var waitingCustomerCopy = waitingCustomers {
            if let index = findIndexOfWaitingCustomer(customer: customer) {
                waitingCustomerCopy.remove(at: index)
                waitingCustomers = waitingCustomerCopy
            }
        }
        ref.child("/waiting_queue/\(customer.key)").removeValue()
        if let vOccupiedTableCount = occupiedTableCount {
            ref.child("Inventory").child("OccupiedTables").setValue(vOccupiedTableCount + 1)
            occupiedTableCount = vOccupiedTableCount + 1
        }
        
    }
    
    private func findIndexOfWaitingCustomer(customer: WaitingCustomers) -> Int? {
        guard let waitingCustomers = waitingCustomers else {
            return nil
        }
        if let index:Int = waitingCustomers.index(where: {$0.key == customer.key}) {
            return index
        }
        return nil
    }
    
    func updateOccupiedTable(value: Int) {
        if let vOccupiedTableCount = occupiedTableCount {
            ref.child("Inventory").child("OccupiedTables").setValue(vOccupiedTableCount + value)
            occupiedTableCount = vOccupiedTableCount + value
        }
    }
    
    func vacantTablesCount() -> Int {
        guard let totalTables = totalTableCount, let occpTables = occupiedTableCount else {
            return 0
        }
        return totalTables - occpTables >= 0 ? totalTables - occpTables : 0
    }
    
    func getSearchedCustomers(searchedtext: String) -> [WaitingCustomers] {
        var searchedCustomers = [WaitingCustomers]()
        guard let waitingCustomers = waitingCustomers else {
            return searchedCustomers
        }
        for i in 0..<waitingCustomers.count {
            var customer = waitingCustomers[i]
            let lowercasedname = customer.customerName.lowercased()
            if lowercasedname.hasPrefix(searchedtext) || customer.phoneNumber.hasPrefix(searchedtext) {
                customer.waitingIndex = i
                searchedCustomers.append(customer)
            }
        }
        return searchedCustomers
    }
    
    func checkPhoneNumberPresentForNewCustomerInWaitingQueue(phoneNo: String) -> Bool {
        if let waitingCustomers = waitingCustomers {
            if  waitingCustomers.index(where: {$0.phoneNumber == phoneNo && $0.state == TableState.Waiting}) != nil {
                return true
            }
        }
        return false
    }
    
    func getWaitIndexForCustomer(phoneNo: String) -> Int? {
        let customers = getSearchedCustomers(searchedtext: phoneNo)
        if customers.count > 0 {
            return customers[0].waitingIndex
        }
        return nil
    }
    
    func allTablesOccupied() -> Bool {
        guard let occupiedTableCount = occupiedTableCount,
            let totalTableCount = totalTableCount else {
                return false
        }
        return occupiedTableCount == totalTableCount
    }
    
    deinit {
        ref.removeAllObservers()
    }
}

