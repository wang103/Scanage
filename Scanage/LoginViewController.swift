//
//  LoginViewController.swift
//  Scanage
//
//  Created by Tianyi Wang on 4/3/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    
    @IBAction func login(sender: UIButton) {
        print("Login button pressed")
    }
}
