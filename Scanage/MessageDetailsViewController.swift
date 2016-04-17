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
    @IBOutlet var playButton: UIButton!
    @IBOutlet var playInfoLabel: UILabel!
    @IBOutlet var playProgress: UIProgressView!
    @IBOutlet var voiceMsgErrorLabel: UILabel!
    
    var imageData: NSData? = nil
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageMsgErrorLabel: UILabel!
    
    @IBOutlet var textMsgField: UITextView!
    @IBOutlet var textMsgErrorLabel: UILabel!
    
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setTitle("Play", forState: .Normal)
    }
    
    @IBAction func playButtonPressed(sender: UIButton) {
        if audioPlayer?.playing == true {
            // Playing -> not playing
            playButton.setTitle("Play", forState: .Normal)
            audioPlayer!.stop()
        }
        else {
            // Not playing -> playing
            playButton.setTitle("Stop", forState: .Normal)
            
            audioPlayer!.play()
        }
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
                playInfoLabel.text = ""
                voiceMsgErrorLabel.text = ""
            }
            catch {
                print("Error: can't play audio")
            }
        }
        else {
            playButton.enabled = false
            playInfoLabel.text = "N/A"
            voiceMsgErrorLabel.text = "empty"
        }
        
        if imageData != nil {
            imageView.image = UIImage(data: imageData!)
            imageMsgErrorLabel.text = ""
        }
        else {
            imageView.image = nil
            imageMsgErrorLabel.text = "empty"
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
    
    @IBAction func removeFromParent(sender: UIBarButtonItem) {
        audioPlayer?.stop()
        
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
        scanningVCDelegate!.startCaptureSession()
    }
}
