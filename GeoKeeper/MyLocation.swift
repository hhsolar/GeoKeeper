//
//  MyLocation.swift
//  GeoKeeper
//
//  Created by apple on 7/4/2017.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class MyLocation: NSObject {
    var locationName: String = "Location Name"
    var locationCategory: String = "All"
    var date: Date?
    var latitude: Double = 0
    var longitude: Double = 0
    var placemark: CLPlacemark?
    var locationPhotoID: NSNumber?
    var photoID: [NSNumber]?
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
        location.photoID = coreDataLocation.photoID
        location.punch = coreDataLocation.punch!
        location.locationDescription = coreDataLocation.locationDescription

        return location
    }
    
    var hasPhoto: Bool {
        return locationPhotoID != nil
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path)
    }
    
    var photoURL: URL {
        let filename = "Photo-\(locationPhotoID!.intValue).jpg"
        return applicationDocumentsDirectory.appendingPathComponent(filename)
    }
    
    var getAddress: String {
        var add = ""
        
        if let s = placemark?.subThoroughfare {
            add += s
        }
        
        if let s = placemark?.thoroughfare {
            add += s
        }
        
        if let s = placemark?.locality {
            add += s
        }
        
        if let s = placemark?.administrativeArea {
            add += s
        }
        
        if let s = placemark?.postalCode {
            add += s
        }        
        return add
    }
    
    func photoImages(photoIndex: Int) -> UIImage? {
        let URL = photosURL(photoIndex: photoIndex)
        return UIImage(contentsOfFile: URL.path)
    }
    
    func photosURL(photoIndex: Int) -> URL {
        let filename = "Photo-\(getAddress)-\(photoIndex).jpg"
        return applicationDocumentsDirectory.appendingPathComponent(filename)
    }
    
}
