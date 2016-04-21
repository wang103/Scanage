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
    
    var newMsgVCDelegate: NewMessageViewControllerDelegate! = nil
    
    var qrString: String = ""
    @IBOutlet var qrImageView: UIImageView!
    
    
    private func removeFromParentHelper() {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func removeFromParent(sender: UIBarButtonItem) {
        newMsgVCDelegate!.clearFields()
        self.removeFromParentHelper()
    }
    
    
    @IBAction func sendEmail(sender: UIButton) {
        
    }
    
    
    private func addTextToImage(text: String, img: UIImage) -> UIImage {
        
        let textFont: UIFont = UIFont(name: "Helvetica Bold", size: 18)!
        let textColor: UIColor = UIColor.init(red: 0.28, green: 0.64, blue: 0.98, alpha: 1.0)
        
        let extendHeight: CGFloat = 25.0
        var imageSize = img.size
        imageSize.height += extendHeight
        
        UIGraphicsBeginImageContext(imageSize)
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor
        ]
        
        // Write the image on top.
        img.drawInRect(CGRectMake(0, 0, img.size.width, img.size.height))
        
        // Write the text on bottom.
        let textRect = CGRectMake(5, img.size.height, img.size.width - 10, extendHeight)
        
        (text as NSString).drawInRect(textRect, withAttributes: textFontAttributes)
        
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImg
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
        
        let appName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
        let text = "Scan this using \(appName), available on Apple App Store."
        let qrImageWithText = addTextToImage(text, img: qrImage)
        
        qrImageView.image = qrImageWithText
    }
}
