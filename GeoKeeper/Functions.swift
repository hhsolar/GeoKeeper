//
//  Functions.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/5/17.
//  Copyright © 2017 204. All rights reserved.
//

import Foundation
import Dispatch
import UIKit

let MyManagedObjectContextSaveDidFailNotification = Notification.Name(rawValue: "MyManagedObjectContextSaveDidFailNotification")

func fatalCoreDataError(_ error: Error) {
    print(" *** Fatal error: \(error)")
    NotificationCenter.default.post(name: MyManagedObjectContextSaveDidFailNotification, object: nil)
}


func afterDelay(seconds: Double, closure: @escaping () -> ()) {
    let when = DispatchTime.now() + seconds
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()

//func chooseColor(indexPathRow: Int) {
//    
//}

var portraitPhotoURL: URL {
    let filename = "MyPortrait.jpg"
    return applicationDocumentsDirectory.appendingPathComponent(filename)
}


var portraitPhotoImage: UIImage? {
    return UIImage(contentsOfFile: portraitPhotoURL.path)
}

