//
//  LocationsViewController.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/5/17.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    var categoryPassed = ""
    var locations = [Location]()

    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "TrebuchetMS", size: 16)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "TrebuchetMS", size: 16)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        fetchRequest.entity = Location.entity()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchPredicate = NSPredicate(format: "category == %@", categoryPassed)
        fetchRequest.predicate = fetchPredicate
        
        do {
            let fetchedResults = try managedObjectContext.fetch(fetchRequest)
            for location in fetchedResults {
                locations.append(location as! Location)
            }
        } catch {
            fatalCoreDataError(error)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LocationDetail" {
            let myNavigationController = segue.destination as! MyNavigationController
            let controller = myNavigationController.topViewController as! LocationDetailViewController
            controller.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let location = locations[indexPath.row]
                controller.locationToShow = MyLocation.toMyLocation(coreDataLocation: location)
            }
        }
        
        if segue.identifier == "PickCategoryinCategoryView" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = "No Category"
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        let location = locations[indexPath.row]
        cell.configure(for: location)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let location = locations[indexPath.row]
            managedObjectContext.delete(location)
            locations.remove(at: indexPath.row)
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        
        if let s = placemark.subThoroughfare {
            line1 += s + " "
        }
        
        if let s = placemark.thoroughfare {
            line1 += s
        }
        
        var line2 = ""
        
        if let s = placemark.locality {
            line2 += s + " "
        }
        if let s = placemark.administrativeArea {
            line2 += s + " "
        }
        if let s = placemark.postalCode {
            line2 += s
        }
        
        return line1 + "\n" + line2
    }
}

