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

class SearchViewController: UIViewController, UISearchBarDelegate {

    private var searchBar = UISearchBar()
    
    var managedObjectContext: NSManagedObjectContext!
    
    let geocoder = CLGeocoder()
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        setSearchBar()
        navigationItem.hidesBackButton = true
    }
    
    func setSearchBar() {
        self.navigationItem.titleView = searchBar
        searchBar.placeholder = "Enter a address"
        searchBar.showsCancelButton = true
        searchBar.subviews[0].subviews.flatMap(){ $0 as? UITextField }.first?.tintColor = UIColor.black
        searchBar.delegate = self
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationController?.popViewController(animated: true)
    }
    
    func checkLocationSaved(_ beCheckedPlacekmark: CLPlacemark) -> MyLocation? {
        let fetchedRequest = NSFetchRequest<Location>(entityName: "Location")
        var locations = [Location]()
        fetchedRequest.entity = Location.entity()
        do {
            locations = try managedObjectContext.fetch(fetchedRequest)
        } catch {
            fatalCoreDataError(error)
        }

        for locationRecord in locations {
            let placemarkRecord = locationRecord.placemark
            if stringFromPlacemark(placemark: beCheckedPlacekmark) == stringFromPlacemark(placemark: placemarkRecord!) {
                return MyLocation.toMyLocation(coreDataLocation: locationRecord)
            }
        }
        return nil
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        spinner.startAnimating()
        
        let myAddress = searchBar.text!

        geocoder.geocodeAddressString(myAddress, completionHandler: {(placemarks: [CLPlacemark]?, error: Error?) -> Void in
            if error != nil {
                print(error!)
                return
            }
            
            guard let placemarks = placemarks else {
                return
            }
            
            var wantedLocation: MyLocation?
            let tempLocation = MyLocation()

            for place in placemarks {
                guard let location = place.location else {
                    continue
                }

                wantedLocation = self.checkLocationSaved(place)
                
                if wantedLocation == nil {
                    tempLocation.locationName = place.locality!
                    tempLocation.locationCategory = "All"
                    tempLocation.placemark = place
                    tempLocation.latitude = location.coordinate.latitude
                    tempLocation.longitude = location.coordinate.longitude
                }
            }
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            if wantedLocation == nil {
                let controller = storyBoard.instantiateViewController(withIdentifier: "FirstEdit") as! LocationDetailFirstViewController
                controller.locationToSave = tempLocation
                controller.managedObjectContext = self.managedObjectContext
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                let controller = storyBoard.instantiateViewController(withIdentifier: "ShowDetail") as! LocationDetailViewController
                controller.locationToShow = wantedLocation!
                controller.sourceFrom = "SearchCV"
                controller.managedObjectContext = self.managedObjectContext
                self.navigationController?.pushViewController(controller, animated: true)
            }
            self.spinner.stopAnimating()
        })
        searchBar.endEditing(true)
    }

}
