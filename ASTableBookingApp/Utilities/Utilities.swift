//
//  Utilities.swift
//  AshishTableBookingApp
//
//  Created by ashish singh on 3/2/18.
//  Copyright © 2018 ashish. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class Utilities {
    static let receptionist = "receptionist"
    static let customer = "customer"
    static let usertype = "usertype"
    static let phonenumber = "phonenumber"
    static let userdata = "userdata"
    static let assignedtableText = "You have been assigned a table"
    
    static func showAlert(title: String, message: String, actions: [UIAlertAction], presentingController: UIViewController?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alertController.addAction(action)
        }
        presentingController?.present(alertController, animated: true, completion: nil)
    }
    
    static func getStyledStringFor(name: String, phoneNumber: String) -> NSMutableAttributedString {
        let nameString: NSMutableAttributedString = NSMutableAttributedString(string: name)
        nameString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: NSMakeRange(0, nameString.length))
        let phoneString: NSMutableAttributedString = NSMutableAttributedString(string:  String(format: " %@", phoneNumber))
        phoneString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, phoneString.length))
        nameString.append(phoneString);
        return nameString
    }
    
    static func getCustomerWaitTime() -> String? {
        let userdata = UserDefaults.standard.value(forKey: Utilities.userdata)
        if let user = userdata as? Dictionary<String, String> {
            let phoneNo = user[self.phonenumber]
            if let waitIndex = ASFirebaseDataSource.database.getWaitIndexForCustomer(phoneNo: phoneNo ?? "") {
                return "\((waitIndex + 1)*10) minutes"
            }
        }
        return nil
    }
    
    static func isCustomerAssignedTableHasUserPhoneNo(phoneNumber: String) -> Bool {
        let userdata = UserDefaults.standard.value(forKey: Utilities.userdata)
        if let user = userdata as? Dictionary<String, String> {
            let phoneNo = user[self.phonenumber]
            return phoneNo == phoneNumber
        }
        return false
    }
    
}

extension Int {
    var ordinal: String {
        var suffix: String
        let ones: Int = self % 10
        let tens: Int = (self/10) % 10
        if tens == 1 {
            suffix = "th"
        } else if ones == 1 {
            suffix = "st"
        } else if ones == 2 {
            suffix = "nd"
        } else if ones == 3 {
            suffix = "rd"
        } else {
            suffix = "th"
        }
        return "\(self)\(suffix)"
    }
    
}

