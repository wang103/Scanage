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

class ScanningViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate,
    UIImagePickerControllerDelegate, UINavigationControllerDelegate, ScanningViewControllerDelegate {

    @IBOutlet var cameraView: UIView!
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var spinnerMsgLabel: UILabel!
    
    private var captureSession: AVCaptureSession?   // coordinate the flow of data from input device to output device
    private var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var qrCodeView: UIView?
    
    private let imagePicker = UIImagePickerController()
    private let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
    
    private var msgDetailsViewController: MessageDetailsViewController!
    
    
    @IBAction func insertQRFromPhotos(sender: UIBarButtonItem) {
        captureSession?.stopRunning()
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        dismissViewControllerAnimated(true, completion: {
        
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                let ciImage = CIImage(CGImage: pickedImage.CGImage!)
            
                let features = self.qrDetector.featuresInImage(ciImage) as! [CIQRCodeFeature]
            
                if features.count == 0 {
                    let alert = UIAlertController(title: "Invalid Image", message: "Image does not contain QR code.",
                        preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel,
                        handler: {(alert: UIAlertAction!) in self.startCaptureSession()}))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else {
                    let qrCodeStr = features[0].messageString
                    self.qrCodeCaptured(qrCodeStr)
                }
            }
            else {
                print("Error: picked image is not an UIImage.")
                self.startCaptureSession()
            }
        
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        self.startCaptureSession()
    }
    
    func switchToMsgDetailsView(result: NSDictionary) {
        if msgDetailsViewController == nil {
            msgDetailsViewController = storyboard?.instantiateViewControllerWithIdentifier("MsgDetailsVC") as! MessageDetailsViewController
            msgDetailsViewController.view.frame = view.layer.bounds
            msgDetailsViewController.scanningVCDelegate = self
        }
        
        msgDetailsViewController.fieldsData = result
        
        // Get the NSData for audio and image now.
        msgDetailsViewController.audioData = nil
        let fieldsDataDict = result.valueForKey("msg_detail") as! NSDictionary
        
        if let audioURLStr = fieldsDataDict["audio_file"] {
            spinnerMsgLabel.text = "Downloading audio file"
            
            if let url = NSURL(string: audioURLStr as! String) {
                if let data = NSData(contentsOfURL: url) {
                    msgDetailsViewController.audioData = data
                }
            }
        }
        
        msgDetailsViewController.imageData = nil
        if let imageURLStr = fieldsDataDict["image_file"] {
            spinnerMsgLabel.text = "Downloading image file"
            
            if let url = NSURL(string: imageURLStr as! String) {
                if let data = NSData(contentsOfURL: url) {
                    msgDetailsViewController.imageData = data
                }
            }
        }
        
        spinnerMsgLabel.text = ""
        
        self.spinner.stopAnimating()
        
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
        spinnerMsgLabel.text = "Looking up..."
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 /*flags*/)
        dispatch_async(queue) {
            // Send a GET request to retrieve the msg associated with the QR string.
            let result = ServerAPIHelper.getMessage(qrString)
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if result == nil || result!.valueForKey("success") as! Bool == false {
                    // QR code is not a Scanage QR.
                    self.spinnerMsgLabel.text = ""
                    self.spinner.stopAnimating()
                    
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
        captureVideoPreviewLayer?.frame = cameraView.layer.bounds
        
        self.cameraView.layer.addSublayer(captureVideoPreviewLayer!)
        
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
        
        self.cameraView.addSubview(qrCodeView!)
        self.cameraView.bringSubviewToFront(qrCodeView!)
    }
    
    func initSpinner() {
        self.cameraView.bringSubviewToFront(spinner)
        self.cameraView.bringSubviewToFront(spinnerMsgLabel)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        captureVideoPreviewLayer?.frame = cameraView.layer.bounds
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
        
        imagePicker.delegate = self
        
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
