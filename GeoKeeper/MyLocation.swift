//
//  MyLocation.swift
//  GeoKeeper
//
//  Created by apple on 7/4/2017.
//  Copyright © 2017 204. All rights reserved.
//

import Foundation
import CoreLocation

class MyLocation: NSObject {
    var locationName: String = "Location Name"
    var locationCategory: String = "No Category"
    var date: Date?
    var latitude: Double = 0
    var longitude: Double = 0
    var placemark: CLPlacemark?
    var locationPhotoID: String = "portrait_cat"
    var punch: NSNumber = 0
    var locationDescription: String = "This guy is so lazy that he writes nothing here!"
    
    class func toMyLocation(coreDataLocation: Location) -> MyLocation {
        let location = MyLocation()
        
        location.locationName = coreDataLocation.name!
        location.locationCategory = coreDataLocation.category
        location.date = coreDataLocation.date
        location.latitude = coreDataLocation.latitude
        location.longitude = coreDataLocation.longitude
        location.placemark = coreDataLocation.placemark
        location.locationPhotoID = coreDataLocation.locationPhotoID
        location.punch = coreDataLocation.punch!
        location.locationDescription = coreDataLocation.locationDescription

        return location
    }
}
