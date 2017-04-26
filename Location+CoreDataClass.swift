//
//  Location+CoreDataClass.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/5/17.
//  Copyright © 2017 204. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Location: NSManagedObject, MKAnnotation {
    
    var hasPhoto: Bool {
        return locationPhotoID != nil
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path)
    }
    
    var photoURL: URL {
        assert(locationPhotoID != nil, "No location photo ID set")
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
    
    func photosURL(photoIndex: NSNumber) -> URL {
        let filename = "Photo-\(getAddress)-\(photoIndex.intValue).jpg"
        return applicationDocumentsDirectory.appendingPathComponent(filename)
    }
 
    func nextPhotoID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "\(getAddress)")
        userDefaults.set(currentID + 1, forKey:"\(getAddress)")
        userDefaults.synchronize()
        return currentID
    }
    
    class func nextLocationPhotoID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "locationPhotoID")
        userDefaults.set(currentID + 1, forKey: "locationPhotoID")
        userDefaults.synchronize()
        return currentID
    }
    
    func removePhotoFile(photoIndex: NSNumber) {
        if (photoID?.contains(photoIndex))! {
            do {
                try FileManager.default.removeItem(at: photosURL(photoIndex: photoIndex))
            } catch {
                print("Error removing file: \(error)")
            }
        }
    }
    
    func removePhotoFile() {
        if hasPhoto {
            do {
                try FileManager.default.removeItem(at: photoURL)
            } catch {
                print("Error removing file: \(error)")
            }
        }
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    var title: String? {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    
    var subtitle: String? {
        return category
    }
        
}



