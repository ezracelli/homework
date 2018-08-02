//
//  Assignment.swift
//  Homework
//
//  Created by Ezra Celli on 5/15/18.
//  Copyright © 2018 Ezra Celli. All rights reserved.
//

import UIKit
import os.log

class Assignment: NSObject, NSCoding {
    
    
// MARK: Properties
    
    var assignmentName: String
    var dueDate: NSDate
    var className: String
    var uuid: String
    
    
// MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("assignments")
    

    
// MARK: Types
    
    struct PropertyKey {
        static let assignmentName = "assignmentName"
        static let dueDate = "dueDate"
        static let className = "className"
        static let uuid = "uuid"
    }
    
    
// MARK: Initialization
    
    init(assignmentName: String, dueDate: NSDate, className: String, uuid: String) {
        self.assignmentName = assignmentName
        self.dueDate = dueDate
        self.className = className
        self.uuid = uuid
    }
    
    
// MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(assignmentName, forKey: PropertyKey.assignmentName)
        aCoder.encode(dueDate, forKey: PropertyKey.dueDate)
        aCoder.encode(className, forKey: PropertyKey.className)
        aCoder.encode(uuid, forKey: PropertyKey.uuid)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // decodeObject(forkey:) returns an Any? type, must safely unwrap and cast
        guard let assignmentName = aDecoder.decodeObject(forKey: PropertyKey.assignmentName) as? String else {
            os_log("Unable to decode the name for an Assignment object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let dueDate = aDecoder.decodeObject(forKey: PropertyKey.dueDate) as? NSDate else {
            os_log("Unable to decode the date for an Assignment object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let className = aDecoder.decodeObject(forKey: PropertyKey.className) as? String else {
            os_log("Unable to decode the course for an Assignment object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let uuid = aDecoder.decodeObject(forKey: PropertyKey.uuid) as? String else {
            os_log("Unable to decode the UUID for an Assignment object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Must call designated initializer.
        self.init(assignmentName: assignmentName, dueDate: dueDate, className: className, uuid: uuid)
    }
}
