//
//  CategoryPickerViewController.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/3/17.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit
import CoreData

protocol ChangeDoneButtonColorDelegate {
    func changeColorOfButton(Color: UIColor)
}

class CategoryAddViewController: UIViewController, UITextFieldDelegate {
    var selectedCategoryName = ""
    var managedObjectContext: NSManagedObjectContext!
    var color = "black"
    var icon = ""
    var selectedIconIndexPath: IndexPath!
    var selectedColorIndexPath: IndexPath!
    var newItemId: NSNumber!
    var selectedColor: String = ""
    var selectedIcon: String = ""
    var modeFlag = " "
    var newCellColor: String!
    
    fileprivate let reuseIdentifier1 = "CategoryColorCell"
    fileprivate let reuseIdentifier2 = "IconCategoryCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 20, left: 10, bottom: 0.0, right: 10)
    fileprivate let itemsPerRow: CGFloat = 7
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet var colorCollection: UICollectionView?
    @IBOutlet var textField: UITextField!
    
    var delegate: ChangeDoneButtonColorDelegate? = nil
    
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
    
    let colors = [
        "red",
        "blue",
        "purple",
        "green",
        "yellow",
        "orange",
        "cyan"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        textField.text = selectedCategoryName
        doneBarButton.isEnabled = false
        delegate?.changeColorOfButton(Color: UIColor.lightGray)
       
        color = selectedColor
        icon = selectedIcon
        
        switch Int(newItemId) % 5 {
        case 0:
            newCellColor = "baseColor0"
        case 1:
            newCellColor = "baseColor1"
        case 2:
            newCellColor = "baseColor2"
        case 3:
            newCellColor = "baseColor3"
        case 4:
            newCellColor = "baseColor4"
        default:
            newCellColor = "baseColor0"
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        colorCollection?.addGestureRecognizer(gestureRecognizer)
        print("!!!!!", selectedIcon)
        print("selectedIcon in viewdidload is",selectedIcon)
        if let iconIndex = icons.index(of: selectedIcon) {
            print("iconindex is", iconIndex)
            selectedIconIndexPath = IndexPath(row: iconIndex, section: 1)
        }
        
        if let colorIndex = colors.index(of: selectedColor) {
            print("iconcolor is", colorIndex)
            selectedColorIndexPath = IndexPath(row: colorIndex, section: 0)
        }
        print("selectedColor is",selectedIcon,selectedColor)
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
            delegate?.changeColorOfButton(Color: UIColor.white)
        } else {
            doneBarButton.isEnabled = false
            delegate?.changeColorOfButton(Color: UIColor.lightGray)
        }
        return true
    }
    
    func saveCategory(name: String) {
        let entity = NSEntityDescription.entity(forEntityName: "Category", in: managedObjectContext)!
        if modeFlag == "Add" {
            let category = NSManagedObject(entity: entity, insertInto: managedObjectContext)
            category.setValue(name, forKey: "category")
            category.setValue(color, forKey: "color")
            category.setValue(icon, forKey: "iconName")
            category.setValue(newItemId, forKey: "id")
            category.setValue(newCellColor, forKey: "cellColor")
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                fatalCoreDataError(error)
            }
        } else if modeFlag == "Edit" {
            let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
            fetchRequest.entity = Category.entity()
            fetchRequest.predicate = NSPredicate(format: "id == %@", newItemId)
            do {
                let categoryToEdits = try managedObjectContext.fetch(fetchRequest)
                for categoryToEdit in categoryToEdits {
                    categoryToEdit.category = name
                    categoryToEdit.color = color
                    categoryToEdit.id = newItemId
                    print("category name is going to save",icon)
                    categoryToEdit.iconName = icon
                }
            } catch {
                fatalCoreDataError(error)
            }
            
            print("color going to save is ", color)
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }

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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier1, for: indexPath) as! ColorCell
            cell.backgroundColor = UIColor.white
            switch indexPath.row {
            case 0:
                cell.colorImageView.image = UIImage(named: "red_unchoose")
            case 1:
                cell.colorImageView.image = UIImage(named: "blue_unchoose")
            case 2:
                cell.colorImageView.image = UIImage(named: "purple_unchoose")
            case 3:
                cell.colorImageView.image = UIImage(named: "green_unchoose")
            case 4:
                cell.colorImageView.image = UIImage(named: "yellow_unchoose")
            case 5:
                cell.colorImageView.image = UIImage(named: "orange_unchoose")
            case 6:
                cell.colorImageView.image = UIImage(named: "cyan_unchoose")
            default:
                print("This should not be called")
            }
            
            if selectedColorIndexPath != nil {
                if selectedColorIndexPath == indexPath {
                    switch indexPath.row {
                    case 0:
                        cell.colorImageView.image = UIImage(named: "red_choose")
                    case 1:
                        cell.colorImageView.image = UIImage(named: "blue_choose")
                    case 2:
                        cell.colorImageView.image = UIImage(named: "purple_choose")
                    case 3:
                        cell.colorImageView.image = UIImage(named: "green_choose")
                    case 4:
                        cell.colorImageView.image = UIImage(named: "yellow_choose")
                    case 5:
                        cell.colorImageView.image = UIImage(named: "orange_choose")
                    case 6:
                        cell.colorImageView.image = UIImage(named: "cyan_choose")
                    default:
                        print("This should not be called")
                    }
                }
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier2, for: indexPath) as! MyIconCollectionCell
            let iconName = icons[indexPath.row]
            cell.iconImage.image = UIImage(named: iconName)
            cell.backgroundColor = UIColor.white
            if selectedIconIndexPath != nil {
                print(selectedIconIndexPath.row,"is selectedIconIndexPath")
               if selectedIconIndexPath == indexPath {
                    cell.backgroundColor = UIColor.lightGray
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var indexPaths = [IndexPath]()
        indexPaths.append(indexPath)
        if indexPath.section == 0 {
            if (selectedColorIndexPath != nil) {
                if indexPath != selectedColorIndexPath {
                    indexPaths.append(selectedColorIndexPath)
                    selectedColorIndexPath = indexPath
                }
            } else {
                selectedColorIndexPath = indexPath
            }
            
            switch indexPath.row {
            case 0:
                color = "red"
            case 1:
                color = "blue"
            case 2:
                color = "purple"
            case 3:
                color = "green"
            case 4:
                color = "yellow"
            case 5:
                color = "orange"
            case 6:
                color = "cyan"
            default:
                color = "black"
            }
            collectionView.reloadItems(at: indexPaths)
            let colorCell = collectionView.cellForItem(at: selectedColorIndexPath) as! ColorCell
            colorCell.colorImageView.image = UIImage(named: color+"_choose")
        } else {
            if (selectedIconIndexPath != nil) {
                if indexPath != selectedIconIndexPath {
                    indexPaths.append(selectedIconIndexPath)
                    selectedIconIndexPath = indexPath
                }
            } else {
                selectedIconIndexPath = indexPath
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
        doneBarButton.isEnabled = true
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



