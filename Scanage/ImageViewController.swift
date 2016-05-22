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
        
        singleTap.requireGestureRecognizerToFail(doubleTap)
        
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
