//
//  DataSource.swift
//  on-the-map
//
//  Created by Pedro De Morais Chiossi on 17/05/18.
//  Copyright © 2018 Pedro Chiossi. All rights reserved.
//



 final class DataSource {

    static let sharedInstance = DataSource()
    
    var studentsInformation = [StudentInformation]()
    
    private init() {}
    
}
