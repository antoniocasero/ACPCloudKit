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


}