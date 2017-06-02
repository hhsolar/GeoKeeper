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
import MapKit
import AudioToolbox

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
    @IBOutlet weak var openMapButton: UIButton!
    @IBOutlet weak var punchLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tempratureLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var mapKit: MKMapView!
    @IBOutlet weak var conbinationView: UIView!
    
    var managedObjectContext: NSManagedObjectContext!
    var locationToEdit = MyLocation()
    var imageBackup: [NSNumber]?
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var soundID: SystemSoundID = 0
    var soundURL: NSURL?
    
    var delegate: LocationDetailEditViewControllerDelegate? = nil
    
    var keyHeight = CGFloat()
    fileprivate let reuseIdentifier1 = "PhotoCell"
    fileprivate let reuseIdentifier2 = "AddPhotoCell"
    var flag = ""
    var hasPortrait = false
    var portraitChanged = false
    
    var temp = ""
    var weather = ""
    var w_icon = ""
    
    var imageArray = [UIImage]()
    var image: UIImage?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    @IBAction func playWeatherSound(_ sender: Any) {
        switch w_icon {
        case "01":
            loadSoundEffect("Bird.caf")
        case "02":
            loadSoundEffect("Bird.caf")
        case "03":
            loadSoundEffect("Bird.caf")
        case "04":
            loadSoundEffect("Bird.caf")
        case "09":
            loadSoundEffect("Rain.caf")
        case "10":
            loadSoundEffect("Bird.caf")
        case "11":
            loadSoundEffect("Thunder.caf")
        case "13":
            loadSoundEffect("Bird.caf")
        case "50":
            loadSoundEffect("Bird.caf")
        default:
            loadSoundEffect("Bird.caf")
        }
        playSoundEffect()
    }
    
    @IBAction func openMapsApp() {
        let targetURL = URL(string: "http://maps.apple.com/maps?saddr=Current%20Location&daddr=\(String(locationToEdit.latitude)),\(String(locationToEdit.longitude))")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(targetURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(targetURL)
        }
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
        view.tintColor = secondColor
        view.backgroundColor = grayColor
        conbinationView.backgroundColor = grayColor
        
        nBar.topItem?.title = "Edit Location"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(tapGesure:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        
        coordinate.latitude = locationToEdit.latitude
        coordinate.longitude = locationToEdit.longitude
        
        setLocation(coordinate: coordinate)
        weatherSearch(coordinate: coordinate)
        setParameter()
        initCollectionView()
        imageBackup = locationToEdit.photoID
    }
    
    func setParameter() {
        // set portraitImageView
        if locationToEdit.hasPhoto {
            portraitImageView.image = locationToEdit.photoImage
            hasPortrait = true
        } else {
            portraitImageView.image = locationDefaultImage
        }
        portraitImageView.layer.borderWidth = 3
        portraitImageView.layer.borderColor = secondColor.cgColor
        
        // set nameTextField
        nameTextField.text = locationToEdit.locationName
        nameTextField.font = UIFont(name: "TrebuchetMS", size: 16)
        nameTextField.delegate = self
        nameTextField.clearButtonMode = UITextFieldViewMode.whileEditing
        nameTextField.layer.cornerRadius = 4
        nameTextField.layer.borderWidth = 0.5
        nameTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        // set categoryPicker button
        if locationToEdit.locationCategory == "All" {
            categoryPicker.setTitle("Choose a category", for: .normal)
        } else {
            categoryPicker.setTitle(locationToEdit.locationCategory, for: .normal)
        }
        categoryPicker.titleLabel!.font = UIFont(name: "TrebuchetMS", size: 14)
        categoryPicker.setTitleColor(UIColor.gray, for: .normal)
        categoryPicker.layer.cornerRadius = 4
        categoryPicker.layer.borderWidth = 0.5
        categoryPicker.layer.borderColor = UIColor.lightGray.cgColor
        
        // set addressLabel
        if let placemark = locationToEdit.placemark {
            addressLabel.text = stringFromPlacemark(placemark: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        addressLabel.textColor = UIColor.black
        addressLabel.font = UIFont(name: "TrebuchetMS", size: 15)

        
        // set mapAppButton
        openMapButton.setTitleColor(secondColor, for: .normal)
        openMapButton.titleLabel?.font = UIFont(name: "TrebuchetMS", size: 16)
        openMapButton.backgroundColor = UIColor.white
        openMapButton.layer.cornerRadius = 14
        openMapButton.layer.masksToBounds = true
        
        
        // set remarkTextView
        remarkTextView.text = locationToEdit.locationDescription
        remarkTextView.textColor = UIColor.black
        remarkTextView.font = UIFont(name: "TrebuchetMS", size: 15)
        
        // set weatherImageView
        weatherImageView.image = UIImage(named: w_icon)
        
        // set temperatureLabel
        tempratureLabel.textColor = baseColor
        tempratureLabel.font = UIFont(name: "TrebuchetMS", size: 16)
        tempratureLabel.text = "\(temp)C"
        
        // set punchNumber
        punchLabel.text = locationToEdit.punch.stringValue
        punchLabel.textColor = secondColor
        
        // set navigationBar
        nBar.barTintColor = baseColor
        nBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "TrebuchetMS-Bold", size: 17)!, NSForegroundColorAttributeName: UIColor.white]
        nBar.topItem?.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "TrebuchetMS", size: 16)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
        nBar.topItem?.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "TrebuchetMS", size: 16)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
    }
    
    func initCollectionView() {
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

    func setLocation(coordinate: CLLocationCoordinate2D) {
        let latDelta = 0.05
        let longDelta = 0.05
        let currentLocationSpan: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        let currentRegion: MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: currentLocationSpan)
        
        mapKit.setRegion(currentRegion, animated: true)
        
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = coordinate
        mapKit.addAnnotation(objectAnnotation)
        
        mapKit.isZoomEnabled = true
    }
    
    // MARK: - download data from openwWeatherAPI
    func weatherSearch(coordinate: CLLocationCoordinate2D) {
        let url = weatherURL(coordinate: coordinate)
        if let jsonString = performWeatherRequest(with: url) {
            if let jsonDictionary = parse(json: jsonString) {
                //                print("Dictionay \(jsonDictionary)")
                parse(dictionary: jsonDictionary)
            }
        } else {
            showNetworkError()
        }
    }
    
    func performWeatherRequest(with url: URL) -> String? {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            print("Download Error: \(error)")
            return nil
        }
    }
    
    func weatherURL(coordinate: CLLocationCoordinate2D) -> URL{
        let urlString = String(format: "http://api.openweathermap.org/data/2.5/weather?lat=%@&lon=%@&APPID=%@", String(coordinate.latitude), String(coordinate.longitude), apiKey)
        let url = URL(string: urlString)
        return url!
    }
    
    // parsing JSON
    func parse(json: String) -> [String: Any]? {
        guard let data = json.data(using: .utf8)
            else { return nil }
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    func parse(dictionary: [String: Any]) {
        guard let array = dictionary["main"] else {
            print("Excepted 'results' array")
            return
        }
        let main = array as! NSDictionary
        let a = "\(main["temp"]!)"
        let b = Int(Float(a)!) - 273
        temp = "\(b)°"
        
        guard let array1 = dictionary["weather"] as? [Any] else {
            print("Excepted 'results' array")
            return
        }
        for resultDict in array1 {
            if let resultDict = resultDict as? [String: Any] {
                if let description = resultDict["description"] as? String {
                    weather = description
                }
                if let weather_icon = resultDict["icon"] as? String {
                    let index = weather_icon.index(weather_icon.startIndex, offsetBy: 2)
                    w_icon = weather_icon.substring(to: index)
                }
            }
        }
    }
    
    // alert for error
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error reading from the openweathermap. Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    
    // MARK: - Weather Sound Effect
    func loadSoundEffect(_ name: String) {
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            let fileURL = URL(fileURLWithPath: path, isDirectory: false)
            let error = AudioServicesCreateSystemSoundID(fileURL as CFURL,&soundID)
            if error != kAudioServicesNoError {
                print("Error code \(error) loading sound at path: \(path)")
            }
        }
    }
    
    func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
    }
    func playSoundEffect() {
        AudioServicesPlaySystemSound(soundID)
    }
    
    // MARK: - textField delegate
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
    
    // MARK: - textView related
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
    
    func show(image: UIImage) {
        if flag == "portrait" {
            portraitImageView.image = image
        } else if flag == "collectionView"{
            imageArray.append(image)
            photoCollection.reloadData()
        }
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
                } else {
                    cell.buttonImageView.image = UIImage(named: "addPhotoIcon")
                    cell.addButton.isEnabled = true
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
            } else {
                cell.buttonImageView.image = UIImage(named: "addPhotoIcon")
                cell.addButton.isEnabled = true
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
