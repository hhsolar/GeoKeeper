//
//  CategoryPickerViewController.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/3/17.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit
import CoreData

class CategoryPickerViewController: UITableViewController {
    var selectedCategoryName = ""
    var managedObjectContext: NSManagedObjectContext!
    var selectedIndexPath = IndexPath()
    var categories = [Category]()
    
    let red = UIColor.red
    let blue = UIColor.blue
    let purple = UIColor.purple
    let gray = UIColor.gray
    let yellow = UIColor.yellow
    let orange = UIColor.orange
    let black = UIColor.black
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "category")
        fetchRequest.entity = Category.entity()
        let sortDescriptor = NSSortDescriptor(key: "category", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let fetchedResults = try managedObjectContext.fetch(fetchRequest)
            for category in fetchedResults {
                categories.append(category as! Category)
            }
        } catch {
            fatalCoreDataError(error)
        }
        
        for i in 0..<categories.count {
            if categories[i].category == selectedCategoryName {
                selectedIndexPath = IndexPath(row: i, section: 0)
                break
            }
        }
    }
    
    @IBAction func getBack() {
        dismiss(animated: true, completion: nil)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            if let IndexPath = tableView.indexPath(for: cell) {
                selectedCategoryName = categories[IndexPath.row].category!
            }
        }
    }
    
    //Mark: - UITableViewDateSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let categoryName = categories[indexPath.row].category
        let categoryColor = categories[indexPath.row].color!
        cell.textLabel!.text = categoryName
        
        switch categoryColor {
        case "red":
            cell.textLabel?.textColor = red
        case "blue":
            cell.textLabel?.textColor = blue
        case "purple":
            cell.textLabel?.textColor = purple
        case "gray":
            cell.textLabel?.textColor = gray
        case "black":
            cell.textLabel?.textColor = black
        case "yellow":
            cell.textLabel?.textColor = yellow
        case "orange":
            cell.textLabel?.textColor = orange
        default:
            cell.textLabel?.textColor = black
        }

        if categoryName == selectedCategoryName {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    
    //Mark: - UITableViewDelegate 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != selectedIndexPath.row {
            if let newCell = tableView.cellForRow(at: indexPath) {
                newCell.accessoryType = .checkmark
                
            }
            if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
                oldCell.accessoryType = .none
            }
            selectedIndexPath = indexPath
        }
    }
}
