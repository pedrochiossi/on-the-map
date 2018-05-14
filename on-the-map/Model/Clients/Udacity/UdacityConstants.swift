//
//  UdacityConstants.swift
//  on-the-map
//
//  Created by Pedro De Morais Chiossi on 09/05/18.
//  Copyright © 2018 Pedro Chiossi. All rights reserved.
//

import Foundation

struct Udacity {
    
    struct Constants{
        
        // MARK: URLs
        
        static let APIScheme = "https"
        static let APIHost = "www.udacity.com"
        static let APIPath = "/api"
        static let SignUpURL = "https://udacity.com/account/auth#!/signup"
    }
    
    // MARK: Methods
    struct Methods{
        
        static let UserId = "/users"
        static let Session = "/session"
        static let Get = "GET"
        static let Post = "POST"
        static let Delete = "DELETE"
    }
    // MARK: HTTP Header
    struct HTTPHeader{
        
        static let AcceptKey = "Accept"
        static let ContentTypeKey = "Content-Type"
        static let ApplicationJSON = "application/json"
        
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys{
        
        static let UdacityLogin = "udacity"
        static let Username = "username"
        static let Password = "password"
        static let FacebookLogin = "facebook_mobile"
        static let AccessToken = "access_token"
        
    }
    
    //MARK:  JSON Response Keys
    struct JSONResponseKeys{
    
        static let Session = "session"
        static let SessionID = "id"
        static let Account = "account"
        static let UserID = "key"
        static let RegisteredUser = "registered"
        static let UserInfo = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        static let StatusCode = "status"
        static let StatusMessage = "error"
    
    }
    
    // MARK: Cross-site Request Forgery
    struct XSRF {
        static let CookieName = "XSRF-TOKEN"
        static let HTTPHeader = "X-XSRF-TOKEN"
    }
    
    
}
