//
//  TableBookingView.swift
//  AshishTableBookingApp
//
//  Created by ashish singh on 3/1/18.
//  Copyright © 2018 ashish. All rights reserved.
//

import UIKit

class TableBookingView: UIView{
    let phoneNumberField = UITextField()
    let nameField = UITextField()
    fileprivate let bookButton = UIButton()
    fileprivate let bottomSeparator = UIView()
    var onTap: () -> () = {}
    var bookButtonEnabled: Bool {
        get {
            return bookButton.isEnabled
        }
        set (newValue) {
            bookButton.isEnabled = newValue
            bookButton.backgroundColor = newValue ? UIColor.blue : UIColor.gray
            bookButton.layer.borderColor = newValue ? UIColor.blue.cgColor : UIColor.gray.cgColor
        }
    }
    
    convenience init(tapCallBack: @escaping () -> ()) {
        self.init()
        phoneNumberField.placeholder = "Enter 10 digit phone number"
        phoneNumberField.keyboardType = .numberPad
        phoneNumberField.addTarget(self, action: #selector(enableDisableAddCustomersButton), for: .editingChanged)
        phoneNumberField.borderStyle = UITextBorderStyle.roundedRect
        phoneNumberField.inputAccessoryView = doneToolBar()
        nameField.placeholder = "Enter Name"
        nameField.inputAccessoryView = doneToolBar()
        nameField.keyboardType = .namePhonePad
        nameField.borderStyle = UITextBorderStyle.roundedRect
        nameField.addTarget(self, action: #selector(enableDisableAddCustomersButton), for: .editingChanged)
        bookButton.setTitle("Add Customer to waiting Queue", for: .normal)
        bookButton.setTitleColor(UIColor.white, for: .normal)
        bookButton.isEnabled = false
        bookButton.addTarget(self, action: #selector(didTapBookButton), for: .touchUpInside)
        bottomSeparator.backgroundColor = UIColor.gray
        bookButton.layer.cornerRadius = 2
        bookButton.layer.borderWidth = 1
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        addSubview(nameField)
        addSubview(phoneNumberField)
        addSubview(bookButton)
        addSubview(bottomSeparator)
        onTap = tapCallBack
    }
    
    @objc func didTapBookButton() {
        onTap()
    }
    
    func resetFields() {
        nameField.text = nil
        phoneNumberField.text = nil
        nameField.becomeFirstResponder()
        enableDisableAddCustomersButton()
    }
    
    override func layoutSubviews() {
        let margin: CGFloat = 15
        nameField.frame = CGRect(x: margin, y: margin, width: bounds.width - 2 * margin, height: 35)
        phoneNumberField.frame = nameField.frame.offsetBy(dx: 0, dy: 50)
        bookButton.frame = CGRect(x: margin, y: phoneNumberField.frame.maxY + 15, width: bounds.width - 2 * margin, height: 40)
        bottomSeparator.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1)
    }
    
    @objc func enableDisableAddCustomersButton() {
        let vacantTablesCount = ASFirebaseDataSource.database.vacantTablesCount()
        guard let nameText = nameField.text,
            let enteredPhone = phoneNumberField.text else {
                bookButtonEnabled = false
                return
        }
        let phoneNoValidation = enteredPhone.count == 10
        let vacantTablesValidation = vacantTablesCount == 0
        let nameValidation = nameText.count > 0
        if phoneNoValidation && vacantTablesValidation && nameValidation {
            bookButtonEnabled = true
        }
        else {
            bookButtonEnabled = false
        }
    }
    
    func doneToolBar() -> UIToolbar {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done",
                                   style: UIBarButtonItemStyle.done,
                                   target: self,
                                   action: #selector(TableBookingView.dismissKeyboard(_:)))
        keyboardToolbar.items = [flexBarButton, done]
        return keyboardToolbar
    }
    
    @objc func dismissKeyboard(_ sender: UIBarButtonItem) {
        if nameField.isFirstResponder {
            nameField.resignFirstResponder()
        }
        else {
            phoneNumberField.resignFirstResponder()
        }
    }
    
}

