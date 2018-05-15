//
//  UdacityClient.swift
//  on-the-map
//
//  Created by Pedro De Morais Chiossi on 09/05/18.
//  Copyright © 2018 Pedro Chiossi. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    var session = URLSession.shared
    var password: String?
    var userEmail: String?
    var facebookToken: String?
    var sessionID: String?
    var userID: String?
    var firstName: String?
    var lastName: String?
    var loggedFromFacebook: Bool!
    
    
    override init() {
        super.init()
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
    
    
    func taskForGETMethod(_ method: String, completionHandlerForGET: @escaping (_ successs: Bool,_ error: NSError?, _ result: AnyObject?) -> Void)  {
        
        let request = NSMutableURLRequest(url: self.udacityURL(pathExtension: method))
        request.httpMethod = Udacity.Methods.Get
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(false, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo),nil)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.parseData(data, completionHandlerForParsedData: completionHandlerForGET)
        }
        
        /* 7. Start the request */
        task.resume()
        
    }
    
    
    func taskForDELETEMethod(_ method: String, completionHandlerForDELETE: @escaping (_ success: Bool, _ error: NSError?,_ result: AnyObject?) -> Void) {
        
        let request = NSMutableURLRequest(url: self.udacityURL(pathExtension: method))
        request.httpMethod = Udacity.Methods.Delete
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies!{
            if cookie.name == Udacity.XSRF.CookieName{
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: Udacity.XSRF.HTTPHeader)
        }
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForDELETE(false, NSError(domain: "taskForDELETEMethod", code: 1, userInfo: userInfo),nil)
            }
            
            /* GUARD: Was there an error? */
            guard
                (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            
            
            /* GUARD: Did we get a successful 2XX response? */
            guard
                let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard
                let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.parseData(data, completionHandlerForParsedData: completionHandlerForDELETE)
        }
        
        /* 7. Start the request */
        task.resume()
        
    }

    
    func taskForPOSTMethod(_ method: String, completionHandlerForPOST: @escaping (_ success: Bool, _ error: NSError?, _ result: AnyObject?) -> Void) {
        
        let request = self.udacityPOSTRequest(method: method)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(false, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo), nil)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            // Check for invalid email and password
            if let statusCode = (response as? HTTPURLResponse)?.statusCode{
                if statusCode == 403{
                    sendError("Invalid Email or Password")
                    return
                }
                else if statusCode == 400{
                    sendError("Post request failed")
                }
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 400, 403 or 2xx!")
                return
            }
            
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.parseData(data, completionHandlerForParsedData: completionHandlerForPOST)
        }
        
        /* 7. Start the request */
        task.resume()
        
    }
    	
    
    func parseData(_ data: Data, completionHandlerForParsedData: (_ success: Bool, _ error: NSError?,_ result: AnyObject?) -> Void) {
        
        let newData = self.correctData(data)
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(newData)'"]
            completionHandlerForParsedData(false, NSError(domain: "parseData", code: 1, userInfo: userInfo), nil)
            return
        }
        
        // Use parsed data
        completionHandlerForParsedData(true,nil,parsedResult)
    }
    
    
    
    // MARK: Create POST Request
    
    private func udacityPOSTRequest(method: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: self.udacityURL(pathExtension: method))
        request.httpMethod = Udacity.Methods.Post
        request.addValue(Udacity.HTTPHeader.ApplicationJSON, forHTTPHeaderField: Udacity.HTTPHeader.AcceptKey)
        request.addValue(Udacity.HTTPHeader.ApplicationJSON, forHTTPHeaderField: Udacity.HTTPHeader.ContentTypeKey)
        if self.loggedFromFacebook{
            request.httpBody = "{\"\(Udacity.JSONBodyKeys.FacebookLogin)\": {\"\(Udacity.JSONBodyKeys.AccessToken)\": \"\(self.facebookToken!);\"}}".data(using: String.Encoding.utf8)
        }
        else{
            request.httpBody = "{\"\(Udacity.JSONBodyKeys.UdacityLogin)\": {\"\(Udacity.JSONBodyKeys.Username)\": \"\(self.userEmail!)\", \"\(Udacity.JSONBodyKeys.Password)\": \"\(self.password!)\"}}".data(using: String.Encoding.utf8)
        }
        
        return request
        
    }
    
    
   
    
}
