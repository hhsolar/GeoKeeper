//
//  CategoryPickerTableViewController.swift
//  GeoKeeper
//
//  Created by apple on 9/4/2017.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit
import CoreData

protocol CategoryPickerTableViewControllerDelegate: class {
    func passCategory(categoryName: String)
}

class CategoryPickerTableViewController: UITableViewController {

    weak var delegate: CategoryPickerTableViewControllerDelegate?
    var managedObjectContext: NSManagedObjectContext!
    
    var categorys = [Category]()
    var categoryChosen = ""
    var chosenIndex = 0
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done() {
        delegate?.passCategory(categoryName: categoryChosen)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CategoryPickerCell.self, forCellReuseIdentifier: "CategoryPickerCell")
        
        let fetchedRequest = NSFetchRequest<Category>(entityName: "Category")
        fetchedRequest.entity = Category.entity()
        do {
            categorys = try managedObjectContext.fetch(fetchedRequest)
        } catch {
            fatalCoreDataError(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryPickerCell", for: indexPath) as! CategoryPickerCell
        let categoryName = categorys[indexPath.row].category
        var isChosen = false
        if categoryName! == categoryChosen {
            isChosen = true
            chosenIndex = indexPath.row
        }
        cell.awakeFromNib()
        cell.configure(name: categoryName!, chosen: isChosen)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cell = tableView.cellForRow(at: indexPath) as! CategoryPickerCell
        cell.toggleChecked()
        categoryChosen = cell.categoryNameLabel.text!
        let chosenIndexPath = NSIndexPath(row: chosenIndex, section: 0)
        cell = tableView.cellForRow(at: chosenIndexPath as IndexPath) as! CategoryPickerCell
        cell.toggleChecked()
        chosenIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
