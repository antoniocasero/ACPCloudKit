//
//  CloudObject.swift
//  CloudkitMapper
//
//  Created by Palmero, Antonio on 09/08/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//

import Foundation
import CloudKit

open class CloudObject : NSObject {
    
    open var recordType:String = ""
    open var record:CKRecord?
    open var currentDatabase:CKDatabase
    open var createdAt:Date {
        get {
            return self.record?.creationDate ?? Date()
        }
    }
    open var uniqueId: String {
        get {
            return self.record?.recordID.recordName ?? ""
        }
    }
    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase
    
    
    var references : [String : CKReference] = [:]
    var referenceLists : [String : [CKReference]] = [:]
    
    public required override init() {
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
        
        // Default is always current DB
        self.currentDatabase = publicDB
        print("Database used ")
    }
    
    public func initializeRecord() {
        self.record = CKRecord(recordType: self.recordType)
    }
    
    public func encode() -> Data? {
        if let record = self.record {
            let archivedObject = NSKeyedArchiver.archivedData(withRootObject: record)
            return archivedObject
        }
        
        return nil
    }
    
    public func decode(data:Data) -> CloudObject? {
        if let record = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? CKRecord {
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
                if let value = self.value(forKey: property) as? CKRecordValue {
                    record[property] = value
                } else {
                    //then it has to be another CloudObject. We need to update it as well.
                    if let cloudObject = self.value(forKey: property) as? CloudObject  {
                        cloudObject.updatedRecord()
                        if let recordCloud = cloudObject.record {
                            let ref = CKReference(record:recordCloud, action:.none)
                            record[property] = ref
                        }
                        
                    } else {
                        assertionFailure("We should never be here")
                    }
                }
            }
            return record
        }
        return nil
    }
    
    public func populate(record:CKRecord) {
        self.record = record
        let properties = propertyNames()
        for property in properties {
            if (self.responds(to: NSSelectorFromString(property))) {
                if let ref = record[property] as? CKReference {
                    self.references[property] = ref
                }
                else if let value = record[property] {
                    self.setValue(value, forKey:property)
                }
            }
        }
    }
    
    public func referenceDependencies() -> [String:CKReference] {
        var dependencies : [String : CKReference] = [:]
        let properties = propertyNames()
        for property in properties {
            if (self.responds(to: NSSelectorFromString(property))) {
                if let value = record![property] , ((value as? CKReference) != nil) {
                    dependencies[property] = value as? CKReference
                }
            }
        }
        return dependencies
    }
    
    
    public func dependencies() -> [CloudObject] {
        var collect : [CloudObject] = []
        let properties = propertyNames()
        for property in properties {
            if let value = self.value(forKey: property) as? CloudObject {
                collect.append(value)
            }
        }
        return collect
    }
    
    public func incrementKey(name:String){
    
    }
    
    public func incrementKey(name:String, byAmount:Int){
        
    }
}


