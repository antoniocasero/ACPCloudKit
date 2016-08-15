//
//  Car.swift
//  Example
//
//  Created by Antonio Casero Palmero on 10/08/16.
//  Copyright © 2016 Antonio Casero Palmero. All rights reserved.
//

import Foundation
import CloudkitMapper

final class Car : CloudObject {
    var name : String!
    var wheel : Wheel!
    
    required init() {
        super.init()
        self.recordType = "Car"
        super.initializeRecord()
        print("Properties \(self.propertyNames())")
    }
    
    
}