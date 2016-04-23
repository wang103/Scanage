//
//  ServerAPIHelper.swift
//  Scanage
//
//  Created by Tianyi Wang on 1/19/16.
//  Copyright © 2016 Tianyi. All rights reserved.
//

import Foundation
import MobileCoreServices

extension NSMutableData {
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding)
        appendData(data!)
    }
}

class ServerAPIHelper {
    
    static let rootURL = "http://scan-to-reveal-app-dev.elasticbeanstalk.com/stv/"
    
    static let cookieURL = rootURL + "new_usr/"
    
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
        let toLogin = loginHelper(username, password: password, completion: completion)
        
        if toLogin == nil {
            print("error: loginHelper failed")
        }
        else {
            ensureCookie(toLogin!)
        }
    }
    
    static func logout(completion: () -> ()) {
        let toLogout = logoutHelper(completion)
        
        if toLogout == nil {
            print("error: logoutHelper failed")
        }
        else {
            ensureCookie(toLogout!)
        }
    }
    
    static func getLoginInfo(completion: NSDictionary? -> ()) {
        let toGetLoginInfo = getLoginInfoHelper(completion)
        
        if toGetLoginInfo == nil {
            print("error: getLoginInfoHelper failed")
        }
        else {
            ensureCookie(toGetLoginInfo!)
        }
    }
    
    static func submitNewMsg(textMsg: String, fileKeys: [String]?, urls: [NSURL]?, completion: NSDictionary? -> ()) {
        let toSubmitNewMsg = submitNewMsgHelper(textMsg, fileKeys: fileKeys, urls: urls, completion: completion)
        
        if toSubmitNewMsg == nil {
            print("error: submitNewMsgHelper failed")
        }
        else {
            ensureCookie(toSubmitNewMsg!)
        }
    }
    
    static func register(username: String, password1: String, password2: String, email: String,
                         firstName: String, lastName: String, completion: NSDictionary? -> ()) {
        let toRegister = registerHelper(username, password1: password1, password2: password2, email: email,
                                        firstName: firstName, lastName: lastName, completion: completion)
        
        if toRegister == nil {
            print("error: registerHelper failed")
        }
        else {
            ensureCookie(toRegister!)
        }
    }
    
    static func getUserInfo(completion: NSDictionary? -> ()) {
        let toGetUserInfo = getUserInfoHelper(completion)
        
        if toGetUserInfo == nil {
            print("error: getUserInfoHelper failed")
        }
        else {
            ensureCookie(toGetUserInfo!)
        }
    }
    
    static func getMessages(completion: NSDictionary? -> ()) {
        let toGetMessages = getMessagesHelper(completion)
        
        if toGetMessages == nil {
            print("error: getMessagesHelper failed")
        }
        else {
            ensureCookie(toGetMessages!)
        }
    }
    
    static func getMessage(qrCode: String) -> NSDictionary? {
        let urlString = rootURL + "msg/" + qrCode
        
        return getJsonInDictFromURL(urlString)
    }
    
    /*** private helper methods ***/
    
    private static func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    private static func mimeTypeForUrl(url: NSURL) -> String {
        let ext = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext! as NSString, nil)?.takeRetainedValue() {
            if let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimeType as String
            }
        }
        
        return "application/octet-stream"
    }
    
    private static func createBodyWithParameters(parameters: [String: String]?, fileKeys: [String]?,
                                                 urls: [NSURL]?, boundary: String) -> NSData {
        let body = NSMutableData()
        
        if parameters != nil {
            for (key, val) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(val)\r\n")
            }
        }
        
        if urls != nil {
            var counter = 0
            
            for url in urls! {
                let filename = url.lastPathComponent
                let data = NSData(contentsOfURL: url)!
                let mimeType = mimeTypeForUrl(url)
                
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(fileKeys![counter])\"; filename=\"\(filename!)\"\r\n")
                body.appendString("Content-Type: \(mimeType)\r\n\r\n")
                body.appendData(data)
                body.appendString("\r\n")
                
                counter += 1
            }
        }
        
        body.appendString("--\(boundary)--\r\n")
        return body
    }
    
    private static func submitNewMsgHelper(textMsg: String, fileKeys: [String]?, urls: [NSURL]?,
                                           completion: NSDictionary? -> ()) -> (String -> ())? {
        let urlString = rootURL + "submit_new_msg/"
        let url = NSURL(string: urlString)
        
        if url == nil {
            return nil
        }
        
        let boundary = generateBoundaryString()
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        return { csrfToken in
            
            let postParams = [
                "csrfmiddlewaretoken": csrfToken,
                "msg_text": textMsg
            ]
            
            request.HTTPBody = createBodyWithParameters(postParams, fileKeys: fileKeys, urls: urls, boundary: boundary)
            
            let cookiesAddr = NSURL(string: cookieURL)
            let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(cookiesAddr!)
            if cookies != nil {
                request.allHTTPHeaderFields = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies!)
            }
            else {
                print("submitNewMsgHelper: about to send POST but cookie is nil")
            }
            
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.addValue(csrfToken, forHTTPHeaderField: "X_CSRFTOKEN")
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                var result: NSDictionary? = nil
                
                if error != nil || data == nil {
                    print("submitNewMsgHelper: error is present or data is absent")
                    result = nil
                }
                else {
                    do {
                        result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    } catch {
                        print("submitNewMsgHelper: invalid JSON")
                        result = nil
                    }
                }
                
                completion(result)
            }
            
            task.resume()
        }
    }
    
    private static func loginHelper(username: String, password: String, completion: NSDictionary? -> ()) -> (String -> ())? {
        let urlString = rootURL + "login_usr/"
        let url = NSURL(string: urlString)
        
        if url == nil {
            return nil
        }
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        return { csrfToken in
            let postString = "username=" + username + "&password=" + password + "&csrfmiddlewaretoken=" + csrfToken
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            
            let cookiesAddr = NSURL(string: cookieURL)
            let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(cookiesAddr!)
            if cookies != nil {
                request.allHTTPHeaderFields = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies!)
            }
            else {
                print("loginHelper: about to send POST but cookie is nil")
            }
            
            request.addValue(csrfToken, forHTTPHeaderField: "X_CSRFTOKEN")
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                var result: NSDictionary? = nil
                
                if error != nil || data == nil {
                    print("loginHelper: error is present or data is absent")
                    result = nil
                }
                else {
                    do {
                        result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    } catch {
                        print("loginHelper: invalid JSON")
                        result = nil
                    }
                }
                
                completion(result)
            }
            
            task.resume()
        }
    }
    
    static func registerHelper(username: String, password1: String, password2: String, email: String,
                               firstName: String, lastName: String, completion: NSDictionary? -> ()) -> (String -> ())? {
        
        let urlString = rootURL + "register_new_usr/"
        let url = NSURL(string: urlString)
        
        if url == nil {
            return nil
        }
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        return { csrfToken in
            let postString = "username=" + username + "&password=" + password1 + "&password_copy=" + password2 +
                "&email=" + email + "&first_name=" + firstName + "&last_name=" + lastName + "&csrfmiddlewaretoken=" + csrfToken
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            
            let cookiesAddr = NSURL(string: cookieURL)
            let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(cookiesAddr!)
            if cookies != nil {
                request.allHTTPHeaderFields = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies!)
            }
            else {
                print("registerHelper: about to send POST but cookie is nil")
            }
            
            request.addValue(csrfToken, forHTTPHeaderField: "X_CSRFTOKEN")
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                var result: NSDictionary? = nil
                
                if error != nil || data == nil {
                    print("registerHelper: error is present or data is absent")
                    result = nil
                }
                else {
                    do {
                        result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    } catch {
                        print("registerHelper: invalid JSON")
                        result = nil
                    }
                }
                
                completion(result)
            }
            
            task.resume()
        }
    }
    
    private static func logoutHelper(completion: () -> ()) -> (String -> ())? {
        let urlString = rootURL + "logout_usr/"
        let url = NSURL(string: urlString)
        
        if url == nil {
            return nil
        }
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        return { csrfToken in
            let postString = "csrfmiddlewaretoken=" + csrfToken
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            
            let cookiesAddr = NSURL(string: cookieURL)
            let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(cookiesAddr!)
            if cookies != nil {
                request.allHTTPHeaderFields = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies!)
            }
            else {
                print("logoutHelper: about to send POST but cookie is nil")
            }
            
            request.addValue(csrfToken, forHTTPHeaderField: "X_CSRFTOKEN")
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                
                if error != nil || data == nil {
                    print("logoutHelper: error is present or data is absent")
                }
                else {
                    completion()
                }
            }
            
            task.resume()
        }
    }
    
    private static func getLoginInfoHelper(completion: NSDictionary? -> ()) -> (String -> ())? {
        let urlString = rootURL + "check_login/"
        let url = NSURL(string: urlString)
        
        if url == nil {
            return nil
        }
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        return { csrfToken in
            let postString = "csrfmiddlewaretoken=" + csrfToken
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            
            let cookiesAddr = NSURL(string: cookieURL)
            let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(cookiesAddr!)
            if cookies != nil {
                request.allHTTPHeaderFields = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies!)
            }
            else {
                print("getLoginInfoHelper: about to send POST but cookie is nil")
            }
            
            request.addValue(csrfToken, forHTTPHeaderField: "X_CSRFTOKEN")
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                var result: NSDictionary? = nil
                
                if error != nil || data == nil {
                    print("getLoginInfoHelper: error is present or data is absent")
                    result = nil
                }
                else {
                    do {
                        result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    } catch {
                        print("getLoginInfoHelper: invalid JSON")
                        result = nil
                    }
                }
                
                completion(result)
            }
            
            task.resume()
        }
    }
    
    private static func getUserInfoHelper(completion: NSDictionary? -> ()) -> (String -> ())? {
        let urlString = rootURL + "usr_info/"
        let url = NSURL(string: urlString)
        
        if url == nil {
            return nil
        }
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        return { csrfToken in
            let postString = "csrfmiddlewaretoken=" + csrfToken
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            
            let cookiesAddr = NSURL(string: cookieURL)
            let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(cookiesAddr!)
            if cookies != nil {
                request.allHTTPHeaderFields = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies!)
            }
            else {
                print("getUserInfoHelper: about to send POST but cookie is nil")
            }
            
            request.addValue(csrfToken, forHTTPHeaderField: "X_CSRFTOKEN")
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                var result: NSDictionary? = nil
                
                if error != nil || data == nil {
                    print("getUserInfoHelper: error is present or data is absent")
                    result = nil
                }
                else {
                    do {
                        result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    } catch {
                        print("getUserInfoHelper: invalid JSON")
                        result = nil
                    }
                }
                
                completion(result)
            }
            
            task.resume()
        }
    }
    
    private static func getMessagesHelper(completion: NSDictionary? -> ()) -> (String -> ())? {
        let urlString = rootURL + "usr_msgs/"
        let url = NSURL(string: urlString)
        
        if url == nil {
            return nil
        }
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        return { csrfToken in
            let postString = "csrfmiddlewaretoken=" + csrfToken
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            
            let cookiesAddr = NSURL(string: cookieURL)
            let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(cookiesAddr!)
            if cookies != nil {
                request.allHTTPHeaderFields = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies!)
            }
            else {
                print("getMessagesHelper: about to send POST but cookie is nil")
            }
            
            request.addValue(csrfToken, forHTTPHeaderField: "X_CSRFTOKEN")
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                var result: NSDictionary? = nil
                
                if error != nil || data == nil {
                    print("getMessagesHelper: error is present or data is absent")
                    result = nil
                }
                else {
                    do {
                        result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    } catch {
                        print("getMessagesHelper: invalid JSON")
                        result = nil
                    }
                }
                
                completion(result)
            }
            
            task.resume()
        }
    }
    
    private static func ensureCookie(completion: String -> ()) {
        let url = NSURL(string: cookieURL)
        if url == nil {
            return
        }
        
        let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(url!)
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPShouldHandleCookies = true
        if cookies != nil {
            request.allHTTPHeaderFields = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies!)
        }
        
        // Make a GET request to get the csrf.
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            // Update the cookie
            let headerFields = (response as! NSHTTPURLResponse).allHeaderFields as! [String : String]
            let newCookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: url!)
            NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(newCookies, forURL: url!, mainDocumentURL: nil)
            
            // Get the CSRF token.
            var csrfToken: String? = nil
            for cookie in newCookies {
                if cookie.name == "csrftoken" {
                    csrfToken = cookie.value
                    break
                }
            }
            
            if csrfToken != nil {
                completion(csrfToken!)
            }
            else {
                print("error: cookieURL did not return CSRF token")
            }
        }
        
        task.resume()
    }
    
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
