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
}
