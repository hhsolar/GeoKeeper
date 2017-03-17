//
//  CategoryPickerViewController.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/3/17.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit

class CategoryAddViewController: UITableViewController {
    var selectedCategoryName = ""
    
    let categories = [
        "No Category",
        "Friend's Home",
        "Ski Resort",
        "Restaurant",
        "Club",
        "Store",
        "Landmark",
        "Park"]
    var selectedIndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func getBack() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            if let IndexPath = tableView.indexPath(for: cell) {
                selectedCategoryName = categories[IndexPath.row]
            }
        }
    }
    
    //Mark: - UITableViewDateSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName
        if categoryName == selectedCategoryName {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
}
