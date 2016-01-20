//
//  ServerAPIHelper.swift
//  Scanage
//
//  Created by Tianyi Wang on 1/19/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import Foundation

class ServerAPIHelper {
    
    static let rootURL = "http://scan-to-reveal-app-dev.elasticbeanstalk.com/stv/"
    
    static func getMessage(qrCode: String) -> NSDictionary? {
        let urlString = rootURL + "msg/" + qrCode
        let url = NSURL(string: urlString)
        
        if url == nil {
            return nil
        }
        
        let jsonData = NSData(contentsOfURL: url!)
        
        if jsonData == nil {
            return nil
        }
        
        var result: NSDictionary? = nil
        
        do {
            result = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
        } catch {
            return nil
        }
        
        return result
    }
}
