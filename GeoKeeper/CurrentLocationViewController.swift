//
//  FirstViewController.swift
//  GeoKeeper
//
//  Created by apple on 1/3/2017.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import MapKit

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    var managedObjectContext: NSManagedObjectContext!
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var locations = [Location]()
    var updatingLocation = false
    var lastLocationError: Error?
    var fetchedLocation: Location!
    var forPassLocation = MyLocation()
    var isVisited = false
    var isPunched = false
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    
    var timer: Timer?
    var image: UIImage?
        
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var nBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var portrait: UIButton!
    @IBOutlet weak var portraitImage: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    
    @IBAction func choosePortrait() {
        showPhotoMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let fetchedRequest = NSFetchRequest<Location>(entityName: "Location")
        fetchedRequest.entity = Location.entity()
        do {
            locations = try managedObjectContext.fetch(fetchedRequest)
        } catch {
            fatalCoreDataError(error)
        }
        
        if let location = location {
            for locationRecord in locations {
                if let placemarkRecord = locationRecord.placemark {
                    if addressLabel.text == string(from:placemarkRecord) {
                        forPassLocation = MyLocation.toMyLocation(coreDataLocation: locationRecord)
                        cityName.text = forPassLocation.locationName
                        //Repeated Punch is not allowed
                        let timeInterval = location.timestamp.timeIntervalSince(locationRecord.date)
                        if timeInterval < punchInterval {
                            isPunched = true
                        } else {
                            isPunched = false
                        }
                        isVisited = true
                    }
                }
            }
        }
        
        if isVisited == false {
            tagLabel.text = "Tag"
            messageLabel.text = "Tap 'Tag' to Save Location"
            if let placemark = placemark {
                cityName.text = placemark.locality
            }
            forPassLocation = MyLocation()
            
        } else if isPunched {
            tagLabel.text = "Detail"
            messageLabel.text = "Tap 'Detail' to Read Details"
        } else {
            tagLabel.text = "Punch"
            messageLabel.text = "Tap 'Punch' to Punch In"
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisited = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = baseColor
        mapView?.showsUserLocation = true
        updateLabels()
        setContainer()
        setPortrait()
    }
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.setTitleColor(baseColor, for: .normal)
            tagButton.isEnabled = true
            tagLabel.textColor = baseColor
            
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
                for locationRecord in locations {
                    if let placemarkRecord = locationRecord.placemark {
                        if addressLabel.text == string(from:placemarkRecord) {
                            forPassLocation = MyLocation.toMyLocation(coreDataLocation: locationRecord)
                            cityName.text = forPassLocation.locationName
                            //Repeated Punch is not allowed
                            let timeInterval = location.timestamp.timeIntervalSince(locationRecord.date)
                            if timeInterval < punchInterval {
                                isPunched = true
                            } else {
                                isPunched = false
                            }
                            isVisited = true
                        }
                    }
                }
                if isVisited == false {
                    if let locationName = placemark.locality {
                        cityName.text = locationName
                    } else {
                        cityName.text = "LocationName"
                    }
                }
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
            
            if isVisited == false {
                tagLabel.text = "Tag"
                messageLabel.text = "Tap 'Tag' to Save Location"
            } else if isPunched {
                tagLabel.text = "Detail"
                messageLabel.text = "Tap 'Detail' to Read Details"
            } else {
                tagLabel.text = "Punch"
                messageLabel.text = "Tap 'Punch' to Punch In"
            }
            
        } else {
            latitudeLabel.text = "Not available"
            longitudeLabel.text = "Not available"
            addressLabel.text = "My address"
            
            tagButton.isEnabled = false
            tagLabel.textColor = disableColor
            
            tagButton.setTitleColor(UIColor.gray, for: .normal)
            messageLabel.text = "Tap 'Get My Location' to Start"
            
            let statusMessage: String
            if let error = lastLocationError {
                if (error as NSError).domain == kCLErrorDomain && (error as NSError).code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
        }
    }

    
    func setContainer() {
        // set navigationBar
        nBar.barTintColor = baseColor
        nBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "TrebuchetMS-Bold", size: 17)!, NSForegroundColorAttributeName: UIColor.white]
        
        // set messageLabel
        messageLabel.font = UIFont(name: "TrebuchetMS-Italic", size: 16)
        messageLabel.textColor = secondColor
        
        // set cityName
        cityName.textColor = baseColor
        cityName.font = UIFont(name: "TrebuchetMS-Bold", size: 20)
        
        // set portrait button
        portrait.layer.cornerRadius = portrait.frame.size.width / 2
        portrait.layer.masksToBounds = true
        
        // set portraitImage
        portraitImage.layer.cornerRadius = portraitImage.frame.size.width / 2
        portraitImage.layer.masksToBounds = true
        portraitImage.layer.borderWidth = 1.5
        portraitImage.layer.borderColor = baseColor.cgColor
        
        // set tagButton
        tagLabel.text = "Tag"
        tagLabel.textColor = disableColor
    }
    
    func setPortrait() {
        let userDefaults = UserDefaults.standard
        let currentPortrait = userDefaults.string(forKey: "Portrait")
        if currentPortrait == "Default" {
            if let theImage = UIImage(named: "default") {
                show(image: theImage)
            }
        } else if currentPortrait == "MyPortrait" {
            if let theImage = portraitPhotoImage {
                show(image: theImage)
            }
        }
        userDefaults.synchronize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func getLocation() {
        isVisited = false
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            placemark = nil
            lastLocationError = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 500, 500)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
        
        let fetchedRequest = NSFetchRequest<Location>(entityName: "Location")
        fetchedRequest.entity = Location.entity()
        do {
            locations = try managedObjectContext.fetch(fetchedRequest)
        } catch {
            fatalCoreDataError(error)
        }
        
        updateLabels()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailViewController
            controller.managedObjectContext = managedObjectContext
            controller.delegate = self
            
            forPassLocation.locationName = cityName.text!
            if tagLabel.text == "Tag" {
//                forPassLocation.locationCategory = "All"
                forPassLocation.placemark = placemark
                forPassLocation.latitude = (location?.coordinate.latitude)!
                forPassLocation.longitude = (location?.coordinate.longitude)!
                forPassLocation.date = (location?.timestamp)!
                forPassLocation.punch = 1;
            } else if tagLabel.text == "Punch" {
                forPassLocation.punch = (Int(forPassLocation.punch) + 1) as NSNumber
                for locationRecord in locations {
                    if let placemarkRecord = locationRecord.placemark {
                        if addressLabel.text == string(from:placemarkRecord) {
                            locationRecord.date = (location?.timestamp)!
                            locationRecord.punch = (Int(forPassLocation.punch) + 1) as NSNumber
                        }
                    }
                }
                saveToCoreData(managedObjectContext)
            } else if tagLabel.text == "Detail" {
                
            }
            controller.locationToShow = forPassLocation
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError\(error)")
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            updateLabels()
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                stopLocationManager()
                
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            
            if !performingReverseGeocoding {
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
                    placemarks, error in
                    self.lastGeocodingError = error
                    if error == nil, let p = placemarks, !p.isEmpty {
                        self.placemark = p.last!
                    } else {
                        self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
            }
        } else if distance < 1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            
            if  timeInterval > punchInterval {
                stopLocationManager()
                updateLabels()
            }
        }
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        }
    }
    
    func didTimeOut () {
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        
        if let s = placemark.subThoroughfare {
            line1 += s + " "
        }
        
        if let s = placemark.thoroughfare {
            line1 += s
        }
        
        var line2 = ""
        
        if let s = placemark.locality {
            line2 += s + " "
        }
        if let s = placemark.administrativeArea {
            line2 += s + " "
        }
        if let s = placemark.postalCode {
            line2 += s
        }
        
        return line1 + "\n" + line2
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler:nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func show(image: UIImage) {
        portraitImage.image = image
        portraitImage.isHidden = false
    }
    
    func saveImage(image: UIImage) {
        if let data = UIImageJPEGRepresentation(image, 0.5) {
            do {
                try data.write(to: portraitPhotoURL, options: .atomic)
            } catch {
                print("Error writing file: \(error)")
            }
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set("MyPortrait", forKey: "Portrait")
    }
}

extension CurrentLocationViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension CurrentLocationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    
    func choosePhotoFromLibrary() {
        let imagePicker = MyImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if let theImage = image {
            show(image: theImage)
            saveImage(image: theImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension CurrentLocationViewController: LocationDetailViewControllerDelegate {
    func passLocation(location: MyLocation) {
        cityName.text = location.locationName
    }
}
