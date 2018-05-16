//
//  ParseConvenience.swift
//  on-the-map
//
//  Created by Pedro De Morais Chiossi on 11/05/18.
//  Copyright © 2018 Pedro Chiossi. All rights reserved.
//

import Foundation
import MapKit
extension ParseClient {
    
    
    func getStudentsInfo(_ completionHandlerForStudentsInfo: @escaping(_ success: Bool,_ error: NSError?) -> Void) {
        
        let parameters: [String:String] = [
            Parse.ParameterKeys.Limit: "100",
            Parse.ParameterKeys.Order: "-updatedAt"]
        
        let url = createParseURL(method: Parse.Methods.StudentLocation, parameters)!
        
        let request = NSMutableURLRequest(url: url)
        
        taskForGETMethod(request) { (success, error, result) in
            
            func sendError(_ errorString: String) {
                completionHandlerForStudentsInfo(false, NSError(domain: "taskForPOSTMethod",code: 1, userInfo: [NSLocalizedDescriptionKey: errorString]))
            }
            
            guard (error == nil) else{
                sendError(error?.localizedDescription ?? "An Unknown error ocurred")
                return
            }
            if success{
                if let results = result?[Parse.JSONResponseKeys.Results] as? [[String : AnyObject]] {
                    let studentsInfo = StudentInformation.studentsFromResults(results)
                    self.studentsInformation = studentsInfo
                    completionHandlerForStudentsInfo(true, nil)
                } else {
                    sendError("Could not find \"results\" in parsed data")
                
                }
            
            }
        }
    
    }
    
    
    func getUserInfo(_ completionHandlerForUserInfo: @escaping(_ success: Bool,_ error: NSError?) -> Void) {
        
        guard let uniqueKey = UdacityClient.sharedInstance().userID else {
            completionHandlerForUserInfo(false, NSError(domain: "getUserInfo", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not get user info. uniqueKey not set"]))
            return
        }
        
        let parameters: [String:String] = [
            Parse.ParameterKeys.Where: "{\"uniqueKey\":\"\(uniqueKey)\"}",
            Parse.ParameterKeys.Order: "-updatedAt"]
        
        
        let url = createParseURL(method: Parse.Methods.StudentLocation, parameters)!
        
        let request = NSMutableURLRequest(url: url)
        
        taskForGETMethod(request) { (success, error, result) in
            
            func sendError(_ errorString: String) {
                completionHandlerForUserInfo(false, NSError(domain: "taskForPOSTMethod",code: 1, userInfo: [NSLocalizedDescriptionKey: errorString]))
            }
            
            guard (error == nil) else{
                sendError(error?.localizedDescription ?? "An Unknown error ocurred")
                return
            }
            if success{
                if let results = result?[Parse.JSONResponseKeys.Results] as? [[String : AnyObject]] {
                    let studentsInfo = StudentInformation.studentsFromResults(results)
                    self.userObjectID = studentsInfo[0].objectId
                    completionHandlerForUserInfo(true, nil)
                } else {
                    sendError("Could not find \"results\" in parsed data")
                }
            }
        }
    }
    
    
    func updateUserInfo(_ completionHandlerForUpdateUser: @escaping(_ success: Bool, _ error: NSError?) -> Void) {
        
        
        let parameters = buildParameters()
        
        taskForPUTMethod(parameters) { (success, error) in
            
            func sendError(_ errorString: String) {
                completionHandlerForUpdateUser(false, NSError(domain: "taskForPUTMethod", code: 1, userInfo: [NSLocalizedDescriptionKey: errorString]))
            }
            
            guard error == nil else {
                sendError(error?.localizedDescription ?? "An unknown error occured")
                return
            }
            
            if success{
                completionHandlerForUpdateUser(true, nil)
            }
            
        }
    }
    
    
    func postStudentInfo(_ completionHandlerForPostStudentInfo: @escaping(_ success: Bool,_ errror: NSError?) -> Void) {
        
        let parameters = buildParameters()
        
        taskForPOSTMethod(parameters) { (success, error) in
            
            func sendError(_ errorString: String) {
                completionHandlerForPostStudentInfo(false, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: [NSLocalizedDescriptionKey: errorString]))
            }
            
            guard error == nil else {
                sendError(error?.localizedDescription ?? "An unknown error occured")
                return
            }
            
            if success{
                completionHandlerForPostStudentInfo(true, nil)
            }
        
        }
        
    }
    
    func buildParameters()->[String:AnyObject] {
        
        let parameters = [    Parse.JSONResponseKeys.UniqueKey: UdacityClient.sharedInstance().userID as AnyObject,
                              Parse.JSONResponseKeys.FirstName: UdacityClient.sharedInstance().firstName as AnyObject,
                              Parse.JSONResponseKeys.LastName: UdacityClient.sharedInstance().lastName as AnyObject,
                              Parse.JSONResponseKeys.MapString: self.userMapString as AnyObject,
                              Parse.JSONResponseKeys.MediaURL: self.userMediaUrl as AnyObject,
                              Parse.JSONResponseKeys.Latitude: self.userLatitude as AnyObject,
                              Parse.JSONResponseKeys.Longitude: self.userLongitude as AnyObject]
        return parameters
    }
    
}
