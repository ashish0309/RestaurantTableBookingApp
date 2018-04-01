//
//  LoginViewController.swift
//  AshishTableBookingApp
//
//  Created by ashish singh on 3/2/18.
//  Copyright © 2018 ashish. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var receptionistLoginButton: UIButton!
    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
        //activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        activityIndicator.backgroundColor = UIColor.white
        textField.placeholder = "Phone No required for Customer Login"
        navigationItem.title = "Sign Up"
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        activityIndicator.frame = view.bounds
    }
    
    @IBAction func receptionistBtnAction(_ sender: Any) {
        createUserInFirebase(isCustomerLogin: false)
    }
    
    @IBAction func customerLoginButtonAction(_ sender: Any) {
        activityIndicator.startAnimating()
        guard let phoneText = textField.text else {
            activityIndicator.stopAnimating()
            showPhoneNumberRequiredAlert()
            return
        }
        if phoneText.count == 10 {
            createUserInFirebase(isCustomerLogin: true)
        }
        else {
            activityIndicator.stopAnimating()
            showPhoneNumberRequiredAlert()
        }
    }
    
    func createUserInFirebase(isCustomerLogin: Bool) {
        Auth.auth().signInAnonymously() { [weak self] (user, error) in
            self?.activityIndicator.stopAnimating()
            if error != nil {
                let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                Utilities.showAlert(title: "Sign up failed",
                                    message: error!.localizedDescription,
                                    actions: [action], presentingController: self)
                return
            }
            let _ = ASFirebaseDataSource.database
            if !isCustomerLogin {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier :"ViewController")
                self?.navigationController?.pushViewController(viewController, animated: false)
                UserDefaults.standard.setValue([Utilities.usertype: Utilities.receptionist], forKey: Utilities.userdata)
                UserDefaults.standard.synchronize()
            }
            else {
                let viewController = CustomerViewController(nibName: nil, bundle: nil)
                self?.navigationController?.pushViewController(viewController, animated: false)
                UserDefaults.standard.setValue([Utilities.usertype: Utilities.customer, Utilities.phonenumber: self?.textField.text!], forKey: Utilities.userdata)
                UserDefaults.standard.synchronize()
            }
            self?.navigationController?.viewControllers.remove(at: 0)
        }
    }
    
    func showPhoneNumberRequiredAlert() {
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        Utilities.showAlert(title: "Phone Number is required",
                            message: "Please enter a valid 10 digit phone number",
                            actions: [action], presentingController: self)
    }
    
}

