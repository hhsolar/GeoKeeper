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
    var selectedCategoryName: String = ""
    var selectedColor: String = ""
    var selectedIcon: String = ""
    var selectedIconIndexPath: IndexPath!
    var selectedColorIndexPath: IndexPath!
    
    var managedObjectContext: NSManagedObjectContext!
    var color = "black"
    var icon = ""
    var newItemId: NSNumber!
    var newCellColor: String!
    
    var modeFlag = " "
    
    fileprivate let reuseIdentifier1 = "CategoryColorCell"
    fileprivate let reuseIdentifier2 = "IconCategoryCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 20, left: 10, bottom: 0.0, right: 10)
    fileprivate let itemsPerRow: CGFloat = 7
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet var colorCollection: UICollectionView?
    @IBOutlet var textField: UITextField!
    
    var delegate: ChangeDoneButtonColorDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        textField.text = selectedCategoryName
        doneBarButton.isEnabled = false
        delegate?.changeColorOfButton(Color: UIColor.lightGray)
        
        if modeFlag == "Add" {
            self.title = "Add Category"
        } else {
            self.title = "Edit Category"
        }
       
        color = selectedColor
        icon = selectedIcon
        loadTapGesture()
        
        if let iconIndex = icons.index(of: selectedIcon) {
            selectedIconIndexPath = IndexPath(row: iconIndex, section: 1)
        }
        
        if let colorIndex = colors.index(of: selectedColor) {
            selectedColorIndexPath = IndexPath(row: colorIndex, section: 0)
            newCellColor = colors[colorIndex]
        } else {
            newCellColor = colors[Int(newItemId) % 5]
        }
    }
    
    func loadTapGesture() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        colorCollection?.addGestureRecognizer(gestureRecognizer)
    }

    func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        textField.resignFirstResponder()
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done() {
        if modeFlag == "Add" {
            let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
            fetchRequest.entity = Category.entity()
            fetchRequest.predicate = NSPredicate(format: "category == %@", textField.text!)
            
            do {
                let count = try managedObjectContext.count(for: fetchRequest)
                if count == 0 {
                    finishAddCategory(name: textField.text!)
                    dismiss(animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Reminder", message: "Category Name Already Exist!!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } catch {
                fatalCoreDataError(error)
            }
        }
        
        if modeFlag == "Edit"{
            let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
            fetchRequest.entity = Category.entity()
            fetchRequest.predicate = NSPredicate(format: "id == %@", newItemId)
            do {
                let categoryToEdits = try managedObjectContext.fetch(fetchRequest)
                for categoryToEdit in categoryToEdits {
                    categoryToEdit.category = textField.text!
                    categoryToEdit.color = color
                    categoryToEdit.id = newItemId
                    categoryToEdit.iconName = icon
                }
            } catch {
                fatalCoreDataError(error)
            }
            saveToCoreData(managedObjectContext)
            dismiss(animated: true, completion: nil)
        }
    }
    
    func finishAddCategory(name: String) {
        let entity = NSEntityDescription.entity(forEntityName: "Category", in: managedObjectContext)!
        let category = NSManagedObject(entity: entity, insertInto: managedObjectContext)
        category.setValue(newItemId, forKey: "id")
        category.setValue(name, forKey: "category")
        category.setValue(icon, forKey: "iconName")
        category.setValue(newCellColor, forKey: "color")
        saveToCoreData(managedObjectContext)
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
            cell.colorImageView.image = UIImage(named: colors[indexPath.row] + "_unchecked")
            
            if selectedColorIndexPath != nil {
                if selectedColorIndexPath == indexPath {
                    cell.colorImageView.image = UIImage(named: colors[indexPath.row] + "_checked")
                }
            }
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier2, for: indexPath) as! MyIconCollectionCell
            let iconName = icons[indexPath.row]
            cell.iconImage.image = UIImage(named: iconName)
            cell.backgroundColor = UIColor.white
            if selectedIconIndexPath != nil {
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
            newCellColor = colors[selectedColorIndexPath.row]
            collectionView.reloadItems(at: indexPaths)
            let colorCell = collectionView.cellForItem(at: selectedColorIndexPath) as! ColorCell
            colorCell.colorImageView.image = UIImage(named: colors[indexPath.row] + "_checked")
        }
        
        if indexPath.section == 1 {
            if (selectedIconIndexPath != nil) {
                if indexPath != selectedIconIndexPath {
                    indexPaths.append(selectedIconIndexPath)
                    selectedIconIndexPath = indexPath
                }
            } else {
                selectedIconIndexPath = indexPath
            }
            icon = icons[selectedIconIndexPath.row]
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
