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
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    @IBOutlet var errorMsgLabel: UILabel!
    
    
    @IBAction func login(sender: UIButton) {
        print("Login button pressed")
    }
    
    
    func startSpinner() {
        errorMsgLabel.text = ""
        usernameField.enabled = false
        passwordField.enabled = false
        loginButton.enabled = false
        
        spinner.startAnimating()
    }
    
    func stopSpinner() {
        self.spinner.stopAnimating()
        
        usernameField.enabled = true
        passwordField.enabled = true
        loginButton.enabled = true
    }
    
    func initSpinner() {
        self.view.bringSubviewToFront(spinner)
    }
    
    override func viewDidLoad() {
        initSpinner()
    }
}
