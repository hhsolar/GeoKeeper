//
//  LocationDetailFirstViewController.swift
//  GeoKeeper
//
//  Created by apple on 19/5/2017.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import MapKit
import Foundation
import AudioToolbox

class LocationDetailFirstViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var portraitImage: UIImageView!
    @IBOutlet weak var locationNameTextField: UITextField!
    @IBOutlet weak var categoryPickerButton: UIButton!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var punchNumber: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapKit: MKMapView!
    @IBOutlet weak var mapAppButton: UIButton!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var remarkTextView: UITextView!
    @IBOutlet weak var conbinationView: UIView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var portraitImageButton: UIButton!
    
    var managedObjectContext: NSManagedObjectContext!
    var locationToSave = MyLocation()
    var placemark: CLPlacemark?
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var soundID: SystemSoundID = 0
    var soundURL: NSURL?
    var keyHeight = CGFloat()
    
    var temp = ""
    var weather = ""
    var w_icon = ""
    
    fileprivate let reuseIdentifier1 = "PhotoCell"
    fileprivate let reuseIdentifier2 = "AddPhotoCell"
    
    var imageArray = [UIImage]()
    var image: UIImage?
    
    var flag = ""
    var hasPortrait = false
    
    @IBAction func cancelSave(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func choosePortrait() {
        flag = "portrait"
        showPhotoMenu()
        hasPortrait = true
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
        let targetURL = URL(string: "http://maps.apple.com/maps?saddr=Current%20Location&daddr=\(String(locationToSave.latitude)),\(String(locationToSave.longitude))")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(targetURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(targetURL)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FirstCategoryPicker" {
            let navigationController = segue.destination as! MyNavigationController
            let controller = navigationController.topViewController as! CategoryPickerTableViewController
            controller.managedObjectContext = managedObjectContext
            
            if (categoryPickerButton.titleLabel?.text!)! == "Choose a category" {
                controller.categoryChosen = "All"
            } else {
                controller.categoryChosen = (categoryPickerButton.titleLabel?.text!)!
            }
            
            controller.delegate = self
        } else if segue.identifier == "DetailView" {
            saveLocation()
            let controller = segue.destination as! LocationDetailViewController
            controller.managedObjectContext = managedObjectContext
            controller.locationToShow = locationToSave
            controller.sourceFrom = "First"
        }
    }
    
    func saveLocation() {
        locationToSave.locationName = locationNameTextField.text!
        if categoryPickerButton.titleLabel?.text != "Choose a category" {
            locationToSave.locationCategory = (categoryPickerButton.titleLabel?.text)!
        }
        locationToSave.locationDescription = remarkTextView.text
        let location: Location = NSEntityDescription.insertNewObject(forEntityName: "Location", into: managedObjectContext) as! Location
        location.name = locationToSave.locationName
        location.category = locationToSave.locationCategory
        location.date = locationToSave.date!
        location.latitude = locationToSave.latitude
        location.longitude = locationToSave.longitude
        location.placemark = locationToSave.placemark
        location.punch = locationToSave.punch
        location.locationDescription = locationToSave.locationDescription
        location.locationPhotoID = locationToSave.locationPhotoID
        
        if hasPortrait {
            location.locationPhotoID = Location.nextLocationPhotoID() as NSNumber
            if let data = UIImageJPEGRepresentation(portraitImage.image!, 0.5) {
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                } catch {
                    print("Error writing file: \(error)")
                }
            }
            locationToSave.locationPhotoID = location.locationPhotoID
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
            locationToSave.photoID = location.photoID
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        imageArray.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = secondColor
        title = locationToSave.locationName
        view.backgroundColor = grayColor
        conbinationView.backgroundColor = grayColor
        
        coordinate.latitude = locationToSave.latitude
        coordinate.longitude = locationToSave.longitude
        
        setLocation(coordinate: coordinate)
        weatherSearch(coordinate: coordinate)
        setParameter()
        initCollectionView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(tapGesure:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        remarkTextView.delegate = self
    }
    
    func setParameter() {
        // set portraitImage
        if locationToSave.hasPhoto {
            portraitImage.image = locationToSave.photoImage
        } else {
            portraitImage.image = locationDefaultImage
        }
        portraitImage.layer.borderWidth = 3
        portraitImage.layer.borderColor = secondColor.cgColor
        
        // set locationNameTextField
        locationNameTextField.text = locationToSave.locationName
        locationNameTextField.font = UIFont(name: "TrebuchetMS", size: 16)
        locationNameTextField.delegate = self
        locationNameTextField.clearButtonMode = UITextFieldViewMode.whileEditing
        locationNameTextField.layer.cornerRadius = 4
        locationNameTextField.layer.borderWidth = 0.5
        locationNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        // set categoryPicker button
        if locationToSave.locationCategory == "All" {
            categoryPickerButton.setTitle("Choose a category", for: .normal)
        } else {
            categoryPickerButton.setTitle(locationToSave.locationCategory, for: .normal)
        }
        categoryPickerButton.titleLabel!.font = UIFont(name: "TrebuchetMS", size: 14)
        categoryPickerButton.setTitleColor(UIColor.gray, for: .normal)
        categoryPickerButton.layer.cornerRadius = 4
        categoryPickerButton.layer.borderWidth = 0.5
        categoryPickerButton.layer.borderColor = UIColor.lightGray.cgColor
        
        // set addressLabel
        if let placemark = locationToSave.placemark {
            addressLabel.text = stringFromPlacemark(placemark: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        addressLabel.textColor = UIColor.black
        addressLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        
        // set mapAppButton
        mapAppButton.setTitleColor(secondColor, for: .normal)
        mapAppButton.titleLabel?.font = UIFont(name: "TrebuchetMS", size: 16)
        mapAppButton.backgroundColor = UIColor.white
        mapAppButton.layer.cornerRadius = 14
        mapAppButton.layer.masksToBounds = true
        
        // set remarkTextView
        remarkTextView.text = locationToSave.locationDescription
        remarkTextView.textColor = UIColor.black
        remarkTextView.font = UIFont(name: "TrebuchetMS", size: 15)
        
        // set weatherImageView
        weatherImageView.image = UIImage(named: w_icon)
        
        // set temperatureLabel
        temperatureLabel.textColor = baseColor
        temperatureLabel.font = UIFont(name: "TrebuchetMS", size: 16)
        temperatureLabel.text = "\(temp)C"
        
        // set punchNumber
        punchNumber.text = locationToSave.punch.stringValue
        punchNumber.textColor = secondColor
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
    
    // MARK: - textField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) ->Bool {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        
        if newText.length > 0 {
            saveButton.isEnabled = true
            saveButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "TrebuchetMS", size: 16)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
        } else {
            saveButton.isEnabled = false
            saveButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "TrebuchetMS", size: 16)!, NSForegroundColorAttributeName: UIColor.lightGray], for: .normal)
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
    
    // MARK: - Download Data From OpenwWeatherAPI
    func weatherSearch(coordinate: CLLocationCoordinate2D) {
        let url = weatherURL(coordinate: coordinate)
        if let jsonString = performWeatherRequest(with: url) {
            if let jsonDictionary = parse(json: jsonString) {
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
    
    // MARK: - Photo Collection View
    func initCollectionView() {
        photoCollectionView.backgroundColor = UIColor.lightGray
        photoCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier1)
        photoCollectionView.register(AddPhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier2)
        let layout = UICollectionViewFlowLayout()
        photoCollectionView.collectionViewLayout = layout
        layout.scrollDirection = .horizontal
        photoCollectionView.showsHorizontalScrollIndicator = false
    }
    
    func show(image: UIImage) {
        if flag == "portrait" {
            portraitImage.image = image
        } else if flag == "collectionView" {
            imageArray.append(image)
            photoCollectionView.reloadData()
        }
    }
}

extension LocationDetailFirstViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if imageArray.count > indexPath.row {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier1, for: indexPath) as! PhotoCell
            cell.awakeFromNib()
            cell.delegate = self
            cell.cellIndex = indexPath.row
            cell.photoImageView.image = imageArray[indexPath.row]
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier2, for: indexPath) as! AddPhotoCell
        cell.awakeFromNib()
        cell.delegate = self
        if imageArray.count < photoCapacity {
            cell.buttonImageView.image = UIImage(named: "addPhotoIcon")
            cell.addButton.isEnabled = true
        } else {
            cell.buttonImageView.image = UIImage(named: "maxPhoto")
            cell.addButton.isEnabled = false
        }
        return cell
    }
}

extension LocationDetailFirstViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemHeight: CGFloat = collectionView.frame.height - 10 * 2
        return CGSize(width: itemHeight, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

extension LocationDetailFirstViewController: PhotoCellDelegate {
    func enlargeImage(forCell: PhotoCell) {
        if imageArray.count > 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier:"PhotoView") as! PhotoViewController
            controller.imageArray = imageArray
            controller.showIndex = forCell.cellIndex
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func deleteImage(forCell: PhotoCell) {
        imageArray.remove(at: forCell.cellIndex)
        photoCollectionView.reloadData()
    }
}

extension LocationDetailFirstViewController: AddPhotoCellDelegate {
    func addPhoto(forCell: AddPhotoCell) {
        if imageArray.count < photoCapacity {
            flag = "collectionView"
            showPhotoMenu()
        }
    }
}

extension LocationDetailFirstViewController: CategoryPickerTableViewControllerDelegate {
    func passCategory(categoryName: String) {
        if categoryName == "All" {
            categoryPickerButton.setTitle("Choose a category", for: .normal)
        } else {
            categoryPickerButton.setTitle(categoryName, for: .normal)
        }
    }
}

extension LocationDetailFirstViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
