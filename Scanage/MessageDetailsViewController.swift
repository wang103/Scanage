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
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    @IBAction func removeFromParent(sender: UIBarButtonItem) {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
        scanningVCDelegate!.startCaptureSession()
    }
}
