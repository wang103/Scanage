//
//  RegisterViewController.swift
//  Scanage
//
//  Created by Tianyi Wang on 4/8/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import Foundation
import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var password1Field: UITextField!
    @IBOutlet var password2Field: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var firstnameField: UITextField!
    @IBOutlet var lastnameField: UITextField!
    
    @IBOutlet var errorMsgLabel: UILabel!
    
    @IBOutlet var submitButton: UIButton!
    
    
    @IBAction func removeFromParent(sender: UIBarButtonItem) {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func register(sender: UIButton) {
        let username = self.usernameField.text
        if username == nil || username!.isEmpty {
            errorMsgLabel.text = "Username cannot be empty"
            return
        }
        
        let password1 = self.password1Field.text
        if password1 == nil || password1!.isEmpty {
            errorMsgLabel.text = "Password cannot be empty"
            return
        }
        
        let password2 = self.password2Field.text
        if password1! != password2! {
            errorMsgLabel.text = "Passwords do not match"
            return
        }
        
        let email = self.emailField.text
        if email == nil || email!.isEmpty {
            errorMsgLabel.text = "Email cannot be empty"
            return
        }
        
        var firstName = self.firstnameField.text
        if firstName == nil {
            firstName = ""
        }
        firstName = firstName!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        
        var lastName = self.lastnameField.text
        if lastName == nil {
            lastName = ""
        }
        lastName = lastName!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        
        
    }
}
