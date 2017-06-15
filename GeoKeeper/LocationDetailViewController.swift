//
//  LocationDetailViewController.swift
//  GeoKeeper
//
//  Created by apple on 19/3/2017.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import MapKit
import Foundation
import AudioToolbox

protocol LocationDetailViewControllerDelegate {
    func passLocation(location: MyLocation)
}

class LocationDetailViewController: UIViewController {
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapKit: MKMapView!
    @IBOutlet weak var mapAppButton: UIButton!
    @IBOutlet weak var remarkTextView: UITextView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var portraitImage: UIImageView!
    @IBOutlet weak var punchNumber: UILabel!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var conbinationView: UIView!
    
    var managedObjectContext: NSManagedObjectContext!
    var locationToShow = MyLocation()
    var placemark: CLPlacemark?
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var delegate: LocationDetailViewControllerDelegate? = nil
    var soundID: SystemSoundID = 0
    var soundURL: NSURL?
        
    var temp = ""
    var weather = ""
    var w_icon = ""
    
    fileprivate let reuseIdentifier1 = "PhotoCell"
    fileprivate let reuseIdentifier2 = "AddPhotoCell"
    
    var image: UIImage?
    
    var sourceFrom = ""
    
    @IBAction func openMapsApp() {
        let targetURL = URL(string: "http://maps.apple.com/maps?saddr=Current%20Location&daddr=\(String(locationToShow.latitude)),\(String(locationToShow.longitude))")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(targetURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(targetURL)
        }
    }
    
    @IBAction func playWeatherSound() {
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
    
    @IBAction func getBack() {
        delegate?.passLocation(location: locationToShow)
        if sourceFrom == "First" {
            navigationController?.popToRootViewController(animated: true)
        } else if sourceFrom == "CurrentLocation" {
            navigationController?.popViewController(animated: true)
        } else if sourceFrom == "SearchCV" {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailEdit" {
            let controller = segue.destination as! LocationDetailEditViewController
            controller.managedObjectContext = managedObjectContext
            controller.locationToEdit = locationToShow
            
            controller.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = secondColor
        title = locationToShow.locationName
        locationNameLabel.text = locationToShow.locationName
        punchNumber.text = locationToShow.punch.stringValue
        remarkTextView.text = locationToShow.locationDescription
        punchNumber.text = locationToShow.punch.stringValue
        if locationToShow.locationCategory == "All" {
            categoryLabel.text = "No category"
        } else {
            categoryLabel.text = locationToShow.locationCategory
        }
        
        if locationToShow.hasPhoto {
            portraitImage.image = locationToShow.photoImage
        } else {
            portraitImage.image = locationDefaultImage
        }
        
        if let placemark = locationToShow.placemark {
            addressLabel.text = stringFromPlacemark(placemark: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        coordinate.latitude = locationToShow.latitude
        coordinate.longitude = locationToShow.longitude
        
        setLocation(coordinate: coordinate)
        weatherSearch(coordinate: coordinate)
        setContainer()
        initCollectionView()
    }
    
    func setContainer() {
        // set locationNameLabel
        locationNameLabel.textColor = baseColor
        locationNameLabel.font = UIFont(name: "TrebuchetMS-Bold", size: 22)
        
        // set categoryLabel
        categoryLabel.textColor = UIColor.gray
        categoryLabel.font = UIFont(name: "TrebuchetMS", size: 14)
        
        // set addressLabel
        addressLabel.textColor = UIColor.black
        addressLabel.font = UIFont(name: "TrebuchetMS", size: 16)
        
        // set mapAppButton
        mapAppButton.setTitleColor(secondColor, for: .normal)
        mapAppButton.titleLabel?.font = UIFont(name: "TrebuchetMS", size: 16)
        
        // set remarkTextView
        remarkTextView.textColor = UIColor.black
        remarkTextView.font = UIFont(name: "TrebuchetMS", size: 15)
        remarkTextView.isEditable = false
        
        // set weatherImageView
        weatherImageView.image = UIImage(named: w_icon)
        
        // set temperatureLabel
        temperatureLabel.textColor = baseColor
        temperatureLabel.font = UIFont(name: "TrebuchetMS", size: 16)
        temperatureLabel.text = "\(temp)C"
        
        // set punchNumber
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
    
    func initCollectionView() {
        photoCollectionView.backgroundColor = grayColor
        photoCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier1)
        photoCollectionView.register(AddPhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier2)
        let layout = UICollectionViewFlowLayout()
        photoCollectionView.collectionViewLayout = layout
//        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
//        
//        let itemHeight: CGFloat = photoCollectionView.frame.height - 10 * 2
//        layout.itemSize = CGSize(width: itemHeight, height: itemHeight)
        
//        layout.minimumLineSpacing = 8
        
        layout.scrollDirection = .horizontal
        photoCollectionView.showsHorizontalScrollIndicator = false
        
    }
    
    // MARK: - Sound Effect
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
    
    func show(image: UIImage) {
        var locations = [Location]()
        
        let fetchedRequest = NSFetchRequest<Location>(entityName: "Location")
        fetchedRequest.entity = Location.entity()
        do {
            locations = try managedObjectContext.fetch(fetchedRequest)
        } catch {
            fatalCoreDataError(error)
        }
        
        for locationRecord in locations {
            if let placemarkRecord = locationRecord.placemark {
                if let placemarkEdit = locationToShow.placemark {
                    if stringFromPlacemark(placemark: placemarkEdit) == stringFromPlacemark(placemark: placemarkRecord) {
                        if locationRecord.photoID == nil {
                            locationRecord.photoID = []
                        }
                        locationRecord.photoID?.append(locationRecord.nextPhotoID() as NSNumber)
                        if let data = UIImageJPEGRepresentation(image, 0.5) {
                            do {
                                try data.write(to: locationRecord.photosURL(photoIndex: (locationRecord.photoID?.last!)!), options: .atomic)
                            } catch {
                                print("Error writing file: \(error)")
                            }
                        }
                        locationToShow.photoID = locationRecord.photoID
                    }
                }
            }
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
        photoCollectionView.reloadData()
    }
}

extension LocationDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let photoIDs = locationToShow.photoID {
            if photoIDs.count > 0 {
                return photoIDs.count + 1
            }
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let photoIDs = locationToShow.photoID {
            if photoIDs.count == indexPath.row {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier2, for: indexPath) as! AddPhotoCell
                cell.awakeFromNib()
                cell.delegate = self
                if photoIDs.count < photoCapacity {
                    cell.buttonImageView.image = UIImage(named: "addPhotoIcon")
                    cell.addButton.isEnabled = true
                } else {
                    cell.buttonImageView.image = UIImage(named: "maxPhoto")
                    cell.addButton.isEnabled = false
                }
                return cell
            } else if photoIDs.count > 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier1, for: indexPath) as! PhotoCell
                cell.awakeFromNib()
                cell.delegate = self
                cell.deleteButton.isHidden = true
                cell.cellIndex = indexPath.row
                
                let index = photoIDs[indexPath.row]
                cell.photoImageView.image = locationToShow.photoImages(photoIndex: Int(index))
                return cell
            }
        }
        
        let cell = photoCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier2, for: indexPath) as! AddPhotoCell
        cell.awakeFromNib()
        cell.delegate = self
        cell.buttonImageView.image = UIImage(named: "addPhotoIcon")
        cell.addButton.isEnabled = true
        return cell
    }
}


extension LocationDetailViewController: UICollectionViewDelegateFlowLayout {
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

extension LocationDetailViewController: LocationDetailEditViewControllerDelegate {
    func passLocation(location: MyLocation) {
        locationToShow = location
        title = locationToShow.locationName
        locationNameLabel.text = locationToShow.locationName
        remarkTextView.text = locationToShow.locationDescription

        if locationToShow.locationCategory == "All" {
            categoryLabel.text = "No category"
        } else {
            categoryLabel.text = locationToShow.locationCategory
        }
        
        if locationToShow.hasPhoto {
            portraitImage.image = locationToShow.photoImage
        }
        photoCollectionView.reloadData()
    }
}

extension LocationDetailViewController: PhotoCellDelegate {
    func enlargeImage(forCell: PhotoCell) {
        if let photoIDs = locationToShow.photoID {
            if photoIDs.count > 0 {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier:"PhotoView") as! PhotoViewController
                controller.locationWithPhoto = locationToShow
                controller.showIndex = forCell.cellIndex
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

extension LocationDetailViewController: AddPhotoCellDelegate {
    func addPhoto(forCell: AddPhotoCell) {
        showPhotoMenu()
    }
}

extension LocationDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
