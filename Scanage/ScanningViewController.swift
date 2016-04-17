//
//  ScanningViewController.swift
//  Scanage
//
//  Created by Tianyi Wang on 1/9/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import AVFoundation
import UIKit

protocol ScanningViewControllerDelegate {
    func startCaptureSession()
}

class ScanningViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, ScanningViewControllerDelegate {

    @IBOutlet var spinner: UIActivityIndicatorView!
    
    private var captureSession: AVCaptureSession?   // coordinate the flow of data from input device to output device
    private var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var qrCodeView: UIView?
    
    private var msgDetailsViewController: MessageDetailsViewController!
    
    
    func switchToMsgDetailsView(result: NSDictionary) {
        if msgDetailsViewController == nil {
            msgDetailsViewController = storyboard?.instantiateViewControllerWithIdentifier("MsgDetailsVC") as! MessageDetailsViewController
            msgDetailsViewController.view.frame = view.layer.bounds
            msgDetailsViewController.scanningVCDelegate = self
        }
        
        msgDetailsViewController.fieldsData = result
        
        self.addChildViewController(msgDetailsViewController!)
        self.view.addSubview(msgDetailsViewController!.view)
        self.view.bringSubviewToFront(msgDetailsViewController!.view)
        msgDetailsViewController!.didMoveToParentViewController(self)
    }
    
    func startCaptureSession() {
        if captureSession?.running == false {
            captureSession?.startRunning()
        }
        qrCodeView?.frame = CGRectZero
    }
    
    func qrCodeCaptured(qrString: String) {
        spinner.startAnimating()
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 /*flags*/)
        dispatch_async(queue) {
            // Send a GET request to retrieve the msg associated with the QR string.
            let result = ServerAPIHelper.getMessage(qrString)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.spinner.stopAnimating()
                
                if result == nil || result!.valueForKey("success") as! Bool == false {
                    // QR code is not a Scanage QR.
                    
                    let alert = UIAlertController(title: "Invalid QR code", message: "This is not a QR code created by this app.",
                                                  preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel,
                                                  handler: {(alert: UIAlertAction!) in self.startCaptureSession()}))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else {
                    self.switchToMsgDetailsView(result!)
                }
            }
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!,
        didOutputMetadataObjects metadataObjects: [AnyObject]!,
        fromConnection connection: AVCaptureConnection!) {
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeView?.frame = CGRectZero
            return
        }
        
        let avMetadataCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if avMetadataCodeObject.type == AVMetadataObjectTypeQRCode {
            // Convert AVMetadataObject's visual properties to the receiver (the layer)'s coordinates.
            let qrCodeObj = captureVideoPreviewLayer?.transformedMetadataObjectForMetadataObject(avMetadataCodeObject) as! AVMetadataMachineReadableCodeObject
            
            qrCodeView?.frame = qrCodeObj.bounds
            
            if avMetadataCodeObject.stringValue != nil {
                // Success!

                captureSession?.stopRunning()
                
                qrCodeCaptured(avMetadataCodeObject.stringValue)
                
                return
            }
        }
        
        qrCodeView?.frame = CGRectZero
    }
    
    func configureVideoCapture() -> Bool {
        
        let captureDevice: AVCaptureDevice! = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        let captureDeviceInput: AVCaptureDeviceInput
        do {
            captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
        }
        catch {
            // Show error message
            let alert = UIAlertController(title: "Device Error", message: "Please enable camera for this app in Settings.",
                preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            return false
        }
        
        captureSession = AVCaptureSession()
        captureSession?.addInput(captureDeviceInput as AVCaptureInput)
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        return true
    }
    
    func addVideoPreviewLayer() {
        captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        captureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        captureVideoPreviewLayer?.frame = view.layer.bounds
        
        self.view.layer.addSublayer(captureVideoPreviewLayer!)
        
        captureSession?.startRunning()
    }
    
    func updateVideoPreviewLayerOrientation() {
        let deviceOrientation = UIDevice.currentDevice().orientation
        
        switch deviceOrientation {
        case .LandscapeLeft:
            captureVideoPreviewLayer?.connection.videoOrientation = .LandscapeRight
        case .LandscapeRight:
            captureVideoPreviewLayer?.connection.videoOrientation = .LandscapeLeft
        default:
            captureVideoPreviewLayer?.connection.videoOrientation = .Portrait
        }
    }
    
    func initQRView() {
        qrCodeView = UIView()
        qrCodeView?.frame = CGRectZero
        qrCodeView?.layer.borderColor = UIColor.redColor().CGColor
        qrCodeView?.layer.borderWidth = 5
        
        self.view.addSubview(qrCodeView!)
        self.view.bringSubviewToFront(qrCodeView!)
    }
    
    func initSpinner() {
        self.view.bringSubviewToFront(spinner)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        captureVideoPreviewLayer?.frame = view.layer.bounds
        if captureVideoPreviewLayer?.connection.supportsVideoOrientation == true {
            updateVideoPreviewLayerOrientation()
        }
        
        if msgDetailsViewController != nil {
            msgDetailsViewController.view.frame = view.layer.bounds
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if (configureVideoCapture()) {
            addVideoPreviewLayer()
            initQRView()
            initSpinner()
        }
        
        msgDetailsViewController = storyboard?.instantiateViewControllerWithIdentifier("MsgDetailsVC") as! MessageDetailsViewController
        msgDetailsViewController.view.frame = view.layer.bounds
        msgDetailsViewController.scanningVCDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        if msgDetailsViewController != nil && msgDetailsViewController.view.superview == nil {
            msgDetailsViewController = nil
        }
    }
}
