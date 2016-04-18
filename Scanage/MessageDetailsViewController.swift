//
//  MessageDetailsViewController.swift
//  Scanage
//
//  Created by Tianyi Wang on 1/12/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class MessageDetailsViewController: UIViewController, AVAudioPlayerDelegate {
    
    var scanningVCDelegate: ScanningViewControllerDelegate! = nil
    
    var fieldsData: NSDictionary! = nil
    
    @IBOutlet var creatorField: UILabel!
    @IBOutlet var dateField: UILabel!
    
    private var audioPlayer: AVAudioPlayer? = nil
    var audioData: NSData? = nil
    private var updater: CADisplayLink? = nil
    var totalDurationStr = ""
    @IBOutlet var playButton: UIButton!
    @IBOutlet var playInfoLabel: UILabel!
    @IBOutlet var playProgress: UIProgressView!
    @IBOutlet var voiceMsgErrorLabel: UILabel!
    
    var imageData: NSData? = nil
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageMsgErrorLabel: UILabel!
    
    @IBOutlet var textMsgField: UITextView!
    @IBOutlet var textMsgErrorLabel: UILabel!
    
    private var imageViewController: ImageViewController!
    
    
    func switchToImageView() {
        if imageViewController == nil {
            imageViewController = storyboard?.instantiateViewControllerWithIdentifier("ImageVC") as! ImageViewController
            imageViewController.view.frame = view.layer.bounds
        }
        
        imageViewController.imageData = self.imageData
        
        self.addChildViewController(imageViewController!)
        self.view.addSubview(imageViewController!.view)
        self.view.bringSubviewToFront(imageViewController!.view)
        imageViewController!.didMoveToParentViewController(self)
    }
    
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        updater!.invalidate()
        playButton.setTitle("Play", forState: .Normal)
    }
    
    @IBAction func playButtonPressed(sender: UIButton) {
        if audioPlayer != nil && audioPlayer!.playing == true {
            // Playing -> not playing
            audioPlayer!.stop()
            audioPlayer!.currentTime = 0
            playInfoLabel.text = getAudioTrackLabel(0)
            updater!.invalidate()
            playButton.setTitle("Play", forState: .Normal)
        }
        else if audioPlayer != nil {
            // Not playing -> playing
            updater = CADisplayLink(target: self, selector: #selector(MessageDetailsViewController.trackAudio))
            updater!.frameInterval = 1
            updater!.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
            
            playButton.setTitle("Stop", forState: .Normal)
            
            audioPlayer!.play()
        }
    }
    
    private func convertSecondsToString(secs: Int) -> String {
        var hours = 0
        var minutes = 0
        var seconds = secs
        
        if seconds >= 3600 {
            hours = seconds / 3600
            seconds -= 3600 * hours
        }
        
        if seconds >= 60 {
            minutes = seconds / 60
            seconds -= 60 * minutes
        }
        
        return "\(hours):\(minutes):\(seconds)"
    }
    
    private func getAudioTrackLabel(curTime: Int) -> String {
        let curStr = convertSecondsToString(curTime)
        
        return "\(curStr) / \(totalDurationStr)"
    }
    
    func trackAudio() {
        let percentage = Float(audioPlayer!.currentTime) / Float(audioPlayer!.duration)
        self.playProgress.setProgress(percentage, animated: false)
        playInfoLabel.text = getAudioTrackLabel(Int(audioPlayer!.currentTime))
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let fieldsDataDict = fieldsData.valueForKey("msg_detail") as! NSDictionary
        
        self.creatorField.text = fieldsDataDict.valueForKey("creator") as? String
        self.dateField.text = fieldsDataDict.valueForKey("create_date") as? String
        
        if audioData != nil {
            do {
                self.audioPlayer = try AVAudioPlayer(data: audioData!)
                self.audioPlayer!.prepareToPlay()
                self.audioPlayer!.delegate = self
                
                playButton.enabled = true
                totalDurationStr = convertSecondsToString(Int(audioPlayer!.duration))
                playInfoLabel.text = getAudioTrackLabel(0)
                playProgress.setProgress(0, animated: false)
                voiceMsgErrorLabel.text = ""
            }
            catch {
                print("Error: can't play audio")
            }
        }
        else {
            playButton.enabled = false
            playInfoLabel.text = "N/A"
            playProgress.setProgress(0, animated: false)
            voiceMsgErrorLabel.text = "empty"
            
            self.audioPlayer = nil
            self.updater = nil
        }
        
        if imageData != nil {
            imageView.image = UIImage(data: imageData!)
            imageMsgErrorLabel.text = ""
            
            // Enable click to enlarge.
            imageView.userInteractionEnabled = true
        }
        else {
            imageView.image = nil
            imageMsgErrorLabel.text = "empty"
            imageView.userInteractionEnabled = false
        }
        
        let textMsg = fieldsDataDict.valueForKey("msg_text") as? String
        if textMsg == nil || textMsg!.isEmpty {
            self.textMsgField.text = ""
            self.textMsgErrorLabel.text = "empty"
        }
        else {
            self.textMsgField.text = textMsg!
            self.textMsgErrorLabel.text = ""
        }
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        switchToImageView()
    }
    
    @IBAction func removeFromParent(sender: UIBarButtonItem) {
        if audioPlayer != nil {
            audioPlayer!.stop()
        }
        if updater != nil {
            updater!.invalidate()
        }
        
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
        scanningVCDelegate!.startCaptureSession()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if imageViewController != nil {
            imageViewController.view.frame = view.layer.bounds
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.overrideOutputAudioPort(.Speaker)
        }
        catch {
            print("Error: unable to play audio via speaker")
        }
        
        imageViewController = storyboard?.instantiateViewControllerWithIdentifier("ImageVC") as! ImageViewController
        imageViewController.view.frame = view.layer.bounds
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MessageDetailsViewController.tap(_:)))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        imageView.userInteractionEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if imageViewController != nil && imageViewController.view.superview == nil {
            imageViewController = nil
        }
    }
}
