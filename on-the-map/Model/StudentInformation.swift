//
//  Student.swift
//  on-the-map
//
//  Created by Pedro De Morais Chiossi on 09/05/18.
//  Copyright © 2018 Pedro Chiossi. All rights reserved.
//

import Foundation

struct StudentInformation{
    
    var objectId: String?
    var uniqueKey: String?
    var firstName: String?
    var lastName: String?
    var mapString: String?
    var mediaUrl: String?
    var latitude: Double?
    var longitude: Double?
    var createdAt: Date?
    var updatedAt: Date?
    
    /* Construct a StudentInformation from a dictionary */
    init(dictionary: [String : AnyObject]) {
        
        objectId = dictionary[Parse.JSONResponseKeys.ObjectID] as? String  
        uniqueKey = dictionary[Parse.JSONResponseKeys.UniqueKey] as? String
        firstName = dictionary[Parse.JSONResponseKeys.FirstName] as? String ?? ""
        lastName = dictionary[Parse.JSONResponseKeys.LastName] as? String ?? ""
        mapString = dictionary[Parse.JSONResponseKeys.MapString] as? String ?? ""
        mediaUrl = dictionary[Parse.JSONResponseKeys.MediaURL] as? String ?? ""
        latitude = dictionary[Parse.JSONResponseKeys.Latitude] as? Double
        longitude = dictionary[Parse.JSONResponseKeys.Longitude] as? Double
        createdAt = dictionary[Parse.JSONResponseKeys.CreatedAt] as? Date
        updatedAt = dictionary[Parse.JSONResponseKeys.UpdatedAt] as? Date
        
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of StudentInformation objects */
    static func studentsFromResults(_ results: [[String : AnyObject]]) -> [StudentInformation] {
        var students = [StudentInformation]()
        
        for result in results {
            students.append(StudentInformation(dictionary: result))
        }
        
        return students
    }
}
