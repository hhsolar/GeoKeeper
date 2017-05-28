//
//  LocationDetailEditViewController.swift
//  GeoKeeper
//
//  Created by apple on 24/3/2017.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import Foundation

protocol LocationDetailEditViewControllerDelegate {
    func passLocation(location: MyLocation)
}

class LocationDetailEditViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var categoryPicker: UIButton!
    @IBOutlet weak var portraitImageView: UIImageView!
    @IBOutlet weak var remarkTextView: UITextView!
    @IBOutlet weak var nBar: UINavigationBar!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var remarkLabel: UILabel!
    
    var managedObjectContext: NSManagedObjectContext!
    var locationToSave: Location?
    var locationToEdit = MyLocation()
    var imageBackup: [NSNumber]?
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var delegate: LocationDetailEditViewControllerDelegate? = nil
    
    var portraitViewFrame = CGRect.zero
    var nameTextFrame = CGRect.zero
    var categoryFrame = CGRect.zero
    var addImageButtonFrame = CGRect.zero
    var collectionFrame = CGRect.zero
    var remarkTextViewFrame = CGRect.zero
    var remarkLabelFrame = CGRect.zero
    
    var keyHeight = CGFloat()
    fileprivate let reuseIdentifier1 = "PhotoCell"
    fileprivate let reuseIdentifier2 = "AddPhotoCell"
    var flag = ""
    var hasPortrait = false
    var portraitChanged = false
    
    var imageArray = [UIImage]()
    var image: UIImage?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CategoryChoose" {
            let navigationController = segue.destination as! MyNavigationController
            let controller = navigationController.topViewController as! CategoryPickerTableViewController
            controller.managedObjectContext = managedObjectContext
            
            if (categoryPicker.titleLabel?.text!)! == "Choose a category" {
                controller.categoryChosen = "All"
            } else {
                controller.categoryChosen = (categoryPicker.titleLabel?.text!)!
            }
            
            controller.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.tintColor = secondColor
        
        nBar.topItem?.title = "Edit Location"
        nameTextField.text = locationToEdit.locationName
        if locationToEdit.locationCategory == "All" {
            categoryPicker.setTitle("Choose a category", for: .normal)
        } else {
            categoryPicker.setTitle(locationToEdit.locationCategory, for: .normal)
        }
        
        if locationToEdit.hasPhoto {
            portraitImageView.image = locationToEdit.photoImage
            hasPortrait = true
        } else {
            portraitImageView.image = locationDefaultImage
        }
        
        remarkTextView.text = locationToEdit.locationDescription
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(tapGesure:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        remarkTextView.delegate = self
        
        setPara()
        initCollectionView()
        imageBackup = locationToEdit.photoID
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let photoIDs = locationToEdit.photoID {
            if photoIDs.count < photoCapacity {
                enableAddImageButton()
            }
        } else {
            enableAddImageButton()
        }
        disableAddImageButton()
    }
    
    func setPara() {
        // set portraitImageView
        portraitImageView.frame = portraitViewFrame
        portraitImageView.layer.borderWidth = 5
        portraitImageView.layer.borderColor = UIColor.white.cgColor
        
        // set nameTextField
        nameTextField.frame = nameTextFrame
        nameTextField.font = UIFont(name: "TrebuchetMS", size: 16)
        nameTextField.delegate = self
        nameTextField.clearButtonMode = UITextFieldViewMode.whileEditing
        
        // set categoryPicker button
        categoryPicker.frame = CGRect(x: categoryFrame.origin.x, y: categoryFrame.origin.y, width: nameTextFrame.size.width, height: categoryFrame.size.height)
        categoryPicker.titleLabel!.font = UIFont(name: "TrebuchetMS", size: 14)
        categoryPicker.setTitleColor(UIColor.gray, for: .normal)
        categoryPicker.layer.cornerRadius = 4
        
        // set addImageButton
        addImageButton.frame = addImageButtonFrame
        addImageButton.setTitleColor(secondColor, for: .normal)
        addImageButton.titleLabel?.font = UIFont(name: "TrebuchetMS", size: 16)
        addImageButton.backgroundColor = UIColor.white
        addImageButton.layer.cornerRadius = 14
        
        // set remarkTextView
        remarkLabel.frame = remarkLabelFrame
        remarkTextView.frame = remarkTextViewFrame
        
        // set navigationBar
        nBar.barTintColor = baseColor
        nBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "TrebuchetMS-Bold", size: 17)!, NSForegroundColorAttributeName: UIColor.white]
        nBar.topItem?.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "TrebuchetMS", size: 16)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
        nBar.topItem?.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "TrebuchetMS", size: 16)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
    }
    
    func initCollectionView() {
        photoCollection.frame = collectionFrame
        photoCollection.backgroundColor = UIColor.lightGray
        photoCollection.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier1)
        photoCollection.register(AddPhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier2)
        let layout = UICollectionViewFlowLayout()
        photoCollection.collectionViewLayout = layout
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        let itemHeight: CGFloat = photoCollection.frame.height - 10 * 2
        layout.itemSize = CGSize(width: itemHeight, height: itemHeight)
        layout.minimumLineSpacing = 8
        
        layout.scrollDirection = .horizontal
        photoCollection.showsHorizontalScrollIndicator = false
    }

    // textField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) ->Bool {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        
        if newText.length > 0 {
            doneButton.isEnabled = true
            doneButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "TrebuchetMS", size: 16)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
        } else {
            doneButton.isEnabled = false
            doneButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "TrebuchetMS", size: 16)!, NSForegroundColorAttributeName: UIColor.lightGray], for: .normal)
        }
        return true
    }
    
    // textView related
    func hideKeyboard(tapGesure: UITapGestureRecognizer) {
        self.remarkTextView.resignFirstResponder()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        let centerDefault = NotificationCenter.default
        centerDefault.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        return true
    }
    
    func keyboardWillShow(aNotification: NSNotification) {
        let userinfo: NSDictionary = aNotification.userInfo! as NSDictionary
        let nsValue = userinfo.object(forKey: UIKeyboardFrameEndUserInfoKey)
        let keyboardRec = (nsValue as AnyObject).cgRectValue
        let height = keyboardRec?.size.height
        self.keyHeight = height!
        UIView.animate(withDuration: 0.5, animations: {
            var frame = self.view.frame
            frame.origin.y = -self.keyHeight
            self.view.frame = frame
        }, completion: nil)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        UIView.animate(withDuration: 0.5, animations: {
            var frame = self.view.frame
            frame.origin.y = 0
            self.view.frame = frame
        }, completion: nil)
        let centerDefault = NotificationCenter.default
        centerDefault.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        return true
    }
    
    func updateContent(location: Location) {
        location.name = nameTextField.text
        if (categoryPicker.titleLabel?.text)! != "Choose a category" {
            location.category = (categoryPicker.titleLabel?.text)!
        } else {
            location.category = "All"
        }
        location.locationDescription = remarkTextView.text
        
        locationToEdit.locationName = location.name!
        locationToEdit.locationCategory = location.category
        locationToEdit.locationDescription = location.locationDescription
        
        if location.hasPhoto && portraitChanged {
            location.removePhotoFile()
            if let data = UIImageJPEGRepresentation(portraitImageView.image!, 0.5) {
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        } else if !location.hasPhoto && portraitChanged {
            location.locationPhotoID = Location.nextLocationPhotoID() as NSNumber
            if let data = UIImageJPEGRepresentation(portraitImageView.image!, 0.5) {
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                } catch {
                    print("Error writing file: \(error)")
                }
            }
            locationToEdit.locationPhotoID = location.locationPhotoID
        }
        
        
        if let photoIDs = location.photoID {
            if let photoIDsEdit = locationToEdit.photoID {
                if photoIDs.count > photoIDsEdit.count {
                    for i in photoIDs.reversed() {
                        if !photoIDsEdit.contains(i) {
                            location.removePhotoFile(photoIndex: i)
                            let ind = photoIDs.index(of: i)
                            location.photoID?.remove(at: ind!)
                        }
                    }
                }
            }
        }
        
        if imageArray.count > 0 {
            if location.photoID != nil {
                for img in imageArray {
                    location.photoID?.append(location.nextPhotoID() as NSNumber)
                    if let data = UIImageJPEGRepresentation(img, 0.5) {
                        do {
                            try data.write(to: location.photosURL(photoIndex: (location.photoID?.last)!), options: .atomic)
                        } catch {
                            print("Error writing file: \(error)")
                        }
                    }
                }

            } else {
                location.photoID = []
                for img in imageArray {
                    location.photoID?.append(location.nextPhotoID() as NSNumber)
                    if let data = UIImageJPEGRepresentation(img, 0.5) {
                        do {
                            try data.write(to: location.photosURL(photoIndex: (location.photoID?.last)!), options: .atomic)
                        } catch {
                            print("Error writing file: \(error)")
                        }
                    }
                }
            }
            locationToEdit.photoID = location.photoID
        }
    }
    
    @IBAction func done() {
        var locations = [Location]()
        var hasRocord = false
        
        let fetchedRequest = NSFetchRequest<Location>(entityName: "Location")
        fetchedRequest.entity = Location.entity()
        do {
            locations = try managedObjectContext.fetch(fetchedRequest)
        } catch {
            fatalCoreDataError(error)
        }
        
        for locationRecord in locations {
            if let placemarkRecord = locationRecord.placemark {
                if let placemarkEdit = locationToEdit.placemark {
                    if stringFromPlacemark(placemark: placemarkEdit) == stringFromPlacemark(placemark: placemarkRecord) {
                        updateContent(location: locationRecord)
                        hasRocord = true
                    }
                }
            }
        }
        
        if !hasRocord {
            locationToEdit.locationName = nameTextField.text!
            if (categoryPicker.titleLabel?.text)! != "Choose a category" {
                locationToEdit.locationCategory = (categoryPicker.titleLabel?.text)!
            }
            locationToEdit.locationDescription = remarkTextView.text
            
            let location: Location = NSEntityDescription.insertNewObject(forEntityName: "Location", into: managedObjectContext) as! Location
            location.name = locationToEdit.locationName
            location.category = locationToEdit.locationCategory
            location.date = locationToEdit.date!
            location.latitude = locationToEdit.latitude
            location.longitude = locationToEdit.longitude
            location.placemark = locationToEdit.placemark
            location.punch = locationToEdit.punch
            location.locationDescription = locationToEdit.locationDescription
            location.locationPhotoID = locationToEdit.locationPhotoID
            
            if hasPortrait {
                location.locationPhotoID = Location.nextLocationPhotoID() as NSNumber
                if let data = UIImageJPEGRepresentation(portraitImageView.image!, 0.5) {
                    do {
                        try data.write(to: location.photoURL, options: .atomic)
                    } catch {
                        print("Error writing file: \(error)")
                    }
                }
                locationToEdit.locationPhotoID = location.locationPhotoID
            }
            
            if imageArray.count > 0 {
                location.photoID = []
                for img in imageArray {
                    location.photoID?.append(location.nextPhotoID() as NSNumber)
                    if let data = UIImageJPEGRepresentation(img, 0.5) {
                        do {
                            try data.write(to: location.photosURL(photoIndex: (location.photoID?.last!)!), options: .atomic)
                        } catch {
                            print("Error writing file: \(error)")
                        }
                    }
                }
                locationToEdit.photoID = location.photoID
            }
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        delegate?.passLocation(location: locationToEdit)
        
        imageArray.removeAll()

        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImage() {
        flag = "collectionView"
        if let photoIDs = locationToEdit.photoID {
            if photoIDs.count + imageArray.count < photoCapacity {
                showPhotoMenu()
            }
        } else {
            if imageArray.count < photoCapacity {
                showPhotoMenu()
            }
        }
    }
    
    func show(image: UIImage) {
        if flag == "portrait" {
            portraitImageView.image = image
        } else if flag == "collectionView"{
            imageArray.append(image)
            photoCollection.reloadData()
        }
    }
    
    func disableAddImageButton() {
        addImageButton.setTitle("Capacity Maximum", for: .normal)
        addImageButton.tintColor = UIColor.lightGray
        addImageButton.setTitleColor(UIColor.lightGray, for: .normal)
    }
    
    func enableAddImageButton() {
        addImageButton.setTitle("Add Image", for: .normal)
        addImageButton.tintColor = secondColor
        addImageButton.setTitleColor(secondColor, for: .normal)
    }
    
    @IBAction func cancel() {
        locationToEdit.photoID = imageBackup
        delegate?.passLocation(location: locationToEdit)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func choosePortrait() {
        flag = "portrait"
        showPhotoMenu()
        hasPortrait = true
        portraitChanged = true
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
        if let photoIDs = locationToEdit.photoID {
            if photoIDs.count + imageArray.count == 0 {
                return 1
            }
            return photoIDs.count + imageArray.count + 1
        } else if imageArray.count == 0 {
            return 1
        }
        return imageArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let photoIDs = locationToEdit.photoID {
            if photoIDs.count + imageArray.count == 0 || photoIDs.count + imageArray.count == indexPath.row {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier2, for: indexPath) as! AddPhotoCell
                cell.awakeFromNib()
                cell.delegate = self
                if photoIDs.count + imageArray.count == photoCapacity {
                    cell.buttonImageView.image = UIImage(named: "maxPhoto")
                    cell.addButton.isEnabled = false
                    disableAddImageButton()
                } else {
                    cell.buttonImageView.image = UIImage(named: "addPhotoIcon")
                    cell.addButton.isEnabled = true
                    enableAddImageButton()
                }
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier1, for: indexPath) as! PhotoCell
            cell.awakeFromNib()
            cell.delegate = self
            cell.cellButton.isHidden = true
            cell.cellIndex = indexPath.row
            if !photoIDs.isEmpty && indexPath.row < photoIDs.count {
                let index = photoIDs[indexPath.row]
                cell.photoImageView.image = locationToEdit.photoImages(photoIndex: Int(index))
            } else {
                let index = indexPath.row - photoIDs.count
                cell.photoImageView.image = imageArray[index]
            }
            return cell
        } else if imageArray.count == 0 || imageArray.count == indexPath.row {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier2, for: indexPath) as! AddPhotoCell
            cell.awakeFromNib()
            cell.delegate = self
            if imageArray.count == photoCapacity {
                cell.buttonImageView.image = UIImage(named: "maxPhoto")
                cell.addButton.isEnabled = false
                disableAddImageButton()
            } else {
                cell.buttonImageView.image = UIImage(named: "addPhotoIcon")
                cell.addButton.isEnabled = true
                enableAddImageButton()
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier1, for: indexPath) as! PhotoCell
            cell.awakeFromNib()
            cell.delegate = self
            cell.cellButton.isHidden = true
            cell.cellIndex = indexPath.row
            cell.photoImageView.image = imageArray[indexPath.row]
            return cell
        }
    }

}

extension LocationDetailEditViewController: AddPhotoCellDelegate {
    func addPhoto(forCell: AddPhotoCell) {
        if imageArray.count < photoCapacity {
            flag = "collectionView"
            showPhotoMenu()
        }
    }
}

extension LocationDetailEditViewController: PhotoCellDelegate {    
    func deleteImage(forCell: PhotoCell) {
        let image = UIImage(named: "closeButton")
        forCell.deleteButton.setImage(image, for: .highlighted)
        
        if let photoIDs = locationToEdit.photoID {
            if !photoIDs.isEmpty && forCell.cellIndex < photoIDs.count {
                locationToEdit.photoID?.remove(at: forCell.cellIndex)
            } else {
                let ind = forCell.cellIndex - photoIDs.count
                imageArray.remove(at: ind)
            }
        } else {
            imageArray.remove(at: forCell.cellIndex)
        }
        photoCollection.reloadData()
    }
}

extension LocationDetailEditViewController: CategoryPickerTableViewControllerDelegate {
    func passCategory(categoryName: String) {
        if categoryName == "All" {
            categoryPicker.setTitle("Choose a category", for: .normal)
        } else {
            categoryPicker.setTitle(categoryName, for: .normal)
        }
    }
}

extension LocationDetailEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in self.takePhotoWithCamera() })
        alertController.addAction(takePhotoAction)
        let chooseFormLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in self.choosePhotoFromLibrary() })
        alertController.addAction(chooseFormLibraryAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func takePhotoWithCamera() {
        let imagePicker = MyImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if let theImage = image {
            show(image: theImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = MyImagePickerController()
        imagePicker.navigationBar.barTintColor = baseColor
        imagePicker.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "TrebuchetMS-Bold", size: 17)!, NSForegroundColorAttributeName: UIColor.white]
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
}
