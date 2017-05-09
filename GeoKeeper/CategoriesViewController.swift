//
//  CategoriesViewController.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/18/17.
//  Copyright © 2017 204. All rights reserved.
//
import UIKit
import CoreData

class CategoriesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate {
    
    fileprivate let reuseIdentifier1 = "CategoryCell"
    fileprivate let reuseIdentifier2 = "AllCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 1.0, left: 4.0, bottom: 1.0, right: 2.0)
    fileprivate let itemsPerRow: CGFloat = 3
    var managedObjectContext: NSManagedObjectContext!
    var blockOperations: [BlockOperation] = []
    var category : Category!
    var p : CGPoint!
    var modeFlag: String = "Add"
    var totalItem = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Category> = {
        let fetchRequest = NSFetchRequest<Category>()
        let entity = Category.entity()
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
//            cacheName: "Categories")
            cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    

    
    override func viewDidLoad() {
         super.viewDidLoad()
         performFetch()
         loadGesture()
         //Remove the top margin, which is related with the collectionView's content margin
         self.automaticallyAdjustsScrollViewInsets = false
    }

    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    func loadGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture))
        collectionView.addGestureRecognizer(longPressGesture)
        longPressGesture.minimumPressDuration = 0.5
        // Retain press event
        longPressGesture.cancelsTouchesInView = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        collectionView.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        UserDefaults.standard.set("No", forKey: "LongPressed")
        UserDefaults.standard.set("No", forKey: "SingleTap")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let navController = segue.destination as! UINavigationController
            let controller = navController.viewControllers[0] as! CategoryAddViewController
            controller.managedObjectContext = managedObjectContext
            if modeFlag == "Add" {
                controller.modeFlag = modeFlag
                controller.selectedCategoryName = "No Category"
                controller.newItemId = fetchedResultsController.sections![0].numberOfObjects as NSNumber!
            } else if modeFlag == "Edit" {
                controller.modeFlag = modeFlag
                modeFlag = "Add"
                let indexPath = collectionView.indexPathForItem(at: p)
                let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
                fetchRequest.entity = Category.entity()
                fetchRequest.predicate = NSPredicate(format: "id == %@", indexPath!.row as NSNumber!)
                do {
                    let categoryToEdits = try managedObjectContext.fetch(fetchRequest)
                    
                    for categoryToEdit in categoryToEdits {
                        controller.selectedCategoryName = categoryToEdit.category!
                        controller.selectedColor = categoryToEdit.color!
                        controller.selectedIcon = categoryToEdit.iconName!
                        controller.newItemId = categoryToEdit.id
                    }
                } catch {
                    fatalCoreDataError(error)
                }
            }
        }
        
        if segue.identifier == "CategoryDetails" {
            let controller = segue.destination as! LocationsViewController
            if let indexPath = collectionView.indexPath(for: sender as! UICollectionViewCell) {
                controller.categoryPassed = fetchedResultsController.object(at: indexPath).category!
            }
            controller.managedObjectContext = managedObjectContext
        }
        
        if segue.identifier == "AllLocations" {
            let controller = segue.destination as! AllLocationsViewController
            controller.managedObjectContext = managedObjectContext
        }
    }
    
    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        UserDefaults.standard.set("Yes", forKey: "LongPressed")
        switch(gesture.state) {
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                break
            }
            p = gesture.location(in: collectionView)
            //async is necessary
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
   
    func handleTap(gesture: UITapGestureRecognizer) {
        UserDefaults.standard.set("Yes", forKey: "SingleTap")
        if gesture.state != UIGestureRecognizerState.ended {
            return
        }
        p = gesture.location(in: collectionView)
        let indexPath = collectionView.indexPathForItem(at: p)
        if indexPath == nil {
            UserDefaults.standard.set("No", forKey: "LongPressed")
            collectionView.reloadData()
        } else if UserDefaults.standard.value(forKey:"LongPressed") as! String == "No" {
            if (collectionView.cellForItem(at: indexPath!) is AllCell) {
                performSegue(withIdentifier: "AllLocations", sender: collectionView.cellForItem(at: indexPath!))
            } else {
                performSegue(withIdentifier: "CategoryDetails", sender: collectionView.cellForItem(at: indexPath!))
            }
        } else if UserDefaults.standard.value(forKey: "LongPressed") as! String == "Yes" {
            modeFlag = "Edit"
            performSegue(withIdentifier: "PickCategory", sender: collectionView.cellForItem(at: indexPath!))
        }
    }
    
    //Move the Position of Collection View Cell
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let category = fetchedResultsController.object(at: sourceIndexPath as IndexPath)
        category.setValue(destinationIndexPath.row, forKey: "id")
        adjustLocationID(startFrom: sourceIndexPath, to: destinationIndexPath)
    }
    
    func adjustLocationID(startFrom sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if (sourceIndexPath.row > destinationIndexPath.row) {
            for id in destinationIndexPath.row..<sourceIndexPath.row {
                let indexPath = IndexPath(row: id, section: 0)
                let category = fetchedResultsController.object(at: indexPath)
                category.setValue((id + 1) as NSNumber, forKey: "id")
            }
        }
        else
        {
            for id in sourceIndexPath.row + 1...destinationIndexPath.row
            {
                let indexPath = IndexPath(row: id, section: 0)
                let category = fetchedResultsController.object(at: indexPath)
                category.setValue((id - 1) as NSNumber, forKey: "id")
            }
        }
        saveToCoreData(managedObjectContext)
    }
    
    
    //MARK: - Feteched Result Controller Delegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertItems(at: [newIndexPath!])
                    }
                })
            )
        case .update:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadItems(at: [indexPath!])
                    }
                })
            )
//        case .move:
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.moveItem(at: indexPath!, to: newIndexPath!)
//                    }
//                })
//            )
        case .delete:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteItems(at: [indexPath!])
                    }
                })
            )
        default:
            print("Re write the move function, so default should be called when move is applied")
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        case .update:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        case .delete:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        default:
            print("This case will never be executed")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView!.performBatchUpdates({ () -> Void in
            for operation: BlockOperation in self.blockOperations {
                operation.start()
            }
        }, completion: { (finished) -> Void in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }
    
    deinit {
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        blockOperations.removeAll(keepingCapacity: false)
    }
}

//MARK: - CollectionView Datasource
extension CategoriesViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let fetchedRequest = NSFetchRequest<Location>(entityName: "Location")
        fetchedRequest.entity = Location.entity()
        do {
            totalItem = try managedObjectContext.count(for: fetchedRequest)
        } catch {
            fatalCoreDataError(error)
        }
        category = fetchedResultsController.object(at: indexPath)
        fetchedRequest.predicate = NSPredicate(format: "category == %@", category.category!)
        var countItems = 0
        do {
            countItems = try managedObjectContext.count(for: fetchedRequest)
        } catch {
            fatalCoreDataError(error)
        }
        
        
        if category.category! == "All" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier2, for: indexPath) as! AllCell
            cell.awakeFromNib()
            cell.categoryLabel?.text = "All (" + (String)(totalItem) + ")"
            if category.iconName != nil {
                cell.categoryImageView?.image = UIImage(named: category.iconName!)
            }
            switch category.color! {
            case "brown":
                cell.backgroundColor = brown
            case "darkgreen":
                cell.backgroundColor = darkgreen
            case "darkpurple":
                cell.backgroundColor = darkpurple
            case "green":
                cell.backgroundColor = green
            case "purple":
                cell.backgroundColor = purple
            case "pink":
                cell.backgroundColor = pink
            case "yellow":
                cell.backgroundColor = yellow
            default:
                cell.backgroundColor = pink
            }
            if UserDefaults.standard.value(forKey: "LongPressed") as! String == "Yes" {
                let anim = CABasicAnimation(keyPath: "transform.rotation")
                anim.toValue = 0.0
                anim.fromValue =  Double.pi / 64
                anim.duration = 0.1
                anim.repeatCount = Float(UInt.max)
                anim.autoreverses = true
                cell.layer.shouldRasterize = true
                cell.layer.add(anim, forKey: "SpringboardShake")
            } else if UserDefaults.standard.value(forKey: "SingleTap") as! String == "Yes" {
                cell.layer.removeAllAnimations()
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier1, for: indexPath) as! CategoryCell
            //        cell.categoryImageView = UIImageView(frame: CGRect(x: width / 2, y: 3, width: width / 2, height: width / 2))
            //        为何加了这一句，就看不到图片呀！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
            cell.awakeFromNib()
            cell.categoryLabel?.text = category.category! + " (" + (String)(countItems) + ")"
            switch category.color! {
            case "brown":
                cell.backgroundColor = brown
            case "darkgreen":
                cell.backgroundColor = darkgreen
            case "darkpurple":
                cell.backgroundColor = darkpurple
            case "green":
                cell.backgroundColor = green
            case "purple":
                cell.backgroundColor = purple
            case "pink":
                cell.backgroundColor = pink
            case "yellow":
                cell.backgroundColor = yellow
            default:
                cell.backgroundColor = pink
            }
            if category.iconName != nil {
                cell.categoryImageView?.image = UIImage(named: category.iconName!)
            }
            if UserDefaults.standard.value(forKey: "LongPressed") as! String == "Yes" {
                let anim = CABasicAnimation(keyPath: "transform.rotation")
                anim.toValue = 0.0
                anim.fromValue =  Double.pi / 64
                anim.duration = 0.1
                anim.repeatCount = Float(UInt.max)
                anim.autoreverses = true
                cell.layer.shouldRasterize = true
                cell.layer.add(anim, forKey: "SpringboardShake")
                
                //                let pat = "^All \\(\\d+\\)$"
                //                let regex = try! NSRegularExpression(pattern: pat, options: [])
                //                let matches = regex.matches(in: cell.categoryLabel.text!, options: [], range:NSRange(location: 0, length: (cell.categoryLabel.text?.characters.count)!))
                
                let deleteButton = UIButton(frame: CGRect(x: (cell.contentView.frame.origin.x + 5), y: (cell.contentView.frame.origin.y + 5), width: 20, height: 20))
                let backgroundImage = UIImage(named: "deleteButton_Orange") as UIImage?
                deleteButton.addTarget(self, action: #selector(deleteCategoryAlert), for: .touchUpInside)
                deleteButton.setImage(backgroundImage, for: .normal)
                cell.addSubview(deleteButton)
            } else if UserDefaults.standard.value(forKey: "SingleTap") as! String == "Yes" {
                cell.layer.removeAllAnimations()
                let subViews = cell.subviews
                for subView in subViews {
                    if subView is UIButton {
                        subView.removeFromSuperview()
                    }
                }
            }
            return cell
        }
    }
    
    func deleteCategoryAlert() {
        let alert = UIAlertController(title: "Please Confirm", message: "If you remove this category, all the data inside will be deleted!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in print("Cancel is pressed")}))
        alert.addAction(UIAlertAction(title: "Done",  style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in self.handleCategoryDeletion()}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleCategoryDeletion() {
        let category = deleteCategory()
        deletedLocationsOfCategory(category)
    }
    
    func deleteCategory() -> String {
        var deletedCategory = ""
        if let id = collectionView.indexPathForItem(at: p) {
            let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
            fetchRequest.entity = Category.entity()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id.row as NSNumber)
            
            do{
                let toBeDeleteds = try managedObjectContext.fetch(fetchRequest)
                for toBeDeleted in toBeDeleteds {
                    deletedCategory = toBeDeleted.category!
                    managedObjectContext.delete(toBeDeleted)
                }
            } catch {
                fatalCoreDataError(error)
            }
            let end = fetchedResultsController.sections![0].numberOfObjects
            for i in id.row + 1..<end {
                let indexPath = IndexPath(row: i, section: 0)
                let category = fetchedResultsController.object(at: indexPath)
                category.setValue((i - 1) as NSNumber, forKey: "id")
            }
        }
        saveToCoreData(managedObjectContext)
        return deletedCategory
    }
    
    func deletedLocationsOfCategory(_ deletedCategory: String) {
        let fetchRequest1 = NSFetchRequest<Location>(entityName: "Location")
        fetchRequest1.entity = Location.entity()
        fetchRequest1.predicate = NSPredicate(format: "category == %@", deletedCategory)
        do {
            let toBeDeletedLocations = try managedObjectContext.fetch(fetchRequest1)
            for toBeDeletedLocation in toBeDeletedLocations {
                if toBeDeletedLocation.hasPhoto {
                    toBeDeletedLocation.removePhotoFile()
                }
                
                if let photoID = toBeDeletedLocation.photoID {
                    for id in photoID {
                        toBeDeletedLocation.removePhotoFile(photoIndex: id)
                    }
                }
                managedObjectContext.delete(toBeDeletedLocation)
            }
        } catch {
            fatalCoreDataError(error)
        }
        saveToCoreData(managedObjectContext)
    }
}

//MARK: - CollectionView FlowLayout
extension CategoriesViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    
    // Top blank is include the content margin and header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: 15)
    }
}
