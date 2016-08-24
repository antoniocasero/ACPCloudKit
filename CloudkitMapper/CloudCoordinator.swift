//
//  CloudCoordinator.swift
//  CloudkitMapper
//
//  Created by Palmero, Antonio on 10/08/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//

import Foundation
import CloudKit
import ReactiveCocoa

public class CloudCoordinator<T:CloudObject> {
    
    public var localCache = CloudCache<T>()
    
    var model:T = T()
    
    var fetchedRecords = Array<T>()
    
    public init() {
        localCache.defaultKey = model.recordType
    }
    
    
    public func deepFetch(predicate:NSPredicate?) -> SignalProducer<[T],CloudError> {
        var array : [T] = []
        return self.fetchObjects(predicate)
            .on(next: { object in
                array.append(object)
            })

            .flatMap(.Merge) { (cloud) -> SignalProducer<T, CloudError> in
                return cloud.rac_fetchReferences()
            }
            .collect().on(completed: { 
                print("Completed puto")
            })
            .map({ _ in
                return array
            })
    }
    
    public func fetchObjects(predicate:NSPredicate?) -> SignalProducer<T,CloudError> {
        let signalFetch = SignalProducer<T,CloudError> { observer, _ in
            let predicate = predicate ?? NSPredicate(value: true)
            let type = self.model.recordType
            let query = CKQuery(recordType: type, predicate: predicate)
            self.model.currentDatabase.performQuery(query, inZoneWithID: nil, completionHandler: { records, error in
                guard error == nil else {
                    observer.sendFailed(.errorOperation)
                    return
                }
                let _ : [T] = records?.map({ (recordFetched) -> T in
                    let cloudModel = T()
                    cloudModel.populate(recordFetched)
                    observer.sendNext(cloudModel)
                    return cloudModel
                }) ?? []
                observer.sendCompleted()
            })
        }
        return signalFetch
    }
        
    public func fetchLocallyAndThenRequestObjects(name:String, predicate:NSPredicate) -> SignalProducer<[T],CloudError> {
        return self.localCache.rac_restoreLocally()
        .concat(self.fetchObjects(predicate).collect())
    }


}