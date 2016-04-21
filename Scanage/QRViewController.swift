//
//  QRViewController.swift
//  Scanage
//
//  Created by Tianyi Wang on 4/20/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import UIKit
import Foundation

class QRViewController: UIViewController {
    
    var qrString: String = ""
    @IBOutlet var qrImageView: UIImageView!
    
    
    private func removeFromParentHelper() {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func removeFromParent(sender: UIBarButtonItem) {
        self.removeFromParentHelper()
    }
}
