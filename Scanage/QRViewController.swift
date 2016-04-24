//
//  QRViewController.swift
//  Scanage
//
//  Created by Tianyi Wang on 4/20/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import UIKit
import Foundation
import MessageUI

class QRViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var newMsgVCDelegate: NewMessageViewControllerDelegate? = nil
    
    var qrString: String = ""
    @IBOutlet var qrImageView: UIImageView!
    var userEmail: String? = nil
    
    
    private func removeFromParentHelper() {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func removeFromParent(sender: UIBarButtonItem) {
        if newMsgVCDelegate != nil {
            newMsgVCDelegate!.clearFields()
        }
        self.removeFromParentHelper()
    }
    
    
    private func getAppName() -> String {
        let appName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
        return appName
    }
    
    @IBAction func sendEmail(sender: UIButton) {
        if (MFMailComposeViewController.canSendMail()) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            let appName = getAppName()
            mailComposer.setSubject("QR Code from \(appName)")
            mailComposer.setMessageBody("Retrieve the message by scanning with \(appName)", isHTML: false)
            
            if userEmail != nil {
                mailComposer.setToRecipients([userEmail!])
            }
            
            if let qrImageData = UIImageJPEGRepresentation(qrImageView.image!, 1.0) {
                mailComposer.addAttachmentData(qrImageData, mimeType: "image/jpeg", fileName: "qrcode")
            }
            
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Your device is not setup to send emails.",
                                          preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveImage(sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(qrImageView.image!, self,
                                       #selector(QRViewController.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func imageSaved(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafePointer<Void>) {
        if error == nil {
            let alert = UIAlertController(title: "Saved!", message: "Image has been saved to photos.",
                                          preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Save Error", message: error?.localizedDescription,
                                          preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
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
        
        let appName = getAppName()
        let text = "Scan this using \(appName), available on Apple App Store."
        let qrImageWithText = addTextToImage(text, img: qrImage)
        
        qrImageView.image = qrImageWithText
    }
}
