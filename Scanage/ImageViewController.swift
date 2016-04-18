//
//  ImageViewController.swift
//  Scanage
//
//  Created by Tianyi Wang on 4/18/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import Foundation
import UIKit

class ImageViewController: UIViewController {
    
    var imageData: NSData? = nil
    @IBOutlet var imageView: UIImageView!
    
    
    private func removeFromParentHelper() {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if imageData != nil {
            imageView.image = UIImage(data: imageData!)
        }
        else {
            imageView.image = nil
        }
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        removeFromParentHelper()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.tap(_:)))
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
}
