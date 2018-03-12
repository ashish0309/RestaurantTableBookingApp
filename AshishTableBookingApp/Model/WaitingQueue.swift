//
//  WaitingQueue.swift
//  AshishTableBookingApp
//
//  Created by ashish singh on 3/1/18.
//  Copyright © 2018 ashish. All rights reserved.
//

import Foundation
import Firebase

enum TableState: String {
    case Waiting
    case Occupied
    case Released
}

struct WaitingCustomers {
    var customerName: String
    var phoneNumber: String
    var state: TableState
    var key: String
    var waitingIndex: Int?
    init(phoneNumber: String, name: String, state: TableState, key: String) {
        self.customerName = name
        self.state = state
        self.phoneNumber = phoneNumber
        self.key = key
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String:Any] else { return nil }
        guard let name  = dict["name"] as? String  else { return nil }
        guard let state = dict["state"]  as? String else { return nil }
        guard let tableState = TableState(rawValue: state) else {return nil}
        guard let phoneNumber = dict["phoneNumber"] as? String else { return nil }
        
        self.init(phoneNumber: phoneNumber, name: name, state: tableState, key: snapshot.key)
    }
    
    
}
