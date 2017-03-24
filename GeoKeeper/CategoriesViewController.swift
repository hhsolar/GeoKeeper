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
    fileprivate let reuseIdentifier = "CategoryCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    fileprivate let itemsPerRow: CGFloat = 3
    var managedObjectContext: NSManagedObjectContext!
    var blockOperations: [BlockOperation] = []
    
//    var categories = [String]()
    
    let baseColor1 = UIColor(red: 210/255.0, green: 246/255.0, blue: 244/255.0, alpha: 1.0)
    let baseColor2 = UIColor(red: 251/255.0, green: 246/255.0, blue: 240/255.0, alpha: 1.0)
    let baseColor3 = UIColor(red: 251/255.0, green: 240/255.0, blue: 244/255.0, alpha: 1.0)
    let baseColor4 = UIColor(red: 230/255.0, green: 221/255.0, blue: 244/255.0, alpha: 1.0)
    let baseColor5 = UIColor(red: 251/255.0, green: 246/255.0, blue: 213/255.0, alpha: 1.0)
    
    let red = UIColor.red
    let blue = UIColor.blue
    let purple = UIColor.purple
    let gray = UIColor.gray
    let yellow = UIColor.yellow
    let orange = UIColor.orange
    let black = UIColor.black

    let icons = [
        "No Icon",
        "Appointments",
        "Birthdays",
        "Chores",
        "Drinks",
        "Folder",
        "Groceries",
        "Inbox",
        "Photos",
        "Trips" ]
    
    @IBOutlet weak var collectionView: UICollectionView!


    lazy var fetchedResultsController: NSFetchedResultsController<Category> = {
        let fetchRequest = NSFetchRequest<Category>()
        let entity = Category.entity()
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "category", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: "Categories")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
         super.viewDidLoad()
         performFetch()
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let navController = segue.destination as! UINavigationController
            let controller = navController.viewControllers[0] as! CategoryAddViewController
            controller.selectedCategoryName = "No Category"
            controller.managedObjectContext = managedObjectContext
        }
        
        if segue.identifier == "CategoryDetails" {
            let controller = segue.destination as! LocationsViewController
            if let indexPath = collectionView.indexPath(for: sender as! UICollectionViewCell) {
                print("CategoryDetails is called")
                controller.categoryPassed = fetchedResultsController.object(at: indexPath).category!
            }
            controller.managedObjectContext = managedObjectContext
        }
    }
    
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
        case .move:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.moveItem(at: indexPath!, to: newIndexPath!)
                    }
                })
            )
        case .delete:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteItems(at: [indexPath!])
                    }
                })
            )
        default:
            print("Should not be called")
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
    
    func collectionColor(_ indexPath: IndexPath, _ cell:UICollectionViewCell) {
        switch indexPath.row % 5 {
        case 0:
            cell.backgroundColor = baseColor1
        case 1:
            cell.backgroundColor = baseColor2
        case 2:
            cell.backgroundColor = baseColor3
        case 3:
            cell.backgroundColor = baseColor4
        case 4:
            cell.backgroundColor = baseColor5
        default:
            cell.backgroundColor = baseColor1
        }
    }
    
    func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.began {
            print("start")
            if let indexPathRow = recognizer.view?.tag {
                let indexPath = IndexPath(row: indexPathRow, section: 0)
                let category = fetchedResultsController.object(at: indexPath)
                managedObjectContext.delete(category)
                do {
                    try managedObjectContext.save()
                } catch {
                    fatalCoreDataError(error)
                }
            }
        }
    }

}

extension CategoriesViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CategoryCell
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        cell.addGestureRecognizer(longPressRecognizer)
        longPressRecognizer.minimumPressDuration = 1.0
        longPressRecognizer.delegate = self
        longPressRecognizer.view?.tag = indexPath.row
        
        let category = fetchedResultsController.object(at: indexPath)
        
        let width = cell.frame.width
//        cell.categoryImageView = UIImageView(frame: CGRect(x: width / 2, y: 3, width: width / 2, height: width / 2)) 为何加了这一句，就看不到图片呀！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
        cell.categoryImageView?.contentMode = UIViewContentMode.scaleAspectFit
    
        
        cell.categoryLabel?.frame = CGRect(x:0, y:width - 40, width:width, height:20)
        cell.categoryLabel?.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        cell.categoryLabel?.textAlignment = .center
        cell.categoryLabel?.text = category.category!
        
        if let categoryColor = category.color {
            switch categoryColor {
            case "red":
                cell.categoryLabel?.textColor = red
            case "blue":
                cell.categoryLabel?.textColor = blue
            case "purple":
                cell.categoryLabel?.textColor = purple
            case "gray":
                cell.categoryLabel?.textColor = gray
            case "black":
                cell.categoryLabel?.textColor = black
            case "yellow":
                cell.categoryLabel?.textColor = yellow
            case "orange":
                cell.categoryLabel?.textColor = orange
            default:
                cell.categoryLabel?.textColor = black
            }
        }

        if category.iconName != nil {
            cell.categoryImageView?.image = UIImage(named: category.iconName!)
        }
        
        collectionColor(indexPath, cell)
        return cell
    }
}

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


