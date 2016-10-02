//
//  CloudCoordinator.swift
//  CloudkitMapper
//
//  Created by Palmero, Antonio on 10/08/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//

import Foundation
import CloudKit
import ReactiveSwift

open class CloudCoordinator<T:CloudObject> {
    
    open var localCache = CloudCache<T>()
    
    var model:T = T()
    
    var fetchedRecords = Array<T>()
    
    let login = CloudLogin();
    
    public init() {
        localCache.defaultKey = model.recordType
    }
    
    
    open func deepFetch(_ predicate:NSPredicate?) -> SignalProducer<[T],CloudError> {
        var array : [T] = []
        return self.fetchObjects(predicate)
            .on(value: { object in
                array.append(object)
            })
            .flatMap(.merge) { (cloud : T) -> SignalProducer<T, CloudError> in
                return cloud.rac_fetchReferences()
            }
            .collect().on(completed: {
                print("Completed puto")
            })
            .map({ _ in
                return array
            })
    }
    
    open func fetchObjects(_ predicate:NSPredicate?) -> SignalProducer<T,CloudError> {
        let signalFetch = SignalProducer<T,CloudError> { observer, _ in
            let predicate = predicate ?? NSPredicate(value: true)
            let type = self.model.recordType
            print("Predicate \(predicate)")
            let query = CKQuery(recordType: type, predicate: predicate)
            self.model.currentDatabase.perform(query, inZoneWith: nil, completionHandler: { records, error in
                guard error == nil else {
                    print("Error query \(error?.localizedDescription)")
                    observer.send(error: .errorOperation)
                    return
                }
                let _ : [T] = records?.map({ (recordFetched) -> T in
                    let cloudModel = T()
                    cloudModel.populate(record: recordFetched)
                    observer.send(value: cloudModel)
                    return cloudModel
                }) ?? []
                observer.sendCompleted()
            })
        }
        return signalFetch
    }
        
    open func fetchLocallyAndThenRequestObjects(_ predicate:NSPredicate?) -> SignalProducer<[T],CloudError> {
        return self.deepFetch(predicate)
//        return self.localCache.rac_restoreLocally()
//        .concat(self.deepFetch(predicate))
    }


}
