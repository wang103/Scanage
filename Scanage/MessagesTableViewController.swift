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
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(tableIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: tableIdentifier)
        }
        
        let index = indexPath.row
        let msgDict = messagesData.objectAtIndex(index) as! NSDictionary
        
        cell!.textLabel!.text = (msgDict["create_date"] as! String)
        
        return cell!
    }
    
    
    private func removeFromParentHelper() {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func removeFromParent(sender: UIBarButtonItem) {
        self.removeFromParentHelper()
    }
}
