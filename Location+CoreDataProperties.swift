//
//  Location+CoreDataProperties.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/28/17.
//  Copyright © 2017 204. All rights reserved.
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location");
    }

    @NSManaged public var category: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var latitude: Double
    @NSManaged public var locationDescription: String?
    @NSManaged public var longitude: Double
    @NSManaged public var photoID: Int32
    @NSManaged public var placemark: NSObject?
    @NSManaged public var punch: Int32
    @NSManaged public var name: String?

}
