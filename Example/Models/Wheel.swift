//
//  Wheel.swift
//  Example
//
//  Created by Antonio Casero Palmero on 10/08/16.
//  Copyright © 2016 Antonio Casero Palmero. All rights reserved.
//

import Foundation
import CloudkitMapper

 final class Wheel : CloudObject {
    var name : String!
    var number : Int!
    
    required init() {
        super.init()
        self.recordType = "Wheel"
        super.initializeRecord()
    }

    
}