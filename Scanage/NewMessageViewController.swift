//
//  NewMessageViewController.swift
//  Scanage
//
//  Created by Tianyi Wang on 1/9/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import UIKit

class NewMessageViewController: UIViewController {

    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var spinnerMsgLabel: UILabel!
    
    @IBOutlet var recordingButton: UIButton!
    @IBOutlet var playingButton: UIButton!
    @IBOutlet var voiceInfoLabel: UILabel!
    
    @IBOutlet var pickImageButton: UIButton!
    @IBOutlet var clearImageButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var submitButton: UIButton!
    
    private var loginViewController: LoginViewController!
    
    
    @IBAction func recordButtonPressed() {
        
    }
    
    @IBAction func playButtonPressed() {
        
    }
    
    
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
    
    func getLoginInfoCompleted(result: NSDictionary?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.spinner.stopAnimating()
            self.spinnerMsgLabel.hidden = true
            
            if result == nil || result!.valueForKey("success") as! Bool == false {
                print("testIfLoggedIn failed")
            }
            else {
                let fLoggedIn = result!.valueForKey("is_logged_in") as! Bool
                if !fLoggedIn {
                    self.switchToLoginView()
                }
            }
        }
    }
    
    func testIfLoggedIn() {
        self.spinnerMsgLabel.hidden = false
        self.spinnerMsgLabel.text = "checking login status..."
        spinner.startAnimating()
        
        // Send a POST request to get login info.
        ServerAPIHelper.getLoginInfo(getLoginInfoCompleted)
    }
    
    override func viewWillLayoutSubviews() {
        if loginViewController != nil {
            loginViewController.view.frame = view.layer.bounds
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // If not showing the login view, test if need to log in.
        if loginViewController == nil || loginViewController.view.superview == nil {
            testIfLoggedIn()
        }
    }
    
    func initSpinner() {
        self.spinner.stopAnimating()
        self.spinnerMsgLabel.hidden = true
        
        self.view.bringSubviewToFront(spinner)
        self.view.bringSubviewToFront(spinnerMsgLabel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initSpinner()
        
        loginViewController = storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
        loginViewController.view.frame = view.layer.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if loginViewController != nil && loginViewController.view.superview == nil {
            loginViewController = nil
        }
    }
}
