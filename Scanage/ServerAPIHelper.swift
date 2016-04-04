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
    
    
    static func login(username: String, password: String, completion: NSDictionary? -> ()) {
        let urlString = rootURL + "login_usr/"
        let url = NSURL(string: urlString)
        
        if url == nil {
            return
        }
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        let postString = "username=" + username + "&password=" + password
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            var result: NSDictionary? = nil
            
            if error != nil || data == nil {
                print("login: error is present or data is absent")
                result = nil
            }
            else {
                do {
                    result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                } catch {
                    print("login: invalid JSON")
                    result = nil
                }
            }
            
            completion(result)
        }
        
        task.resume()
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
