//
//  NewMessageViewController.swift
//  Scanage
//
//  Created by Tianyi Wang on 1/9/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import UIKit
import AVFoundation

class NewMessageViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var spinnerMsgLabel: UILabel!
    
    @IBOutlet var recordingButton: UIButton!
    @IBOutlet var playingButton: UIButton!
    @IBOutlet var voiceInfoLabel: UILabel!
    
    @IBOutlet var pickImageButton: UIButton!
    @IBOutlet var clearImageButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var submitButton: UIButton!
    
    private var audioPlayer: AVAudioPlayer?
    private var audioRecorder: AVAudioRecorder?
    
    private var loginViewController: LoginViewController!
    
    
    @IBAction func recordButtonPressed() {
        
    }
    
    @IBAction func playButtonPressed() {
        
    }
    
    func initAudioRecorder() -> Bool {
        let documentsURL = NSFileManager.defaultManager()
            .URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let voiceMsgFileURL = documentsURL.URLByAppendingPathComponent("voice_msg.caf")
        
        let recordSettings = [
            AVEncoderAudioQualityKey: AVAudioQuality.Medium.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 2,
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
            let alert = UIAlertController(title: "Device Error", message: "Please enable recording for this app in Settings.",
                                          preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            return false
        }
        
        return true
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // If not showing the login view, test if need to log in.
        if loginViewController == nil || loginViewController.view.superview == nil {
            testIfLoggedIn()
        }
    }
    
    func initSpinner() {
        self.spinner.stopAnimating()
        self.spinnerMsgLabel.hidden = true
        
        self.view.bringSubviewToFront(spinner)
        self.view.bringSubviewToFront(spinnerMsgLabel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initSpinner()
        if initAudioRecorder() == false {
            recordingButton.enabled = false
        }
        
        loginViewController = storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
        loginViewController.view.frame = view.layer.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if loginViewController != nil && loginViewController.view.superview == nil {
            loginViewController = nil
        }
    }
}
