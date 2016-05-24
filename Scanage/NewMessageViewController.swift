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
    @IBOutlet var clearRecordButton: UIButton!
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
    
    private var userEmail: String? = nil
    
    
    func clearFields() {
        spinnerMsgLabel.text = ""
        
        recordingButton.enabled = true
        playingButton.enabled = false
        clearRecordButton.enabled = false
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
            self.spinnerMsgLabel.text = ""
            self.spinnerMsgLabel.hidden = true
            
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
        self.spinnerMsgLabel.text = "Submitting..."
        self.spinnerMsgLabel.hidden = false
        
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
        clearRecordButton.enabled = true
        submitButton.enabled = true
    }
    
    @IBAction func recordButtonPressed(sender: UIButton) {
        if audioRecorder!.recording == true {
            // Recording -> not recording
            recordingButton.setTitle("Start Recording", forState: .Normal)
            playingButton.enabled = true
            clearRecordButton.enabled = true
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
            clearRecordButton.enabled = false
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
            clearRecordButton.enabled = true
            submitButton.enabled = true
            
            audioPlayer!.stop()
        }
        else {
            // Not playing -> playing
            recordingButton.enabled = false
            playingButton.setTitle("Stop Playing", forState: .Normal)
            clearRecordButton.enabled = false
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
    
    @IBAction func clearRecording(sender: UIButton) {
        if audioRecorder?.recording == true {
            return
        }
        
        if audioPlayer?.playing == true {
            return
        }
        
        let controller = UIAlertController(title: "Are you sure?",
                                           message:nil, preferredStyle: .ActionSheet)
        
        let yesAction = UIAlertAction(title: "Yes, clear recording",
                                      style: .Destructive, handler: { action in
            self.recordingButton.enabled = true
            self.playingButton.enabled = false
            self.clearRecordButton.enabled = false
            
            let fileManager = NSFileManager.defaultManager()
            let documentsURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let voiceMsgFileURL = documentsURL.URLByAppendingPathComponent("voice_msg.m4a")
            
            self.removeAudioRecordFile(voiceMsgFileURL)
        })
        
        let noAction = UIAlertAction(title: "No", style: .Cancel, handler: nil)
        
        controller.addAction(yesAction)
        controller.addAction(noAction)
        
        if let ppc = controller.popoverPresentationController {
            ppc.sourceView = sender
            ppc.sourceRect = sender.bounds
        }
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    
    private func removeAudioRecordFile(voiceMsgFileURL: NSURL) {
        let fileManager = NSFileManager.defaultManager()
        
        if fileManager.fileExistsAtPath(voiceMsgFileURL.path!) {
            do {
                try fileManager.removeItemAtURL(voiceMsgFileURL)
            }
            catch {
                print("Error: removing audio file failed")
            }
        }
        
        recorded = false
        
        voiceInfoLabel.text = ""
    }
    
    
    func initAudioRecorder() -> Bool {
        let fileManager = NSFileManager.defaultManager()
        let documentsURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let voiceMsgFileURL = documentsURL.URLByAppendingPathComponent("voice_msg.m4a")
        
        removeAudioRecordFile(voiceMsgFileURL)
        
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
        qrViewController.userEmail = self.userEmail
        
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
    
    func getUserInfoCompleted(result: NSDictionary?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.spinner.stopAnimating()
            self.spinnerMsgLabel.hidden = true
            
            if result == nil {
                print("testIfLoggedIn failed")
            }
            else if result!.valueForKey("success") as! Bool == false {
                // This could only be because user is not logged in.
                self.switchToLoginView()
            }
            else {
                let userInfo = result!.valueForKey("user_info") as! NSDictionary
                self.userEmail = userInfo.valueForKey("email") as? String
            }
        }
    }
    
    func testIfLoggedIn() {
        self.spinnerMsgLabel.hidden = false
        self.spinnerMsgLabel.text = "checking login status..."
        spinner.startAnimating()
        
        // Send a POST request to get user info.
        ServerAPIHelper.getUserInfo(getUserInfoCompleted)
    }
    
    func appWillEnterForeground(notification: NSNotification) {
        Utils.updateAudioPlayerSettings()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if loginViewController != nil {
            loginViewController.view.frame = view.layer.bounds
        }
        
        if qrViewController != nil {
            qrViewController.view.frame = view.layer.bounds
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Utils.updateAudioPlayerSettings()
        
        let app = UIApplication.sharedApplication()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewMessageViewController.appWillEnterForeground(_:)), name: UIApplicationWillEnterForegroundNotification, object: app)
        
        // If not showing the login view, test if need to log in.
        if loginViewController == nil || loginViewController.view.superview == nil {
            testIfLoggedIn()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private var playingButtonState: Bool = false
    private var clearRecordButtonState: Bool = false
    
    func startSpinner() {
        spinnerMsgLabel.text = ""
        recordingButton.enabled = false
        playingButtonState = playingButton.enabled
        playingButton.enabled = false
        clearRecordButtonState = clearRecordButton.enabled
        clearRecordButton.enabled = false
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
        clearRecordButton.enabled = clearRecordButtonState
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
        // If presenting login view, don't do anything.
        if loginViewController != nil && loginViewController.view.superview != nil {
            return
        }
        
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
