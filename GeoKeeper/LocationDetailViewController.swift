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
    
    let apiKey = "64061cb2cff1e380d2011f5ad50d3bf8"
    
    var temp = ""
    var weather = ""
    var w_icon = ""
    
    fileprivate let reuseIdentifier = "PhotoCell"
    
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
        dismiss(animated: true, completion: nil);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditDetail" {
            let controller = segue.destination as! LocationDetailEditViewController
            controller.locationToEdit = locationToShow
            
            controller.portraitViewFrame = portraitImage.frame
            controller.nameTextFrame = locationNameLabel.frame
            controller.categoryFrame = categoryLabel.frame
            
            controller.collectionFrame = CGRect(x: conbinationView.frame.origin.x + photoCollectionView.frame.origin.x, y: conbinationView.frame.origin.y + photoCollectionView.frame.origin.y, width: photoCollectionView.frame.width, height: photoCollectionView.frame.height)
            controller.addImageButtonFrame = CGRect(x: conbinationView.frame.origin.x + mapAppButton.frame.origin.x, y: conbinationView.frame.origin.y + mapAppButton.frame.origin.y, width: mapAppButton.frame.width, height: mapAppButton.frame.height)
            controller.remarkLabelFrame = remarkLabel.frame
            controller.remarkTextViewFrame = remarkTextView.frame
            
            controller.managedObjectContext = managedObjectContext
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
    
    // download data from openwWeatherAPI
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
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        var text = ""
        if let s = placemark.subThoroughfare {
            text += s + " "
        }
        if let s = placemark.thoroughfare {
            text += s + ","
        }
        if let s = placemark.locality {
            text += s + ","
        }
        if let s = placemark.administrativeArea {
            text += s + ","
        }
        if let s = placemark.postalCode {
            text += s
        }
        return text
    }
    
    func initCollectionView() {
        photoCollectionView.backgroundColor = grayColor
        photoCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        let layout = UICollectionViewFlowLayout()
        photoCollectionView.collectionViewLayout = layout
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        let itemHeight: CGFloat = photoCollectionView.frame.height - 10 * 2
        layout.itemSize = CGSize(width: itemHeight, height: itemHeight)
        
        layout.minimumLineSpacing = 8
        
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
}

extension LocationDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let photoIDs = locationToShow.photoID {
            if photoIDs.count > 0 {
                return photoIDs.count
            }
            return 1
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        cell.awakeFromNib()
        cell.delegate = self
        cell.deleteButton.isHidden = true
        cell.cellIndex = indexPath.row
        if let photoIDs = locationToShow.photoID {
            if photoIDs.count == 0 {
                cell.photoImageView.image = UIImage(named: "noPhoto_icon")
                return cell
            }
            let index = photoIDs[indexPath.row]
            cell.photoImageView.image = locationToShow.photoImages(photoIndex: Int(index))
        } else {
            cell.photoImageView.image = UIImage(named: "noPhoto_icon")
        }
        return cell
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
