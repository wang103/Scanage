//
//  Utils.swift
//  Scanage
//
//  Created by Tianyi Wang on 4/23/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import Foundation
import AVFoundation

class Utils {
    
    static let settingsPrivateModeKey = "PRIVATE_MODE"
    
    
    static func convertUTCToLocal(utcStr: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let date = dateFormatter.dateFromString(utcStr)
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        
        return dateFormatter.stringFromDate(date!)
    }
    
    static func updateAudioPlayerSettings() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.synchronize()
        let fPrivateMode = defaults.boolForKey(Utils.settingsPrivateModeKey)
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.overrideOutputAudioPort(fPrivateMode ? .None : .Speaker)
        }
        catch {
            print("Error: unable to override output audio port. Private mode: \(fPrivateMode)")
        }
    }
    
}
