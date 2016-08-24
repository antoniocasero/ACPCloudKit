//
//  ViewController.swift
//  Example
//
//  Created by Antonio Casero Palmero on 10/08/16.
//  Copyright © 2016 Antonio Casero Palmero. All rights reserved.
//

import UIKit
import CloudKit
import CloudkitMapper
import ReactiveCocoa

class ViewController: UIViewController {

    let coordinator = CloudCoordinator<Car>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let car = Car()
        car.initializeRecord()
        let wheel = Wheel()
        wheel.initializeRecord()
        wheel.name = "WheelName"
        wheel.number = 2323
        car.wheel = wheel
        car.name = "CarName"

        car.rac_deepSave().producer
        .on { error in
            print("\(error)")
        }.startWithNext { 
            print("saved")
        }
        
        
        coordinator.deepFetch(nil)
        .producer
        .startWithNext { object in
            print("\(object)")

        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

