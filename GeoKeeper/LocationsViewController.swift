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

//    
//    lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
//        let fetchRequest = NSFetchRequest<Location>()
//        let entity = Location.entity()
//        fetchRequest.entity = entity
//        let predicate = NSPredicate(format: "category == %@", self.categoryPassed)
//        fetchRequest.predicate = predicate
//        
//        let sortDescriptor1 = NSSortDescriptor(key: "category", ascending: true)
//        let sortDescriptor2 = NSSortDescriptor(key: "date", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
//        fetchRequest.fetchBatchSize = 20
//        
//        let fetchedResultsController = NSFetchedResultsController(
//            fetchRequest: fetchRequest,
//            managedObjectContext: self.managedObjectContext,
//            sectionNameKeyPath: "category",
//            cacheName: "Locations")
//        fetchedResultsController.delegate = self
//        return fetchedResultsController
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        performFetch()
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
    
//    func performFetch() {
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            fatalCoreDataError(error)
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
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
    
//    deinit {
//        fetchedResultsController.delegate = nil
//    }
    
    //MARK: - UITableViewDataSource
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let sectionInfo = fetchedResultsController.sections![section]
//        return sectionInfo.name
//    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let sectionInfo = fetchedResultsController.sections![categoryPassed]
//        return sectionInfo.numberOfObjects
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
//        let location = fetchedResultsController.object(at: indexPath)
//        cell.configure(for: location)
        let location = locations[indexPath.row]
        cell.configure(for: location)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            let location = fetchedResultsController.object(at: indexPath)
            let location = locations[indexPath.row]
            managedObjectContext.delete(location)
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
    
}

//
//extension LocationsViewController: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }
//    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anyObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            tableView.insertRows(at: [newIndexPath!], with: .fade)
//        case .delete:
//            tableView.deleteRows(at: [indexPath!], with: .fade)
//        case .update:
//            print("*** NSFetchedResultsChangeUpdate (object)")
//            if let cell = tableView.cellForRow(at: indexPath!)
//                as? LocationCell {
//                let location = controller.object(at: indexPath!) as! Location
//                cell.configure(for: location)
//            }
//        case .move:
//            print("*** NSFetchedResultsChangeMove (object)")
//            tableView.deleteRows(at: [indexPath!], with: .fade)
//            tableView.insertRows(at: [newIndexPath!], with: .fade)
//        }
//    }
//    
//    func controller(
//        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
//        didChange sectionInfo: NSFetchedResultsSectionInfo,
//        atSectionIndex sectionIndex: Int,
//        for type: NSFetchedResultsChangeType) {
//        switch type {
//        case .insert:
//            tableView.insertSections(IndexSet(integer: sectionIndex),
//                                     with: .fade)
//        case .delete:
//            tableView.deleteSections(IndexSet(integer: sectionIndex),
//                                     with: .fade)
//        case .update:
//            print("*** NSFetchedResultsChangeUpdate (section)")
//        case .move:
//            print("*** NSFetchedResultsChangeMove (section)")
//        }
//    }
//    func controllerDidChangeContent(
//        _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        print("*** controllerDidChangeContent")
//        tableView.endUpdates()
//    }
//
//}
