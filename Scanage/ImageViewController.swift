//
//  ImageViewController.swift
//  Scanage
//
//  Created by Tianyi Wang on 4/18/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import Foundation
import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var imageData: NSData? = nil
    private var image: UIImage? = nil
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    
    private func removeFromParentHelper() {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if imageView.image == nil && imageData != nil {
            image = UIImage(data: imageData!)
            imageView.image = image
            
            imageView.bounds = CGRectMake(0, 0, image!.size.width, image!.size.height)
            scrollView.contentSize = image!.size
            
            scrollView.zoomScale = 1
        }
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            removeFromParentHelper()
        }
    }
    
    func doubleTap(gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            scrollView.zoomScale = 5
        }
        else {
            scrollView.zoomScale = 1
        }
    }
    
    func longPress(gesture: UITapGestureRecognizer) {
        if gesture.state != .Began {
            return
        }
        
        let controller = UIAlertController(title: "What would you like to do?",
                                           message:nil, preferredStyle: .ActionSheet)
        
        let saveAction = UIAlertAction(title: "Save image",
                                       style: .Default, handler: { action in
            UIImageWriteToSavedPhotosAlbum(self.image!, self,
                #selector(ImageViewController.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        controller.addAction(saveAction)
        controller.addAction(cancelAction)
        
        if let ppc = controller.popoverPresentationController {
            ppc.sourceView = scrollView
            ppc.sourceRect = CGRectMake(scrollView.bounds.origin.x + scrollView.bounds.size.width / 2,
                                        scrollView.bounds.origin.y + scrollView.bounds.size.height / 2,
                                        1, 1)
        }

        presentViewController(controller, animated: true, completion: nil)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Single tap to dismiss if zoom is 1.0.
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.tap(_:)))
        singleTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(singleTap)
        
        // Double taps to reset zoom to 1.0 if it is not.
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.doubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        // Long press to show menu for image.
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ImageViewController.longPress(_:)))
        scrollView.addGestureRecognizer(longPress)
        
        singleTap.requireGestureRecognizerToFail(doubleTap)
        singleTap.requireGestureRecognizerToFail(longPress)
        
        scrollView.scrollEnabled = true
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        scrollView.delegate = self
    }
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
    }
}
