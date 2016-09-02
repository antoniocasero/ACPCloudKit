//
//  CloudLogin.swift
//  CloudkitMapper
//
//  Created by Palmero, Antonio on 02/09/16.
//  Copyright © 2016 Uttopia. All rights reserved.
//

import UIKit
import CloudKit
import ReactiveCocoa

class CloudLogin {
    
    let defaultContainer: CKContainer = CKContainer.defaultContainer()
    
    func rac_requestPermission() -> SignalProducer<Void,CloudError> {
        return SignalProducer { observer, _ in
            self.defaultContainer.requestApplicationPermission(CKApplicationPermissions.UserDiscoverability, completionHandler: { applicationPermissionStatus, error in
                if applicationPermissionStatus == CKApplicationPermissionStatus.Granted {
                    observer.sendCompleted()
                } else {
                    observer.sendFailed(.errorUnathorized)
                }
            })
        }
    }
    
    //    func getUser(completionHandler: (success: Bool, user: User?) -> ()) {
    //        defaultContainer!.fetchUserRecordIDWithCompletionHandler { (userRecordID, error) in
    //            if error != nil {
    //                completionHandler(success: false, user: nil)
    //            } else {
    //                let privateDatabase = self.defaultContainer!.privateCloudDatabase
    //                privateDatabase.fetchRecordWithID(userRecordID!, completionHandler: { (user: CKRecord?, anError) -> Void in
    //                    if (error != nil) {
    //                        completionHandler(success: false, user: nil)
    //                    } else {
    //                        let user = User(userRecordID: userRecordID!)
    //                        completionHandler(success: true, user: user)
    //                    }
    //                })
    //            }
    //        }
    //    }
    //
//        func getUserInfo(user: User, completionHandler: (success: Bool, user: User?) -> ()) {
//            defaultContainer!.discoverUserInfoWithUserRecordID(user.userRecordID) { (info, fetchError) in
//                if fetchError != nil {
//                    completionHandler(success: false, user: nil)
//                } else {
//                    user.firstName = info!.displayContact!.givenName
//                    user.lastName = info!.displayContact!.familyName
//                    completionHandler(success: true, user: user)
//                }
//            }
//        }
    
    
}
