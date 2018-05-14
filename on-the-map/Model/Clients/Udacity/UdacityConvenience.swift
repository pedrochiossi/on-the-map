//
//  UdacityConvenience.swift
//  on-the-map
//
//  Created by Pedro De Morais Chiossi on 10/05/18.
//  Copyright © 2018 Pedro Chiossi. All rights reserved.
//

import Foundation
import FBSDKLoginKit
extension UdacityClient {
    
    //  creates udacity API URL
    func udacityURL(pathExtension: String?) -> URL {
        var components = URLComponents()
        components.scheme = Udacity.Constants.APIScheme
        components.host = Udacity.Constants.APIHost
        components.path = Udacity.Constants.APIPath + (pathExtension ?? "")
        return components.url!
    }
    
    // Correction for Udacity's JSON returned data
    func correctData(_ data: Data) -> Data {
        let range = Range(uncheckedBounds: (5, data.count))
        let newdata = data.subdata(in: range)
        return newdata
    }

    
    func getUserData(_ completionHandlerForUserData: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        guard let userID = self.userID else {
        completionHandlerForUserData(false, NSError(domain: "getUserData", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to make request, userID not established"]))
        return
        }
        
        taskForGETMethod((Udacity.Methods.UserId + "/\(userID)")) { (success, error, result) in
            
            func sendError(_ errorString: String) {
                completionHandlerForUserData(false, NSError(domain: "taskForGETMethod", code: 1, userInfo: [NSLocalizedDescriptionKey: errorString]))
            }
            
            guard error == nil else {
                    sendError(error?.localizedDescription ?? "An unknown error occured")
                return
            }
            
            if success{
                
                guard let user = result?["user"] as? [String: AnyObject] else {
                    sendError("Unable to find \"user\" in: \(String(describing: result))")
                    return
                }
                
                // Get User Data
                if let lastName = user["last_name"] as? String {
                    print(lastName)
                    self.lastName = lastName
                }
                if let firstName = user["first_name"] as? String{
                    print(firstName)
                    self.firstName = firstName
                }
                completionHandlerForUserData(true,nil)
            }
            
        }
    }
    
    
    func getSession(_ completionHandlerForGETSession: @escaping(_ success: Bool,_ error: NSError?) -> Void) {
        
        taskForPOSTMethod(Udacity.Methods.Session) { (success, error, result) in
            
            func sendError(_ errorString: String) {
                completionHandlerForGETSession(false, NSError(domain: "taskForPOSTMethod",code: 1, userInfo: [NSLocalizedDescriptionKey: errorString]))
            }
            
            guard error == nil else {
                sendError(error?.localizedDescription ?? "An unknown error occured")
                return
            }
            
            if success{
                guard let session = result?[Udacity.JSONResponseKeys.Session] as? [String: AnyObject] else {
                    sendError("Unable to find \"session\" in: \(String(describing: result))")
                    return
                }
                
                guard let account = result?[Udacity.JSONResponseKeys.Account] as? [String: AnyObject] else {
                    sendError("Unable to find \"account\" in: \(String(describing: result))")
                    return
                }
                // Get Session Data
                if let sessionid = session[Udacity.JSONResponseKeys.SessionID] as? String {
                    print(sessionid)
                    self.sessionID = sessionid
                }
                
                if let userid = account[Udacity.JSONResponseKeys.UserID] as? String {
                    self.userID = userid
                    print(userid)
                }
               
                completionHandlerForGETSession(true,nil)
            }
        }
    }
    
    
    func udacityLogin(email: String, password: String, _ completionHandlerForUdacityLogin: @escaping(_ success: Bool,_ error: NSError?) ->Void) {
        
        self.loggedFromFacebook = false
        self.userEmail = email
        self.password = password
        
        getSession() { (success, error ) in
            
            if success{
                self.getUserData() { (success, error) in
                    
                    if success{
                        completionHandlerForUdacityLogin(true,nil)
                    } else {
                        completionHandlerForUdacityLogin(false,error)
                    }
                }
            } else {
                completionHandlerForUdacityLogin(false, error)
            }
        }
    }

    func facebookLogin(accessToken: String, _ completionHandlerForFacebookLogin: @escaping(_ success: Bool,_ error: NSError?) -> Void) {
        
        self.loggedFromFacebook = true
        self.facebookToken = accessToken
        
        getSession() { (success, error ) in
            
            if success{
                self.getUserData() { (success, error) in
                    if success{
                        completionHandlerForFacebookLogin(true, nil)
                    } else {
                        completionHandlerForFacebookLogin(false,error)
                    }
                }
            } else {
                completionHandlerForFacebookLogin(false,error)
            }
        }
    }
            
    func logoutFromSession(_ completionHandlerForLogout: @escaping(_ success: Bool,_ error: NSError?) -> Void) {
        
        taskForDELETEMethod(Udacity.Methods.Session) { (success, error, result) in
            
            func sendError(_ errorString: String) {
                completionHandlerForLogout(false, NSError(domain: "taskForDELETEMethod",code: 0, userInfo: [NSLocalizedDescriptionKey: errorString]))
            }
            
            guard error == nil else {
                sendError(error?.localizedDescription ?? "An unknown error occured")
                return
            }
            
            if success{
                if self.loggedFromFacebook{
                    let fbLoginManager = FBSDKLoginManager()
                    fbLoginManager.logOut()
                }
                completionHandlerForLogout(true,nil)
            }
                
        }
            
    }
    
}
