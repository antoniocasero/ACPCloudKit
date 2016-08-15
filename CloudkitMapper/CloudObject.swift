//
//  CloudObject.swift
//  CloudkitMapper
//
//  Created by Palmero, Antonio on 09/08/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//

import Foundation
import CloudKit

public class CloudObject : NSObject {
    
    public var recordType:String = ""
    public var record:CKRecord?
    public var currentDatabase:CKDatabase
    
    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase
    
    
    var referencesKeys : [String] = []
    var references : [String : CKReference] = [:]
    var referenceLists : [String : [CKReference]] = [:]
    
    public required init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
        
        // Default is always current DB
        self.currentDatabase = publicDB
    }
    
    public func initializeRecord() {
        self.record = CKRecord(recordType: self.recordType)
    }
    
    public func encode() -> NSData? {
        if let record = self.record {
            let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(record)
            return archivedObject
        }
        
        return nil
    }
    
    public func decode(data:NSData) -> CloudObject? {
        if let record = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? CKRecord {
            self.record = record
            return self
        } else {
            return nil
        }
    }
    
    public func propertyNames() -> [String] {
        return Mirror(reflecting: self).children.flatMap { $0.label }
    }
    
    public func updatedRecord() -> CKRecord? {
        if let record = self.record {
            let properties = propertyNames()
            for property in properties {
                if let value = self.valueForKey(property) as? CKRecordValue {
                    record[property] = value
                } else {
                    record[property] =
                }
            }
            return record
        }
        return nil
    }
}


