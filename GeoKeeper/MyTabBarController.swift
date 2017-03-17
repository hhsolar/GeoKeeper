//
//  MyTabBarController.swift
//  GeoKeeper
//
//  Created by apple on 13/3/2017.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {
    
    let unselectedColor = UIColor.lightGray
    let selectedColor = UIColor.white
    let tabBarColor = UIColor(red: 71/255.0, green: 117/255.0, blue: 179/255.0, alpha: 1.0)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // unselectedColor state colors
        self.tabBar.unselectedItemTintColor = unselectedColor
       
        // selectedColor state colors
        self.tabBar.tintColor = selectedColor
        
        self.tabBar.barTintColor = tabBarColor
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return nil
    }
}
