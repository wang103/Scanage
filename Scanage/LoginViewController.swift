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
    
    
    func removeFromParent() {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    func getLoginInfoCompleted(result: NSDictionary?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.stopSpinner()
            
            if result == nil || result!.valueForKey("success") as! Bool == false {
                print("testIfLoggedIn failed")
            }
            else {
                let fLoggedIn = result!.valueForKey("is_logged_in") as! Bool
                if fLoggedIn {
                    self.removeFromParent()
                }
            }
        }
    }
    
    func testIfLoggedIn() {
        startSpinner()
        
        // Send a POST request to get login info.
        ServerAPIHelper.getLoginInfo(getLoginInfoCompleted)
    }
    
    func loginCompleted(result: NSDictionary?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.stopSpinner()
            
            if result == nil {
                print("login failed")
            }
            else if result!.valueForKey("success") as! Bool == false {
                let ec = result!.valueForKey("ec") as! Int
                
                if ec == ServerAPIHelper.EC_INVALID_CREDS {
                    self.errorMsgLabel.text = "Invalid username or password"
                }
                else if ec == ServerAPIHelper.EC_ACCOUNT_DISABLED {
                    self.errorMsgLabel.text = "This account has been disabled"
                }
                else {
                    self.errorMsgLabel.text = "Account error"
                }
                
                return
            }
            else {
                // Successfully logged in.
                self.removeFromParent()
            }
        }
    }
    
    @IBAction func login(sender: UIButton) {
        let username = self.usernameField.text
        if username == nil || username!.isEmpty {
            errorMsgLabel.text = "Username cannot be empty"
            return
        }
        
        let password = self.passwordField.text
        if password == nil || password!.isEmpty {
            errorMsgLabel.text = "Password cannot be empty"
            return
        }
        
        self.startSpinner()
        
        // Send a POST request to log in.
        ServerAPIHelper.login(username!, password: password!, completion: loginCompleted)
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        testIfLoggedIn()
    }
    
    override func viewDidLoad() {
        initSpinner()
    }
}
