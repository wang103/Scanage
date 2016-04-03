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
    
    static let EC_INVALID_USERNAME   = 1
    static let EC_USERNAME_EXISTS    = 2
    static let EC_INVALID_PASSWORD   = 3
    static let EC_PASSWORDS_MISMATCH = 4
    static let EC_INVALID_EMAIL      = 5
    static let EC_INVALID_CREDS      = 6
    static let EC_ACCOUNT_DISABLED   = 7
    static let EC_NOT_LOGGED_IN      = 8
    static let EC_EMPTY_MESSAGE      = 9
    
    
    static func login(username: String, password: String) -> NSDictionary? {
        return nil
    }
    
    static func getLoginInfo() -> NSDictionary? {
        let urlString = rootURL + "check_login/"
        
        return getJsonInDictFromURL(urlString)
    }
    
    static func getMessage(qrCode: String) -> NSDictionary? {
        let urlString = rootURL + "msg/" + qrCode
        
        return getJsonInDictFromURL(urlString)
    }
    
    /*** private helper methods ***/
    
    private static func getJsonInDictFromURL(urlString: String) -> NSDictionary? {
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
