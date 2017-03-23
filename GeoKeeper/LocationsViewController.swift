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

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        
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
                controller.locationToEdit = location
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
}

