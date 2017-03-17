//
//  AllCategoryViewController.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/13/17.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit
import CoreData

class AllCategoryViewController: UITableViewController, UINavigationControllerDelegate {
    var managedObjectContext: NSManagedObjectContext!
    var categorySet = NSMutableOrderedSet()
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let entity = Category.entity()
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "category", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let categories = try managedObjectContext.fetch(fetchRequest)
            for category in categories {
                categorySet.add((category as! Category).value(forKey: "category")!)
            }
        }catch {
                fatalCoreDataError(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorySet.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categorySet.object(at: indexPath.row) as! String
        let categoryLabel = cell.viewWithTag(200) as! UILabel
        categoryLabel.text = category
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            let entityDescription = NSEntityDescription.entity(forEntityName: "Category", in: self.managedObjectContext)
            fetchRequest.entity = entityDescription
            let fetchPredicate = NSPredicate(format: "category == %@", categorySet.object(at: indexPath.row) as! String)
            categorySet.removeObject(at: indexPath.row)
            fetchRequest.predicate = fetchPredicate
            let sortDescriptor = NSSortDescriptor(key: "category", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            do {
                let fetchedRequests = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
                for fetchedRequest in fetchedRequests {
                    managedObjectContext.delete(fetchedRequest)
                    try managedObjectContext.save()
                }
            }  catch {
            fatalCoreDataError(error)
            }
        }
        tableView.reloadData()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryAddViewController
            controller.selectedCategoryName = "No Category"
        }
        
        
        if segue.identifier == "CategoryDetails" {
            let controller = segue.destination as! LocationsViewController
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
            let row = indexPath?.row
            controller.managedObjectContext = managedObjectContext
            controller.categoryPassed = categorySet.object(at:row!) as! String
        }
    }
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryAddViewController
        categorySet.add(controller.selectedCategoryName)
        save(name: controller.selectedCategoryName)
        tableView.reloadData()
    }
    
    func save(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Category", in: managedContext)!
        let category = NSManagedObject(entity: entity, insertInto: managedContext)
        category.setValue(name, forKey: "category")
        do {
            try managedContext.save()
        } catch let error as NSError {
            fatalCoreDataError(error)
        }
    }
}
