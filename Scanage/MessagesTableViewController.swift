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
    
    var messagesData: NSArray! = nil
    
    @IBOutlet var tableView: UITableView!
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableIdentifier, forIndexPath: indexPath) as! MessageTableCell
        
        let index = indexPath.row
        let msgDict = messagesData.objectAtIndex(index) as! NSDictionary
        
        cell.createdAtLabel.text = (msgDict["create_date"] as! String)
        
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(MessageTableCell.self, forCellReuseIdentifier: tableIdentifier)
        
        let nib = UINib(nibName: "MessageTableCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: tableIdentifier)
    }
}
