//
//  MessagesTableViewController.swift
//  Scanage
//
//  Created by Tianyi Wang on 4/23/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import Foundation
import UIKit

class MessagesTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableIdentifier = "MessagesTableIdentifier"
    
    var email: String = ""
    var messagesData: NSArray! = nil
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var spinnerMsgLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    private var qrViewController: QRViewController!
    private var msgDetailsViewController: MessageDetailsViewController!
    
    
    func switchToQRView(qrString: String) {
        if qrViewController == nil {
            qrViewController = storyboard?.instantiateViewControllerWithIdentifier("QRVC") as! QRViewController
            qrViewController.view.frame = view.layer.bounds
        }
        
        qrViewController.qrString = qrString
        qrViewController.userEmail = email
        
        self.addChildViewController(qrViewController!)
        self.view.addSubview(qrViewController!.view)
        self.view.bringSubviewToFront(qrViewController!.view)
        qrViewController!.didMoveToParentViewController(self)
    }
    
    func qrButtonPressed(sender: UIButton) {
        let index = sender.tag
        
        let msgDict = messagesData.objectAtIndex(index) as! NSDictionary
        let qrString = msgDict["qr_str"] as! String
        
        switchToQRView(qrString)
    }
    
    
    func switchToMsgDetailsView(result: NSDictionary) {
        if msgDetailsViewController == nil {
            msgDetailsViewController = storyboard?.instantiateViewControllerWithIdentifier("MsgDetailsVC") as! MessageDetailsViewController
            msgDetailsViewController.view.frame = view.layer.bounds
        }
        
        msgDetailsViewController.fieldsData = result
        
        // Get the NSData for audio and image now.
        msgDetailsViewController.audioData = nil
        let fieldsDataDict = result.valueForKey("msg_detail") as! NSDictionary
        
        if let audioURLStr = fieldsDataDict["audio_file"] {
            spinnerMsgLabel.text = "Downloading audio file"
            
            if let url = NSURL(string: audioURLStr as! String) {
                if let data = NSData(contentsOfURL: url) {
                    msgDetailsViewController.audioData = data
                }
            }
        }
        
        msgDetailsViewController.imageData = nil
        if let imageURLStr = fieldsDataDict["image_file"] {
            spinnerMsgLabel.text = "Downloading image file"
            
            if let url = NSURL(string: imageURLStr as! String) {
                if let data = NSData(contentsOfURL: url) {
                    msgDetailsViewController.imageData = data
                }
            }
        }
        
        stopSpinner()
        
        self.addChildViewController(msgDetailsViewController!)
        self.view.addSubview(msgDetailsViewController!.view)
        self.view.bringSubviewToFront(msgDetailsViewController!.view)
        msgDetailsViewController!.didMoveToParentViewController(self)
    }
    
    func detailsButtonPressed(sender: UIButton) {
        startSpinner()
        spinnerMsgLabel.text = "Looking up..."
        
        let index = sender.tag
        
        let msgDict = messagesData.objectAtIndex(index) as! NSDictionary
        let qrString = msgDict["qr_str"] as! String
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 /*flags*/)
        dispatch_async(queue) {
            // Send a GET request to retrieve the msg associated with the QR string.
            let result = ServerAPIHelper.getMessage(qrString)
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if result == nil || result!.valueForKey("success") as! Bool == false {
                    // QR code is not a Scanage QR.
                    self.stopSpinner()
                    
                    let alert = UIAlertController(title: "Error", message: "This message no longer exists.",
                                                  preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else {
                    self.switchToMsgDetailsView(result!)
                }
            }
        }
    }
    
    
    private func startSpinner() {
        self.spinner.startAnimating()
        
        self.tableView.scrollEnabled = false
        
        for cell in tableView.visibleCells {
            let messageCell = cell as! MessageTableCell
            messageCell.qrButton.enabled = false
            messageCell.detailsButton.enabled = false
        }
    }
    
    private func stopSpinner() {
        spinnerMsgLabel.text = ""
        self.spinner.stopAnimating()
        
        for cell in tableView.visibleCells {
            let messageCell = cell as! MessageTableCell
            messageCell.qrButton.enabled = true
            messageCell.detailsButton.enabled = true
        }
        
        self.tableView.scrollEnabled = true
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableIdentifier, forIndexPath: indexPath) as! MessageTableCell
        
        let index = indexPath.row
        let msgDict = messagesData.objectAtIndex(index) as! NSDictionary
        
        cell.indexLabel.text = "\(index + 1)"
        let utcTimeStr = msgDict["create_date"] as! String
        cell.createdAtLabel.text = Utils.convertUTCToLocal(utcTimeStr)
        
        cell.qrButton.tag = index
        cell.detailsButton.tag = index
        
        cell.qrButton.addTarget(self, action: #selector(MessagesTableViewController.qrButtonPressed(_:)),
                                forControlEvents: .TouchUpInside)
        cell.detailsButton.addTarget(self, action: #selector(MessagesTableViewController.detailsButtonPressed(_:)),
                                     forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 81.0
    }
    
    private func removeFromParentHelper() {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func removeFromParent(sender: UIBarButtonItem) {
        let accountVC = self.parentViewController as? AccountViewController
        self.removeFromParentHelper()
        
        if accountVC != nil {
            accountVC!.displayUserInfo()
        }
        
        messagesData = nil
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if qrViewController != nil {
            qrViewController.view.frame = view.layer.bounds
        }
        
        if msgDetailsViewController != nil {
            msgDetailsViewController.view.frame = view.layer.bounds
        }
    }
    
    func initSpinner() {
        self.view.bringSubviewToFront(spinner)
        self.view.bringSubviewToFront(spinnerMsgLabel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSpinner()
        
        tableView.registerClass(MessageTableCell.self, forCellReuseIdentifier: tableIdentifier)
        
        let nib = UINib(nibName: "MessageTableCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: tableIdentifier)
        
        for case let x as UIScrollView in tableView.subviews {
            x.delaysContentTouches = false
        }
        
        qrViewController = storyboard?.instantiateViewControllerWithIdentifier("QRVC") as! QRViewController
        qrViewController.view.frame = view.layer.bounds
        
        msgDetailsViewController = storyboard?.instantiateViewControllerWithIdentifier("MsgDetailsVC") as! MessageDetailsViewController
        msgDetailsViewController.view.frame = view.layer.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if qrViewController != nil && qrViewController.view.superview == nil {
            qrViewController = nil
        }
        
        if msgDetailsViewController != nil && msgDetailsViewController.view.superview == nil {
            msgDetailsViewController = nil
        }
    }
}
