//
//  SearchViewController.swift
//  GeoKeeper
//
//  Created by apple on 13/6/2017.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

protocol SearchViewControllerDelegate {
    func passLocationBack(location: MyLocation)
}

class SearchViewController: UIViewController, UISearchBarDelegate {

    private var searchBar = UISearchBar()
    
    var managedObjectContext: NSManagedObjectContext!
    
    let geocoder = CLGeocoder()
    var wantedLocation = MyLocation()
    
    var delegate: SearchViewControllerDelegate?
    
    override func viewDidLoad() {
         setSearchBar()
    }
    
    func setSearchBar() {
        self.navigationItem.titleView = searchBar

        searchBar.becomeFirstResponder()
        searchBar.placeholder = "Enter a address"
        searchBar.showsCancelButton = true
        searchBar.subviews[0].subviews.flatMap(){ $0 as? UITextField }.first?.tintColor = UIColor.black
        searchBar.delegate = self
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let myAddress = searchBar.text!
//        geocoder.geocodeAddressString(myAddress, completionHandler: {(placemarks: [CLPlacemark]?, error: Error?) -> Void in
//            if error != nil {
//                print(error!)
//                return
//            }
//            
//            guard let placemarks = placemarks else {
//                return
//            }
//            
//            for place in placemarks {
//                print(place.name!)
//                
//                guard let location = place.location else {
//                    continue
//                }
//                
//                self.wantedLocation.latitude = location.coordinate.latitude
//                self.wantedLocation.longitude = location.coordinate.longitude
//                self.wantedLocation.locationName = place.locality!
//                self.wantedLocation.placemark = place
//                self.wantedLocation.date = location.timestamp
//            }
//        })
//        searchBar.endEditing(true)
//        delegate?.passLocationBack(location: wantedLocation)
//        dismiss(animated: true, completion: nil)
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        searchBar.endEditing(true)
//    }


}
