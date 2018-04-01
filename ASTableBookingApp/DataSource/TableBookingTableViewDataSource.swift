//
//  TableBookingTableViewDataSource.swift
//  AshishTableBookingApp
//
//  Created by ashish singh on 3/12/18.
//  Copyright © 2018 ashish. All rights reserved.
//

import Foundation
import UIKit

enum TableRows: Int {
    
    case WaitingCustomers
    case SearchWaitingCustomers
    case AssignTable
    case ReleaseTable
    
    func associatedRowText() -> String {
        switch self {
        case .WaitingCustomers:
            return "Waiting Customers"
        case .SearchWaitingCustomers:
            return "Search Waiting Customer"
        case .AssignTable:
            return "Tap to assign a Table to Customer"
        case .ReleaseTable:
            return "Tap to release a Table"
        }
    }
}

struct BookingTableRowModel {
    var detailText: String?
    var text: String?
    var disclosure = UITableViewCellAccessoryType.none
    var detailTextColor = UIColor.black
    var textColor = UIColor.black
    var cellIdentifier = TableBookingViewController.defaultCellIdentifier
    var cellStyle = UITableViewCellStyle.default
    
    init(text: String?, detailText: String?, textColor: UIColor,
         detailTextColor: UIColor,
         disclosureType: UITableViewCellAccessoryType,
         cellIdentifier: String,
         cellStyle: UITableViewCellStyle) {
        self.text = text
        self.detailText = detailText
        self.detailTextColor = detailTextColor
        self.textColor = textColor
        self.disclosure = disclosureType
        self.cellIdentifier = cellIdentifier
        self.cellStyle = cellStyle
    }
    init() {
        
    }
}

struct TableBookingTableViewDataSource {
    var headerTitle: String {
        var title = ""
        if ASFirebaseDataSource.database.waitingCustomers == nil {
            return title
        }
        let vacantTablesCount = ASFirebaseDataSource.database.vacantTablesCount()
        if let totalTables = ASFirebaseDataSource.database.totalTableCount, vacantTablesCount == totalTables {
            title = "All Tables are free!"
        }
        else if vacantTablesCount == 0 {
            title = "All Tables are occupied"
        }
        else {
            title = "Vacant Tables Count: \(vacantTablesCount)"
        }
        return title
    }
    
    func bookingViewModelFor(section: Int) -> BookingTableRowModel {
        var model = BookingTableRowModel()
        if section == TableRows.WaitingCustomers.rawValue {
            model.cellStyle = .value1
            model.cellIdentifier = TableBookingViewController.waitingCustomerCellIdentifier
        }
        if section < 2 {
            model.disclosure = .disclosureIndicator
        }
        model.text = TableRows(rawValue: section)?.associatedRowText()
        model.textColor = section < 2 ? UIColor.black : UIColor.blue
        if let count = ASFirebaseDataSource.database.waitingCustomers?.count,
            section == TableRows.WaitingCustomers.rawValue {
            model.detailText = "\(count)"
            model.detailTextColor = UIColor.red
        }
        return model
    }
    
    func heightForRow(indexPath: IndexPath) -> CGFloat {
        if let occupiedTablesCount = ASFirebaseDataSource.database.occupiedTableCount,
            TableRows.ReleaseTable.rawValue == indexPath.section {
            return occupiedTablesCount > 0 ? 50 : 0.1
        }
        else if TableRows.AssignTable.rawValue == indexPath.section {
            let vacantTables = ASFirebaseDataSource.database.vacantTablesCount()
            if let waitingCustomersCount =  ASFirebaseDataSource.database.waitingCustomers {
                return vacantTables > 0 && waitingCustomersCount.count == 0 ? 50 : 0.1
            }
            return 0.1
        }
        return 50
    }
}

