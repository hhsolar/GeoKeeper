//
//  Category+CoreDataProperties.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/15/17.
//  Copyright © 2017 204. All rights reserved.
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category");
    }

    @NSManaged public var category: String?

}
