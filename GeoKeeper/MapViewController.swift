//
//  MapViewController.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/7/17.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension MapViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

