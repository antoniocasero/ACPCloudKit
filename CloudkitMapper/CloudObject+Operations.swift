//
//  CloudCoordinator.swift
//  CloudkitMapper
//
//  Created by Palmero, Antonio on 09/08/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//

import Foundation
import CloudKit
import ReactiveSwift
import enum Result.NoError

public typealias NoError = Result.NoError

public enum CloudError : Error {
    case errorOperation
    case errorSavingLocally
    case errorUnathorized
}

extension Array {
    func rx_loop<T>() -> SignalProducer<T, NoError> {
        return SignalProducer<T, NoError> { observer, _ -> () in
            for element in self {
                let elementT : T = element as! T
                observer.send(value: elementT)
            }
            observer.sendCompleted()
        }
    }
}
extension Dictionary {
    func rx_loop<T,U>() -> SignalProducer<(T,U), NoError> {
        return SignalProducer<(T,U), NoError> { observer, _ -> () in
            for (key, value) in self {
                let keyT : T = key as! T
                let valueU : U = value as! U
                observer.send(value: (keyT, valueU))
            }
            observer.sendCompleted()
        }
    }
}

public extension CloudObject {
    
    //Public RAC API
    public func rac_deepSave() -> SignalProducer<(), CloudError> {
        //Save all the sub objects
        return self.dependencies().rx_loop()
            .flatMap(.concat) { (cloudObject : CloudObject) -> SignalProducer<(), CloudError> in
            return cloudObject.rac_save()
        }
        .collect()
        .flatMap(.concat) { _ in
            return self.rac_save()
        }
        
    }
    
    public func rac_save() -> SignalProducer<(), CloudError> {
        return SignalProducer { observer, disposable in
            self.save(observer)
        }
    }
    
    
    public func rac_fetchReference<T:CloudObject>(_ referenceName:String) -> SignalProducer<T, CloudError> {
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
    
     public func rac_fetchReferences<T:CloudObject>() -> SignalProducer<T, CloudError> {
        return self.references.rx_loop()
            .flatMap(.merge) { (key : String, value : CKReference) -> SignalProducer<T, CloudError> in
                return self.rac_fetchReference(key)
                    .on(value: { model in
                        //I need to assign this model to the object. (with the key)
                        //We need the key.
                        self.setValue(model, forKey: key)
                    })
        }
        
    }
    
    
//Internal methods
    
     func save(_ observer: Observer<Void, CloudError>) {
        if let record = self.updatedRecord() {
            print("Object \(record) is going to be saved")
            self.currentDatabase.save(record, completionHandler: { (record, error) -> Void in
                guard error == nil && record?.recordID != nil else {
                    observer.send(error: .errorOperation)
                    return
                }
                self.record = record
                print("Object \(record) saved")
                observer.sendCompleted()
            })
        }
    }
    
     func fetchReferenceRecord(_ reference:CKReference, observer: Observer<CKRecord?, CloudError>) {
            self.currentDatabase.fetch(withRecordID: reference.recordID, completionHandler: { (record, error) -> Void in
//                guard error == nil && record?.recordID != nil else {
//                    observer.sendFailed(.errorOperation)
//                    return
//                }
                observer.send(value: record)
                observer.sendCompleted()
            })
    }

}
