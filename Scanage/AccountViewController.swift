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
    
    
    func logoutCompleted() {
        dispatch_async(dispatch_get_main_queue()) {
            self.stopSpinner()
            
            // Show the login view.
            
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
