//
//  Wheel.swift
//  Example
//
//  Created by Antonio Casero Palmero on 10/08/16.
//  Copyright © 2016 Antonio Casero Palmero. All rights reserved.
//

import Foundation
import ACPCloudKit

final  class Wheel : CloudObject {
    
    required init() {
        super.init()
        self.recordType = "Wheel"
        super.initializeRecord()
    }
    
    
    var name:String?
    var number:NSNumber?
    
    
}
