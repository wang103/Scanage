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
    
    func testIfLoggedIn() {
        self.spinnerMsgLabel.hidden = false
        self.spinnerMsgLabel.text = "checking login status..."
        spinner.startAnimating()
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 /*flags*/)
        dispatch_async(queue) {
            // Send a GET request to see if logged in.
            let result = ServerAPIHelper.getLoginInfo()
            
            dispatch_async(dispatch_get_main_queue()) {
                self.spinner.stopAnimating()
                self.spinnerMsgLabel.hidden = true
                
                if result == nil || result!.valueForKey("success") as! Bool == false {
                    print("testIfLoggedIn failed")
                }
                else {
                    //self.switchToMsgDetailsView(result!)
                    let tempResult = result!.valueForKey("is_logged_in") as! Bool
                    print("is_logged_in: \(tempResult)")
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        testIfLoggedIn()
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
