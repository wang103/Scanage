//
//  ScanningViewController.swift
//  Scanage
//
//  Created by Tianyi Wang on 1/9/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import AVFoundation
import UIKit

class ScanningViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession: AVCaptureSession?   // coordinate the flow of data from input device to output device
    var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeView: UIView?
    
    
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        captureVideoPreviewLayer?.frame = view.layer.bounds
        
        if captureVideoPreviewLayer?.connection.supportsVideoOrientation == true {
            updateVideoPreviewLayerOrientation()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if (configureVideoCapture()) {
            addVideoPreviewLayer()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
