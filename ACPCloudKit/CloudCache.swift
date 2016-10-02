//
//  CloudCache.swift
//  CloudkitMapper
//
//  Created by Palmero, Antonio on 09/08/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//

import Foundation
import ReactiveSwift

open class CloudCache<T:CloudObject> {
    
    var userDefaults = UserDefaults.standard
    var defaultKey = "CloudCache.DefaultKey"
    
    
    open func rac_storeLocally<T:CloudObject>(_ data:[T], cachingKey:String? = nil) -> SignalProducer<Void, CloudError> {
        return SignalProducer<Void, CloudError> { observer, _ in
                self.storeData(data , cachingKey: cachingKey, completion: { error in
                    observer.sendCompleted()
                })
        }
        
    }
    
    open func storeData<T:CloudObject>(_ data:[T], cachingKey:String? = nil, completion: (_ error: CloudError) -> ()) {
        
        var serializableObjects = Array<Data>()
        
        for model in data {
            if let offlineObject = model.encode() {
                serializableObjects.append(offlineObject as Data)
            }
        }
        
        userDefaults.set(serializableObjects, forKey: cachingKey ?? defaultKey)
        userDefaults.synchronize()
    }
    
    open func rac_restoreLocally<T:CloudObject>(_ cachingKey:String? = nil) -> SignalProducer<[T], CloudError> {
        return SignalProducer<[T], CloudError> { observer, _ in
                let objects  = self.loadData(cachingKey ?? self.defaultKey)
                observer.send(value: objects as! [T])
                observer.sendCompleted()
        }
        
    }
    
    open func loadData<T:CloudObject>(_ cachingKey:String? = nil) -> [T] {
        
        var models = Array<T>()
        
        if let serializedObjects = userDefaults.object(forKey: cachingKey ?? defaultKey) as? Array<Data> {
            for serializeObject in serializedObjects {
                
                let cloudModel = T()
                
                if let cloudModel = cloudModel.decode(data: serializeObject) as? T {
                    models.append(cloudModel)
                }
            }
            
            return models
        } else {
            return []
        }
    }
    
    open func decode<T:CloudObject>(_ data:Data) -> [T] {
        if let models = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? Array<T> {
            return models
        } else {
            return []
        }
    }
}
