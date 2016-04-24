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
    
    @IBOutlet var tableView: UITableView!
    
    private var qrViewController: QRViewController!
    
    
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
    
    func detailsButtonPressed(sender: UIButton) {
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableIdentifier, forIndexPath: indexPath) as! MessageTableCell
        
        let index = indexPath.row
        let msgDict = messagesData.objectAtIndex(index) as! NSDictionary
        
        cell.indexLabel.text = "\(index + 1)"
        cell.createdAtLabel.text = (msgDict["create_date"] as! String)
        
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(MessageTableCell.self, forCellReuseIdentifier: tableIdentifier)
        
        let nib = UINib(nibName: "MessageTableCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: tableIdentifier)
        
        for case let x as UIScrollView in tableView.subviews {
            x.delaysContentTouches = false
        }
        
        qrViewController = storyboard?.instantiateViewControllerWithIdentifier("QRVC") as! QRViewController
        qrViewController.view.frame = view.layer.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if qrViewController != nil && qrViewController.view.superview == nil {
            qrViewController = nil
        }
    }
}
