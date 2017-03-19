//
//  CategoryPickerViewController.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/3/17.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit

class CategoryAddViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var selectedCategoryName = ""
    @IBOutlet weak var addCategory: UITableView!
    
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
        addCategory.delegate = self
        addCategory.dataSource = self
        
        
    }
    
    @IBAction func getBack() {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            if let IndexPath = addCategory.indexPath(for: cell) {
                selectedCategoryName = categories[IndexPath.row]
            }
        }
    }
    
    //Mark: - UITableViewDateSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

extension CategoryAddViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
