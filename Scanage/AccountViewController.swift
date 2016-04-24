//
//  AccountViewController.swift
//  Scanage
//
//  Created by Tianyi Wang on 1/9/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {

    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var messagesButton: UIButton!
    
    private var loginViewController: LoginViewController!
    private var messagesTableViewController: MessagesTableViewController!
    
    
    func switchToLoginView() {
        if loginViewController == nil {
            loginViewController = storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
            loginViewController.view.frame = view.layer.bounds
        }
        
        self.addChildViewController(loginViewController!)
        self.view.addSubview(loginViewController!.view)
        self.view.bringSubviewToFront(loginViewController!.view)
        loginViewController!.didMoveToParentViewController(self)
    }
    
    func switchToMessagesView(messagesData: NSArray) {
        messagesTableViewController = storyboard?.instantiateViewControllerWithIdentifier("MessagesTableVC") as! MessagesTableViewController
        messagesTableViewController.view.frame = view.layer.bounds
        
        messagesTableViewController.email = emailLabel.text!
        messagesTableViewController.messagesData = messagesData
        
        self.addChildViewController(messagesTableViewController!)
        self.view.addSubview(messagesTableViewController!.view)
        self.view.bringSubviewToFront(messagesTableViewController!.view)
        messagesTableViewController!.didMoveToParentViewController(self)
    }
    
    
    func getUserMessagesCompleted(result: NSDictionary?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.stopSpinner()
            
            if result == nil {
                print("getMessages failed")
            }
            else if result!.valueForKey("success") as! Bool == false {
                let ec = result!.valueForKey("ec") as! Int
                
                if ec == ServerAPIHelper.EC_NOT_LOGGED_IN {
                    self.switchToLoginView()
                }
            }
            else {
                let messagesDataArray = result!.valueForKey("msgs") as! NSArray
                
                self.switchToMessagesView(messagesDataArray)
            }
        }
    }
    
    func getUserInfoCompleted(result: NSDictionary?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.stopSpinner()
            
            if result == nil {
                print("getUserInfo failed")
            }
            else if result!.valueForKey("success") as! Bool == false {
                let ec = result!.valueForKey("ec") as! Int
                
                if ec == ServerAPIHelper.EC_NOT_LOGGED_IN {
                    self.switchToLoginView()
                }
            }
            else {
                // Successfully got user info.
                let userInfo = result!.valueForKey("user_info") as! NSDictionary
                let username = userInfo.valueForKey("username") as! String
                let email = userInfo.valueForKey("email") as! String
                let firstName = userInfo.valueForKey("first_name") as! String
                let lastName = userInfo.valueForKey("last_name") as! String
                
                self.usernameLabel.text = username
                self.emailLabel.text = email
                self.nameLabel.text = firstName + " " + lastName
            }
        }
    }
    
    func displayUserInfo() {
        startSpinner()
        
        // Send a POST request to get user info.
        ServerAPIHelper.getUserInfo(getUserInfoCompleted)
    }
    
    func logoutCompleted() {
        dispatch_async(dispatch_get_main_queue()) {
            self.stopSpinner()
            
            // Show the login view.
            self.displayUserInfo()
        }
    }
    
    @IBAction func logout(sender: UIButton) {
        let controller = UIAlertController(title: "Are you sure?",
                                           message:nil, preferredStyle: .ActionSheet)
        
        let yesAction = UIAlertAction(title: "Yes, log me out",
                                      style: .Destructive, handler: { action in
            self.startSpinner()
            
            // Send a POST request to log out.
            ServerAPIHelper.logout(self.logoutCompleted)
        })
        
        let noAction = UIAlertAction(title: "No", style: .Cancel, handler: nil)
        
        controller.addAction(yesAction)
        controller.addAction(noAction)
        
        if let ppc = controller.popoverPresentationController {
            ppc.sourceView = sender
            ppc.sourceRect = sender.bounds
        }
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func showMessages(sender: UIButton) {
        startSpinner()
        
        // Send a POST request to get all user messages.
        ServerAPIHelper.getMessages(self.getUserMessagesCompleted)
    }
    
    func startSpinner() {
        logoutButton.enabled = false
        messagesButton.enabled = false
        
        spinner.startAnimating()
    }
    
    func stopSpinner() {
        spinner.stopAnimating()
        
        logoutButton.enabled = true
        messagesButton.enabled = true
    }
    
    override func viewWillLayoutSubviews() {
        if loginViewController != nil {
            loginViewController.view.frame = view.layer.bounds
        }
        
        if messagesTableViewController != nil {
            messagesTableViewController.view.frame = view.layer.bounds
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // If not showing any sub view, grab the user info.
        if (loginViewController == nil || loginViewController.view.superview == nil) &&
           (messagesTableViewController == nil || messagesTableViewController.view.superview == nil) {
            displayUserInfo()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginViewController = storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
        loginViewController.view.frame = view.layer.bounds
        
        messagesTableViewController = storyboard?.instantiateViewControllerWithIdentifier("MessagesTableVC") as! MessagesTableViewController
        messagesTableViewController.view.frame = view.layer.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if loginViewController != nil && loginViewController.view.superview == nil {
            loginViewController = nil
        }
        
        if messagesTableViewController != nil && messagesTableViewController.view.superview == nil {
            messagesTableViewController = nil
        }
    }
}
