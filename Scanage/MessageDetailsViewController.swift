//
//  MessageDetailsViewController.swift
//  Scanage
//
//  Created by Tianyi Wang on 1/12/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import Foundation
import UIKit

class MessageDetailsViewController: UIViewController {
    
    var scanningVCDelegate: ScanningViewControllerDelegate! = nil
    
    var fieldsData: NSDictionary! = nil
    
    @IBOutlet var creatorField: UILabel!
    @IBOutlet var dateField: UILabel!
    @IBOutlet var textMsgField: UITextView!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let fieldsDataDict = fieldsData.valueForKey("msg_detail") as! NSDictionary
        
        self.creatorField.text = fieldsDataDict.valueForKey("creator") as? String
        self.dateField.text = fieldsDataDict.valueForKey("create_date") as? String
        self.textMsgField.text = fieldsDataDict.valueForKey("msg_text") as? String
    }
    
    @IBAction func removeFromParent(sender: UIBarButtonItem) {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
        scanningVCDelegate!.startCaptureSession()
    }
}
