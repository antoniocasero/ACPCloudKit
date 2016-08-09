//
//  CloudCache.swift
//  CloudkitMapper
//
//  Created by Palmero, Antonio on 09/08/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//

import Foundation

public class CloudCache<T:CloudObject> {
    
    var userDefaults = NSUserDefaults.standardUserDefaults()
    var defaultKey = "localCache.DefaultKey"
    
    public func storeData<T:CloudObject>(data:Array<T>, cachingKey:String? = nil) {
        
        var serializableObjects = Array<NSData>()
        
        for model in data {
            if let offlineObject = model.encode() {
                serializableObjects.append(offlineObject)
            }
        }
        
        userDefaults.setObject(serializableObjects, forKey: cachingKey ?? defaultKey)
        userDefaults.synchronize()
    }
    
    public func loadData<T:CloudObject>(cachingKey:String? = nil) -> Array<T> {
        
        var models = Array<T>()
        
        if let serializedObjects = userDefaults.objectForKey(cachingKey ?? defaultKey) as? Array<NSData> {
            for serializeObject in serializedObjects {
                
                let cloudModel = T()
                
                if let cloudModel = cloudModel.decode(serializeObject) as? T {
                    models.append(cloudModel)
                }
            }
            
            return models
        } else {
            return []
        }
    }
    
    public func decode<T:CloudObject>(data:NSData) -> Array<T> {
        if let models = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Array<T> {
            return models
        } else {
            return []
        }
    }
}