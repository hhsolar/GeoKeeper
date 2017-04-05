//
//  LocationDetailEditViewController.swift
//  GeoKeeper
//
//  Created by apple on 24/3/2017.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class LocationDetailEditViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var categoryPicker: UIButton!
    @IBOutlet weak var portraitImageView: UIImageView!
    @IBOutlet weak var remarkTextView: UITextView!
    @IBOutlet weak var nBar: UINavigationBar!
    @IBOutlet weak var photoCollection: UICollectionView!
    
    var managedObjectContext: NSManagedObjectContext!
    var locationToEdit: Location?
    
    let baseColor = UIColor(red: 71/255.0, green: 117/255.0, blue: 179/255.0, alpha: 1.0)
    
    var collectionFrame = CGRect.zero
    fileprivate let reuseIdentifier = "PhotoCell"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
  
        setPara()
        initCollectionView()
                
    }
    
    func setPara() {
        // set portraitImageView
        print("!!!!!!!!! \(locationToEdit?.locationPhotoID)")
        portraitImageView.image = UIImage(named: (locationToEdit?.locationPhotoID)!)
        portraitImageView.layer.borderWidth = 5
        portraitImageView.layer.borderColor = UIColor.white.cgColor
        
        // set nameTextField
        nameTextField.text = locationToEdit?.name
        nameTextField.font = UIFont(name: "TrebuchetMS", size: 16)
        
        // set categoryPicker
        categoryPicker.setTitle(locationToEdit?.category, for: .normal)
        categoryPicker.titleLabel!.font = UIFont(name: "TrebuchetMS", size: 14)
        categoryPicker.setTitleColor(UIColor.gray, for: .normal)
        categoryPicker.layer.cornerRadius = 4
//        categoryPicker.addTarget(self, action: #selector(ViewController.noInteractPush), for: .touchUpInside)
        
        remarkTextView.text = locationToEdit?.locationDescription
        
        // set navigationBar
        nBar.barTintColor = baseColor
        nBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "TrebuchetMS-Bold", size: 17)!, NSForegroundColorAttributeName: UIColor.white]
        nBar.topItem?.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "TrebuchetMS", size: 16)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
        nBar.topItem?.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "TrebuchetMS", size: 16)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
    }
    
    func initCollectionView() {
        photoCollection.frame = collectionFrame
        photoCollection.backgroundColor = UIColor.lightGray
        photoCollection.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        let layout = UICollectionViewFlowLayout()
        photoCollection.collectionViewLayout = layout
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        let itemHeight: CGFloat = photoCollection.frame.height - 8 * 2
        layout.itemSize = CGSize(width: itemHeight, height: itemHeight)
        layout.minimumLineSpacing = 8
        
        layout.scrollDirection = .horizontal
        photoCollection.showsHorizontalScrollIndicator = false
    }

    @IBAction func done() {
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func choosePortrait() {
        
    }
    
    @IBAction func loadCategoryPicker() {
        
    }
    
    @IBAction func editPhoto() {
        
    }
    
    @IBAction func nameDone() {
        
    }
    
}

extension LocationDetailEditViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeInAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeOutAnimationController()
    }
}

extension LocationDetailEditViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension LocationDetailEditViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        cell.awakeFromNib()
        cell.delegate = self
        cell.photoImageView.image = UIImage(named: "portrait_cat")
        return cell
    }
}

extension LocationDetailEditViewController: PhotoCellDelegate {
    func changeColorOfButton(forCell: PhotoCell) {
        let image = UIImage(named: "closeButton")
        forCell.deleteButton.setImage(image, for: .highlighted)
    }
}
