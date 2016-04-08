//
//  RegisterViewController.swift
//  Scanage
//
//  Created by Tianyi Wang on 4/8/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import Foundation
import UIKit

class RegisterViewController: UIViewController {
    
    @IBAction func removeFromParent(sender: UIBarButtonItem) {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
}
