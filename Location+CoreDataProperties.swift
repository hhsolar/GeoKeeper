//
//  Location+CoreDataProperties.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/28/17.
//  Copyright © 2017 204. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location");
    }

    @NSManaged public var category: String
    @NSManaged public var date: Date
    @NSManaged public var latitude: Double
    @NSManaged public var locationDescription: String
    @NSManaged public var longitude: Double
    @NSManaged public var photoID: [NSNumber]?
    @NSManaged public var locationPhotoID: NSNumber?
    @NSManaged public var placemark: CLPlacemark?
    
    @NSManaged public var punch: NSNumber?
    @NSManaged public var name: String?

}
