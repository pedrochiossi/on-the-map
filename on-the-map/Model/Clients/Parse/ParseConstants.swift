//
//  Constants.swift
//  on-the-map
//
//  Created by Pedro De Morais Chiossi on 10/05/18.
//  Copyright © 2018 Pedro Chiossi. All rights reserved.
//

import Foundation

struct Parse{
    
    struct Constants {
        
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes"
        
        
    }
    
    struct Methods{
        
        static let StudentLocation = "/StudentLocation"
        static let Get = "GET"
        static let Post = "POST"
        static let Put = "PUT"
    
        
    }
    
    struct HTTPHeaderKeys{
        static let ApplicationID = "X-Parse-Application-Id"
        static let ApplicationIDValue = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKeyValue = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ApiKey = "X-Parse-REST-API-Key"
        static let ContentTypeKey = "Content-Type"
        static let ApplicationJSONValue = "application/json"
    }
    
    
    struct ParameterKeys {
        
        static let Limit = "limit"
        static let Order = "order"
        static let Skip = "skip"
        
    }
    
    struct JSONResponseKeys {
        static let Results = "results"
        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let UpdatedAt = "updatedAt"
        static let ObjID = "objectId"
    }
    
}
