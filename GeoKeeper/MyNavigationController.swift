//
//  MyNavigationController.swift
//  GeoKeeper
//
//  Created by apple on 13/3/2017.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit

class MyNavigationController: UINavigationController {
    
    let baseColor = UIColor(red: 71/255.0, green: 117/255.0, blue: 179/255.0, alpha: 1.0)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationBar.barTintColor = baseColor
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
