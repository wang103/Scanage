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
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create the image.
        let data = qrString.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter!.setValue(data, forKey: "inputMessage")
        
        let image: CIImage = filter!.outputImage!
        
        let scaleX = 500.0 / image.extent.size.width
        let scaleY = 500.0 / image.extent.size.height
        
        let scaledImage = image.imageByApplyingTransform(CGAffineTransformMakeScale(scaleX, scaleY))
        
        let qrImage = UIImage(CIImage: scaledImage)
        
        qrImageView.image = qrImage
    }
}
