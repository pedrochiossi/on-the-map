//
//  ParseClient.swift
//  on-the-map
//
//  Created by Pedro De Morais Chiossi on 09/05/18.
//  Copyright © 2018 Pedro Chiossi. All rights reserved.
//

import Foundation

class ParseClient: NSObject {
    
    var session = URLSession.shared
    var userMapString: String?
    var userObjectID: String?
    var userMediaUrl: String?
    var userLatitude: Double?
    var userLongitude: Double?
    var studentsInformation = [StudentInformation]()
    
    
    override init() {
        super.init()
    }
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
    func taskForPOSTMethod(_ parameters: [String: AnyObject] , completionHandlerForPOST: @escaping (_ successs: Bool,_ error: NSError?) -> Void)  {
        
        guard let request = createParsePOSTRequestFrom(parameters: parameters) else {
            completionHandlerForPOST(false, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create POST Request"]))
            return
        }
    
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(false, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
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
            guard data != nil else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            completionHandlerForPOST(true, nil)
        }
        
        /* 7. Start the request */
        task.resume()
        
    }
    
    
    func taskForGETMethod(_ request: NSMutableURLRequest , completionHandlerForGET: @escaping (_ successs: Bool,_ error: NSError?, _ result: [String: AnyObject]?) -> Void)  {
        
        request.addValue(Parse.HTTPHeaderKeys.APIKeyValue, forHTTPHeaderField: Parse.HTTPHeaderKeys.ApiKey)
        request.addValue(Parse.HTTPHeaderKeys.ApplicationIDValue, forHTTPHeaderField: Parse.HTTPHeaderKeys.ApplicationID)
        request.httpMethod = Parse.Methods.Get
        
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
    
    
    func taskForPUTMethod(_ parameters: [String: AnyObject] , completionHandlerForPUT: @escaping (_ successs: Bool,_ error: NSError?) -> Void)  {
        
        guard let request = createParsePUTRequestFrom(parameters: parameters) else {
            completionHandlerForPUT(false, NSError(domain: "taskForPUTMethod", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create PUT Request"]))
            return
        }
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPUT(false, NSError(domain: "taskForPUTMethod", code: 1, userInfo: userInfo))
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
            guard data != nil else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
           completionHandlerForPUT(true, nil)
        }
        
        /* 7. Start the request */
        task.resume()
        
    }
    
    
    
    func createParsePOSTRequestFrom( parameters: [String:AnyObject]) -> URLRequest? {
        
        
        guard let url = createParseURL(method: Parse.Methods.StudentLocation, pathExtension: nil, [:]) else {
            return nil
        }
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = Parse.Methods.Post
        request.addValue(Parse.HTTPHeaderKeys.APIKeyValue, forHTTPHeaderField: Parse.HTTPHeaderKeys.ApiKey)
        request.addValue(Parse.HTTPHeaderKeys.ApplicationIDValue, forHTTPHeaderField: Parse.HTTPHeaderKeys.ApplicationID)
        request.addValue(Parse.HTTPHeaderKeys.ApplicationJSONValue, forHTTPHeaderField: Parse.HTTPHeaderKeys.ContentTypeKey)
        request.httpBody = self.jsonDataFrom(object: parameters)
        
        return request as URLRequest
    }
    
    
    func jsonDataFrom(object: [String:AnyObject]) -> Data? {
        
        let jsonData: Data?
        
        do{
            jsonData = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
        } catch {
            return nil
        }
        return jsonData
    }
    
    
    
    func createParseURL(method: String?, pathExtension: String?,_ parameters: [String: String]) -> URL? {
        
        var components = URLComponents()
        components.scheme = Parse.Constants.ApiScheme
        components.host = Parse.Constants.ApiHost
        components.path = Parse.Constants.ApiPath + (method ?? "") + (pathExtension ?? "")
        var queryItems = [URLQueryItem]()
        
        if !parameters.isEmpty {
            for pairs in parameters {
                queryItems.append(URLQueryItem(name: pairs.key, value: pairs.value))
            }
            
            components.queryItems = queryItems
        }
        
        return components.url
    }
  
    
    func createParsePUTRequestFrom(parameters: [String:AnyObject]) -> URLRequest? {
        
        guard let url = createParseURL(method: Parse.Methods.StudentLocation, pathExtension: self.userObjectID , [:]) else {
            return nil
        }
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = Parse.Methods.Put
        request.addValue(Parse.HTTPHeaderKeys.APIKeyValue, forHTTPHeaderField: Parse.HTTPHeaderKeys.ApiKey)
        request.addValue(Parse.HTTPHeaderKeys.ApplicationIDValue, forHTTPHeaderField: Parse.HTTPHeaderKeys.ApplicationID)
        request.addValue(Parse.HTTPHeaderKeys.ApplicationJSONValue, forHTTPHeaderField: Parse.HTTPHeaderKeys.ContentTypeKey)
        request.httpBody = self.jsonDataFrom(object: parameters)
        
        return request as URLRequest
    }
    
    
    
    func parseData(_ data: Data, completionHandlerForParsedData: (_ success: Bool, _ error: NSError?,_ result: [String:AnyObject]?) -> Void) {
        
        var parsedResult: [String: AnyObject]! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForParsedData(false, NSError(domain: "parseData", code: 1, userInfo: userInfo), nil)
            return
        }
        
        // Use parsed data
        completionHandlerForParsedData(true,nil,parsedResult)
    }
    
    
}
