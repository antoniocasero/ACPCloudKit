//
//  CloudCache.swift
//  CloudkitMapper
//
//  Created by Palmero, Antonio on 09/08/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//

import Foundation
import ReactiveCocoa

public class CloudCache<T:CloudObject> {
    
    var userDefaults = NSUserDefaults.standardUserDefaults()
    var defaultKey = "CloudCache.DefaultKey"
    
    
    public func rac_storeLocally<T:CloudObject>(data:[T], cachingKey:String? = nil) -> SignalProducer<Void, CloudError> {
        return SignalProducer<Void, CloudError> { observer, _ in
            if let dataT = data as? [T]{
                self.storeData(dataT, cachingKey: cachingKey, completion: { error in
                    observer.sendCompleted()
                })
            } else {
                observer.sendFailed(.errorSavingLocally)
            }
        }
        
    }
    
    public func storeData<T:CloudObject>(data:[T], cachingKey:String? = nil, completion: (error: CloudError) -> ()) {
        
        var serializableObjects = Array<NSData>()
        
        for model in data {
            if let offlineObject = model.encode() {
                serializableObjects.append(offlineObject)
            }
        }
        
        userDefaults.setObject(serializableObjects, forKey: cachingKey ?? defaultKey)
        userDefaults.synchronize()
    }
    
    public func rac_restoreLocally<T:CloudObject>(cachingKey:String? = nil) -> SignalProducer<[T], CloudError> {
        return SignalProducer<[T], CloudError> { observer, _ in
                let objects  = self.loadData(cachingKey)
                observer.sendNext(objects)
                observer.sendCompleted()
        }
        
    }
    
    public func loadData<T:CloudObject>(cachingKey:String? = nil) -> [T] {
        
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
    
    public func decode<T:CloudObject>(data:NSData) -> [T] {
        if let models = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Array<T> {
            return models
        } else {
            return []
        }
    }
}