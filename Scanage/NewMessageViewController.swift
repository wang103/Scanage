//
//  NewMessageViewController.swift
//  Scanage
//
//  Created by Tianyi Wang on 1/9/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import UIKit
import AVFoundation

protocol NewMessageViewControllerDelegate {
    func clearFields()
}

class NewMessageViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate,
    UIImagePickerControllerDelegate, UINavigationControllerDelegate, NewMessageViewControllerDelegate {

    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var spinnerMsgLabel: UILabel!
    
    @IBOutlet var recordingButton: UIButton!
    @IBOutlet var playingButton: UIButton!
    @IBOutlet var voiceInfoLabel: UILabel!
    private var recorded: Bool = false
    
    @IBOutlet var pickImageButton: UIButton!
    @IBOutlet var clearImageButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var submitButton: UIButton!
    
    private var audioPlayer: AVAudioPlayer?
    private var audioRecorder: AVAudioRecorder?
    
    private let imagePicker = UIImagePickerController()
    
    private var loginViewController: LoginViewController!
    private var qrViewController: QRViewController!
    
    
    func clearFields() {
        spinnerMsgLabel.text = ""
        
        recordingButton.enabled = true
        playingButton.enabled = false
        voiceInfoLabel.text = ""
        recorded = false
        
        pickImageButton.enabled = true
        clearImageButton.enabled = false
        imageView.image = nil
        
        textView.text = ""
        submitButton.enabled = true
    }
    
    
    func submitMsgCompleted(result: NSDictionary?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.stopSpinner()
            
            if result == nil {
                print("submit new message failed")
            }
            else if result!.valueForKey("success") as! Bool == false {
                let ec = result!.valueForKey("ec") as! Int
                
                var msg = ""
                
                if ec == ServerAPIHelper.EC_NOT_LOGGED_IN {
                    msg = "Please log in before submitting a new message"
                    self.switchToLoginView()
                }
                else if ec == ServerAPIHelper.EC_EMPTY_MESSAGE {
                    msg = "Message cannot be empty"
                }
                else {
                    msg = "Server error"
                }
                
                let alertController = UIAlertController(title: "Error", message: msg, preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
                return
            }
            else {
                // Message submitted successfully.
                
                let msg_detail = result!.valueForKey("msg_detail") as! NSDictionary
                let qrString = msg_detail.valueForKey("qr_str") as! String
                
                self.switchToQRView(qrString)
            }
        }
    }
    
    @IBAction func submitMessage(sender: UIButton) {
        var fileKeys: [String] = []
        var urls: [NSURL] = []
        
        let voiceMsgUrl = audioRecorder?.url
        if recorded && voiceMsgUrl != nil {
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(voiceMsgUrl!.path!) {
                fileKeys.append("audio_file")
                urls.append(voiceMsgUrl!)
            }
        }
        
        if imageView.image != nil {
            let fileManager = NSFileManager.defaultManager()
            let documentsURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let imgMsgFileURL = documentsURL.URLByAppendingPathComponent("image_msg.jpg")
            UIImageJPEGRepresentation(imageView.image!, 1.0)?.writeToURL(imgMsgFileURL, atomically: true)
            
            fileKeys.append("image_file")
            urls.append(imgMsgFileURL)
        }
        
        let textMsg = self.textView.text
        
        self.startSpinner()
        
        // Send a POST to request to submit new message.
        ServerAPIHelper.submitNewMsg(textMsg, fileKeys: fileKeys, urls: urls, completion: submitMsgCompleted)
    }
    
    
    @IBAction func pickImage(sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func clearImage(sender: UIButton) {
        clearImageButton.enabled = false
        imageView.image = nil
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage
            clearImageButton.enabled = true
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    private func showRecorderError() {
        let alert = UIAlertController(title: "Device Error", message: "Please enable recording for this app in Settings.",
                                      preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        recordingButton.enabled = true
        playingButton.setTitle("Start Playing", forState: .Normal)
        submitButton.enabled = true
    }
    
    @IBAction func recordButtonPressed(sender: UIButton) {
        if audioRecorder!.recording == true {
            // Recording -> not recording
            recordingButton.setTitle("Start Recording", forState: .Normal)
            playingButton.enabled = true
            submitButton.enabled = true
            
            audioRecorder!.stop()
            
            // Show recorded audio info.
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: audioRecorder!.url)
                let attributes = try NSFileManager.defaultManager().attributesOfItemAtPath(audioRecorder!.url.path!)
                let fileSize = Float((attributes[NSFileSize] as! NSNumber).longLongValue) / 1048576.0
                let fileSizeStr = String(format: "%.2f", fileSize)
                voiceInfoLabel.text = "Length: \(Int(audioPlayer!.duration)) seconds. Size: \(fileSizeStr) MB."
                
                recorded = true
            }
            catch {
                print("Error: something is wrong with audio player")
            }
        }
        else {
            // Not recording -> recording
            recordingButton.setTitle("Stop Recording", forState: .Normal)
            playingButton.setTitle("Start Playing", forState: .Normal)
            playingButton.enabled = false
            voiceInfoLabel.text = "Recording..."
            submitButton.enabled = false
            
            if audioRecorder!.record() == false {
                showRecorderError()
            }
        }
    }
    
    @IBAction func playButtonPressed(sender: UIButton) {
        if audioRecorder?.recording == true {
            return
        }
        
        if audioPlayer?.playing == true {
            // Playing -> not playing
            recordingButton.enabled = true
            playingButton.setTitle("Start Playing", forState: .Normal)
            submitButton.enabled = true
            
            audioPlayer!.stop()
        }
        else {
            // Not playing -> playing
            recordingButton.enabled = false
            playingButton.setTitle("Stop Playing", forState: .Normal)
            submitButton.enabled = false
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: audioRecorder!.url)
                audioPlayer!.delegate = self
                audioPlayer!.play()
            }
            catch {
                print("Error: something is wrong with audio player")
            }
        }
    }
    
    func initAudioRecorder() -> Bool {
        let fileManager = NSFileManager.defaultManager()
        
        let documentsURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let voiceMsgFileURL = documentsURL.URLByAppendingPathComponent("voice_msg.m4a")
        
        if fileManager.fileExistsAtPath(voiceMsgFileURL.path!) {
            do {
                try fileManager.removeItemAtURL(voiceMsgFileURL)
            }
            catch {
                print("Error: removing audio file failed")
            }
        }
        
        recorded = false
        
        let recordSettings = [
            AVEncoderAudioQualityKey: AVAudioQuality.Medium.rawValue,
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVEncoderBitRateKey: 128000,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey: 44100.0
        ]
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.overrideOutputAudioPort(.Speaker)
            self.audioRecorder = try AVAudioRecorder(URL: voiceMsgFileURL, settings: recordSettings as! [String : AnyObject])
            if self.audioRecorder!.prepareToRecord() == false {
                struct Error: ErrorType {
                    var msg = "Unable to prepare audio recorder"
                }
                throw Error()
            }
        }
        catch {
            // Show error message
            showRecorderError()
            
            return false
        }
        
        return true
    }
    
    
    func switchToQRView(qrString: String) {
        if qrViewController == nil {
            qrViewController = storyboard?.instantiateViewControllerWithIdentifier("QRVC") as! QRViewController
            qrViewController.view.frame = view.layer.bounds
            qrViewController.newMsgVCDelegate = self
        }
        
        qrViewController.qrString = qrString
        
        self.addChildViewController(qrViewController!)
        self.view.addSubview(qrViewController!.view)
        self.view.bringSubviewToFront(qrViewController!.view)
        qrViewController!.didMoveToParentViewController(self)
    }
    
    func switchToLoginView() {
        if loginViewController == nil {
            loginViewController = storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
            loginViewController.view.frame = view.layer.bounds
        }
        
        self.addChildViewController(loginViewController!)
        self.view.addSubview(loginViewController!.view)
        self.view.bringSubviewToFront(loginViewController!.view)
        loginViewController!.didMoveToParentViewController(self)
    }
    
    func getLoginInfoCompleted(result: NSDictionary?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.spinner.stopAnimating()
            self.spinnerMsgLabel.hidden = true
            
            if result == nil || result!.valueForKey("success") as! Bool == false {
                print("testIfLoggedIn failed")
            }
            else {
                let fLoggedIn = result!.valueForKey("is_logged_in") as! Bool
                if !fLoggedIn {
                    self.switchToLoginView()
                }
            }
        }
    }
    
    func testIfLoggedIn() {
        self.spinnerMsgLabel.hidden = false
        self.spinnerMsgLabel.text = "checking login status..."
        spinner.startAnimating()
        
        // Send a POST request to get login info.
        ServerAPIHelper.getLoginInfo(getLoginInfoCompleted)
    }
    
    override func viewWillLayoutSubviews() {
        if loginViewController != nil {
            loginViewController.view.frame = view.layer.bounds
        }
        
        if qrViewController != nil {
            qrViewController.view.frame = view.layer.bounds
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // If not showing the login view, test if need to log in.
        if loginViewController == nil || loginViewController.view.superview == nil {
            testIfLoggedIn()
        }
    }
    
    private var playingButtonState: Bool = false
    
    func startSpinner() {
        spinnerMsgLabel.text = ""
        recordingButton.enabled = false
        playingButtonState = playingButton.enabled
        playingButton.enabled = false
        pickImageButton.enabled = false
        clearImageButton.enabled = false
        textView.editable = false
        submitButton.enabled = false
        
        spinner.startAnimating()
    }
    
    func stopSpinner() {
        self.spinner.stopAnimating()
        
        recordingButton.enabled = true
        playingButton.enabled = playingButtonState
        pickImageButton.enabled = true
        clearImageButton.enabled = imageView.image != nil
        textView.editable = true
        submitButton.enabled = true
    }
    
    func initSpinner() {
        self.spinner.stopAnimating()
        self.spinnerMsgLabel.hidden = true
        
        self.view.bringSubviewToFront(spinner)
        self.view.bringSubviewToFront(spinnerMsgLabel)
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        textView.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initSpinner()
        if initAudioRecorder() == false {
            recordingButton.enabled = false
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NewMessageViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        imagePicker.delegate = self
        
        loginViewController = storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
        loginViewController.view.frame = view.layer.bounds
        
        qrViewController = storyboard?.instantiateViewControllerWithIdentifier("QRVC") as! QRViewController
        qrViewController.view.frame = view.layer.bounds
        qrViewController.newMsgVCDelegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewMessageViewController.keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewMessageViewController.keyboardWillHide(_:)),
                                                         name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            var target = -keyboardSize.height
            if let offset = self.tabBarController?.tabBar.frame.size.height {
                target += offset
            }
            
            if self.view.frame.origin.y != target {
                self.view.frame.origin.y = target
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if loginViewController != nil && loginViewController.view.superview == nil {
            loginViewController = nil
        }
        if qrViewController != nil && qrViewController.view.superview == nil {
            qrViewController = nil
        }
    }
}
