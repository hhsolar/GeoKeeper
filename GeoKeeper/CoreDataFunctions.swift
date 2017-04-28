//
//  CoreDataFunctions.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 4/27/17.
//  Copyright © 2017 204. All rights reserved.
//

import Foundation
import CoreData

let MyManagedObjectContextSaveDidFailNotification = Notification.Name(rawValue: "MyManagedObjectContextSaveDidFailNotification")

func fatalCoreDataError(_ error: Error) {
    print(" *** Fatal error: \(error)")
    NotificationCenter.default.post(name: MyManagedObjectContextSaveDidFailNotification, object: nil)
}

func saveToCoreData(_ managedObjectContext: NSManagedObjectContext) {
    do {
        try managedObjectContext.save()
    } catch {
        fatalCoreDataError(error)
    }
}
