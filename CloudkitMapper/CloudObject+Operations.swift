//
//  CloudCoordinator.swift
//  CloudkitMapper
//
//  Created by Palmero, Antonio on 09/08/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//

import Foundation
import CloudKit
import ReactiveCocoa
import enum Result.NoError

public typealias NoError = Result.NoError

public enum CloudError : ErrorType {
    case errorOperation
    case errorSavingLocally
}

extension Array {
    func rx_loop<T>() -> SignalProducer<T, NoError> {
        return SignalProducer<T, NoError> { observer, _ -> () in
            for element in self {
                let elementT : T = element as! T
                observer.sendNext(elementT)
            }
            observer.sendCompleted()
        }
    }
}

public extension CloudObject {
    
    //Public RAC API
    public func rac_save() -> SignalProducer<(), CloudError> {
        return SignalProducer { observer, disposable in
            self.save(observer)
        }
    }
    
    public func rac_fetchReference<T:CloudObject>(referenceName:String) -> SignalProducer<T, CloudError> {
        let signalProducer =  SignalProducer<CKRecord?, CloudError> { observer, disposable in
            let reference = self.record?[referenceName] as! CKReference
            self.references.updateValue(reference, forKey: referenceName)
            self.fetchReferenceRecord(reference, observer: observer)
        }
       return signalProducer.map { record -> T in
            let cloudModel = T()
            cloudModel.record = record
            return cloudModel
        }
    }
     public func rac_fetchReferences<T:CloudObject>() -> SignalProducer<[T], CloudError> {
        return self.referencesKeys.rx_loop()
        .flatMap(.Concat) { referenceName -> SignalProducer<T, CloudError> in
            return self.rac_fetchReference(referenceName)
        }
        .collect()
    }
    
     func save(observer: Observer<Void, CloudError>) {
        if let record = self.record {
            self.currentDatabase.saveRecord(record, completionHandler: { (record, error) -> Void in
                guard error == nil && record?.recordID != nil else {
                    observer.sendFailed(.errorOperation)
                    return
                }
                observer.sendCompleted()
            })
        }
    }
    
     func fetchReferenceRecord(reference:CKReference, observer: Observer<CKRecord?, CloudError>) {
            self.currentDatabase.fetchRecordWithID(reference.recordID, completionHandler: { (record, error) -> Void in
                guard error == nil && record?.recordID != nil else {
                    observer.sendFailed(.errorOperation)
                    return
                }
                observer.sendNext(record)
                observer.sendCompleted()
            })
    }

    public func setReferenceValue<T:CloudObject>(referenceName:String, value:T?) {
        if let givenRecord = value?.record {
            self.record?[referenceName] = CKReference(record: givenRecord, action: CKReferenceAction.None)
        }
    }
    


}