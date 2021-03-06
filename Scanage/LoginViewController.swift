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
    @IBOutlet var registerButton: UIButton!
    
    @IBOutlet var errorMsgLabel: UILabel!
    
    private var registerViewController: RegisterViewController!
    
    
    func switchToRegisterView() {
        if registerViewController == nil {
            registerViewController = storyboard?.instantiateViewControllerWithIdentifier("RegisterVC") as! RegisterViewController
            registerViewController.view.frame = view.layer.bounds
        }
        
        self.addChildViewController(registerViewController!)
        self.view.addSubview(registerViewController!.view)
        self.view.bringSubviewToFront(registerViewController!.view)
        registerViewController!.didMoveToParentViewController(self)
    }
    
    
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
                    // Successfully logged in.
                    if let accountVC = self.parentViewController as? AccountViewController {
                        accountVC.displayUserInfo()
                    }
                    
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
                if let accountVC = self.parentViewController as? AccountViewController {
                    accountVC.displayUserInfo()
                }
                
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
    
    @IBAction func register(sender: UIButton) {
        switchToRegisterView()
    }
    
    
    func startSpinner() {
        errorMsgLabel.text = ""
        usernameField.enabled = false
        passwordField.enabled = false
        loginButton.enabled = false
        registerButton.enabled = false
        
        spinner.startAnimating()
    }
    
    func stopSpinner() {
        self.spinner.stopAnimating()
        
        usernameField.enabled = true
        passwordField.enabled = true
        loginButton.enabled = true
        registerButton.enabled = true
    }
    
    func initSpinner() {
        self.view.bringSubviewToFront(spinner)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if registerViewController != nil {
            registerViewController.view.frame = view.layer.bounds
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        testIfLoggedIn()
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSpinner()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        registerViewController = storyboard?.instantiateViewControllerWithIdentifier("RegisterVC") as! RegisterViewController
        registerViewController.view.frame = view.layer.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        if registerViewController != nil && registerViewController.view.superview == nil {
            registerViewController = nil
        }
    }
}
