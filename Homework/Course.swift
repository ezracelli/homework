//
//  Course.swift
//  Homework
//
//  Created by Ezra Celli on 5/16/18.
//  Copyright © 2018 Ezra Celli. All rights reserved.
//

import UIKit
import os.log

class Course: NSObject, NSCoding {
    
    
    // MARK: Properties
    
    var courseName: String
    
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("courses")
    
    
    
    // MARK: Types
    
    struct PropertyKey {
        static let courseName = "courseName"
    }
    
    
    // MARK: Initialization
    
    init(courseName: String) {
        self.courseName = courseName
    }
    
    
    // MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(courseName, forKey: PropertyKey.courseName)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // decodeObject(forkey:) returns an Any? type, must safely unwrap and cast
        guard let courseName = aDecoder.decodeObject(forKey: PropertyKey.courseName) as? String else {
            os_log("Unable to decode the name for a Course object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Must call designated initializer.
        self.init(courseName: courseName)
    }
}
