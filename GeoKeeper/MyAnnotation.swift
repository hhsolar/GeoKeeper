//
//  MyAnnotation.swift
//  GeoKeeper
//
//  Created by apple on 30/5/2017.
//  Copyright © 2017 204. All rights reserved.
//

import MapKit

class MyAnnotation: NSObject, MKAnnotation {

    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title:String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
