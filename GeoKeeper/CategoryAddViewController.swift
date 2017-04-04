//
//  CategoryPickerViewController.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/3/17.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit
import CoreData

class CategoryAddViewController: UIViewController, UITextFieldDelegate {
    var selectedCategoryName = ""
    var managedObjectContext: NSManagedObjectContext!
    var color = "Black"
    var icon = ""
    var temp = 0
    var selectedIconIndexPath: IndexPath!
    
    fileprivate let reuseIdentifier1 = "CategoryColorCell"
    fileprivate let reuseIdentifier2 = "IconCategoryCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 20, left: 10, bottom: 0.0, right: 10)
    fileprivate let itemsPerRow: CGFloat = 7
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet var colorCollection: UICollectionView?
    @IBOutlet var textField: UITextField!
    
    let icons = [
        "Appointments",
        "Birthdays",
        "Chores",
        "Drinks",
        "Folder",
        "Groceries",
        "Inbox",
        "Photos",
        "Trips" ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        doneBarButton.isEnabled = false
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        colorCollection?.addGestureRecognizer(gestureRecognizer)
        selectedIconIndexPath = IndexPath(row: 1, section: 1)
    }

    func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        textField.resignFirstResponder()
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done() {
        saveCategory(name: textField.text!)
        dismiss(animated: true, completion: nil)
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in:range, with: string) as NSString
        if newText.length > 0 {
            doneBarButton.isEnabled = true
        } else {
            doneBarButton.isEnabled = false
        }
        return true
    }
    
    func saveCategory(name: String) {
        let entity = NSEntityDescription.entity(forEntityName: "Category", in: managedObjectContext)!
        let category = NSManagedObject(entity: entity, insertInto: managedObjectContext)
        category.setValue(name, forKey: "category")
        category.setValue(color, forKey: "color")
        category.setValue(icon, forKey: "iconName")
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            fatalCoreDataError(error)
        }
    }
}


extension CategoryAddViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 7
        } else {
            return icons.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier1, for: indexPath) as! MyColorCollectionViewCell
            cell.backgroundColor = UIColor.lightGray
            temp += 1
            cell.colorLabel.text = String(temp)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier2, for: indexPath) as! MyIconCollectionCell
            collectionView.cellForItem(at: selectedIconIndexPath)?.backgroundColor = UIColor.lightGray
            let iconName = icons[indexPath.row]
            cell.iconImage.image = UIImage(named: iconName)
            cell.backgroundColor = UIColor.white
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                color = "red"
            case 1:
                color = "blue"
            case 2:
                color = "purple"
            case 3:
                color = "gray"
            case 4:
                color = "black"
            case 5:
                color = "yellow"
            case 6:
                color = "orange"
            default:
                color = "white"
            }
        } else {
            var indexPaths = [IndexPath]()
            indexPaths.append(indexPath)
            
            if (selectedIconIndexPath != nil) {
                if indexPath != selectedIconIndexPath {
                    indexPaths.append(selectedIconIndexPath)
                    selectedIconIndexPath = indexPath
                }
            }
            
            switch indexPath.row {
            case 0:
                icon = "Appointments"
            case 1:
                icon = "Birthdays"
            case 2:
                icon = "Chores"
            case 3:
                icon = "Drinks"
            case 4:
                icon = "Folder"
            case 5:
                icon = "Groceries"
            case 6:
                icon = "Inbox"
            case 7:
                icon = "Photos"
            case 8:
                icon = "Trips"
            default:
                icon = "Appointments"
           }
            collectionView.reloadItems(at: indexPaths)
            collectionView.cellForItem(at: selectedIconIndexPath)?.backgroundColor = UIColor.lightGray
        }
    }
}


extension CategoryAddViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            return CGSize(width: widthPerItem, height: widthPerItem)
        } else {
            let paddingSpace = sectionInsets.left * 6
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / 5
            return CGSize(width: widthPerItem, height: widthPerItem)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

