//
//  Utils.swift
//  Scanage
//
//  Created by Tianyi Wang on 4/23/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import Foundation

class Utils {
    
    static func convertUTCToLocal(utcStr: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let date = dateFormatter.dateFromString(utcStr)
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        
        return dateFormatter.stringFromDate(date!)
    }
    
}
