//
//  Category+CoreDataProperties.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/22/17.
//  Copyright © 2017 204. All rights reserved.
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category");
    }

    @NSManaged public var category: String?
    @NSManaged public var color: String?
    @NSManaged public var iconName: String?
    @NSManaged public var id: NSNumber?

}
