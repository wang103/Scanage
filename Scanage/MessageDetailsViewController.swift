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
    
    @IBOutlet var playButton: UIButton!
    @IBOutlet var playInfoLabel: UILabel!
    @IBOutlet var playProgress: UIProgressView!
    @IBOutlet var voiceMsgErrorLabel: UILabel!
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageMsgErrorLabel: UILabel!
    
    @IBOutlet var textMsgField: UITextView!
    @IBOutlet var textMsgErrorLabel: UILabel!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let fieldsDataDict = fieldsData.valueForKey("msg_detail") as! NSDictionary
        
        self.creatorField.text = fieldsDataDict.valueForKey("creator") as? String
        self.dateField.text = fieldsDataDict.valueForKey("create_date") as? String
        
        if let imageURLStr = fieldsDataDict["image_file"] {
            imageMsgErrorLabel.text = ""
            
            if let url = NSURL(string: imageURLStr as! String) {
                if let data = NSData(contentsOfURL: url) {
                    imageView.image = UIImage(data: data)
                }
            }
        }
        else {
            imageMsgErrorLabel.text = "empty"
        }
        
        let textMsg = fieldsDataDict.valueForKey("msg_text") as? String
        if textMsg == nil || textMsg!.isEmpty {
            self.textMsgField.text = ""
            self.textMsgErrorLabel.text = "empty"
        }
        else {
            self.textMsgField.text = textMsg!
            self.textMsgErrorLabel.text = ""
        }
    }
    
    @IBAction func removeFromParent(sender: UIBarButtonItem) {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
        scanningVCDelegate!.startCaptureSession()
    }
}
