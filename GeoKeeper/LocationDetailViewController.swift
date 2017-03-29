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

class LocationDetailViewController: UIViewController {
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapKit: MKMapView!
    @IBOutlet weak var mapAppButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var remarkTextView: UITextView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var portraitImage: UIImageView!

    let baseColor = UIColor(red: 71/255.0, green: 117/255.0, blue: 179/255.0, alpha: 1.0)
    let secondColor = UIColor(red: 249/255.0, green: 171/255.0, blue: 86/255.0, alpha: 1.0)
    
    var managedObjectContext: NSManagedObjectContext!
    var categoryName = "No Category"
    var placemark: CLPlacemark?
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    let kScreenWidth = UIScreen.main.bounds.size.width
    let kScreenHeight = UIScreen.main.bounds.size.height
    
    let edgeW = CGFloat(3)
    let edgeH = CGFloat(6)
    let scrollViewHeight = UIScreen.main.bounds.size.height / 13 * 3
    let apiKey = "64061cb2cff1e380d2011f5ad50d3bf8"
    
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                categoryName = location.category
                placemark = location.placemark
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            }
        }
    }
    
    var temp = ""
    var weather = ""
    var w_icon = ""
    
    @IBAction func openMapsApp() {
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditDetail" {
            let controller = segue.destination as! LocationDetailEditViewController
            controller.managedObjectContext = managedObjectContext
            controller.nameText = locationNameLabel.text!
            controller.categoryName = categoryLabel.text!
            controller.remarkText = remarkTextView.text!
            controller.portraitImage = portraitImage.image!
        }
    }
    
    @IBAction func getBack() {
        dismiss(animated: true, completion: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = secondColor
        
        if let placemark = placemark {
            title = placemark.locality
            locationNameLabel.text = placemark.locality
            categoryLabel.text = categoryName
            addressLabel.text = stringFromPlacemark(placemark: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        setLocation(location: locationToEdit!)
        weatherSearch()
        
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
        remarkTextView.layer.cornerRadius = 5
        remarkTextView.layer.borderWidth = 1
        remarkTextView.layer.borderColor = UIColor.lightGray.cgColor

        // set weatherImageView
        weatherImageView.image = UIImage(named: w_icon)
        
        // set temperatureLabel
        temperatureLabel.textColor = baseColor
        temperatureLabel.font = UIFont(name: "TrebuchetMS", size: 16)
        temperatureLabel.text = "\(temp)C"
        
        scrollViewSetup()
    }
    
    // download data from openwWeatherAPI
    func weatherSearch() {
        let url = weatherURL(location: locationToEdit!)
        if let jsonString = performWeatherRequest(with: url) {
            if let jsonDictionary = parse(json: jsonString) {
                print("Dictionay \(jsonDictionary)")
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
    
    func weatherURL(location: Location) -> URL{
        let urlString = String(format: "http://api.openweathermap.org/data/2.5/weather?lat=%@&lon=%@&APPID=%@", String(location.latitude), String( location.longitude), apiKey)
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
    
    func setLocation(location: Location) {
        let latDelta = 0.05
        let longDelta = 0.05
        let currentLocationSpan: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        let currentRegion: MKCoordinateRegion = MKCoordinateRegion(center: location.coordinate, span: currentLocationSpan)
        
        mapKit.setRegion(currentRegion, animated: true)
        
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = location.coordinate
        mapKit.addAnnotation(objectAnnotation)
        
        mapKit.isZoomEnabled = true
    }
    
    // scrollView related
   
    func scrollViewSetup() {
        scrollView.contentSize = CGSize(width: scrollViewHeight * 5, height: scrollViewHeight)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor.lightGray
        scrollView.frame = CGRect(x: 0, y: (mapAppButton.frame.origin.y + mapAppButton.frame.height + 8), width: kScreenWidth, height: scrollViewHeight)
        
        addImageViewsToScrollView()
        setDefaultInfo()
    }
    
    func addImageViewsToScrollView() {
        
        let w = scrollViewHeight - edgeW * 2
        let h = scrollViewHeight - edgeH * 2
        
        var imageS1 = UIImageView(frame: CGRect(x: edgeW, y: edgeH, width: w, height: h))
        imageS1.backgroundColor = UIColor.white
        imageS1.layer.cornerRadius = 4
        
        var imageS2 = UIImageView(frame: CGRect(x: edgeW * 3 + w, y: edgeH, width: w, height: h))
        imageS2.backgroundColor = UIColor.white
        imageS2.layer.cornerRadius = 4

        var imageS3 = UIImageView(frame: CGRect(x: edgeW * 5 + w * 2, y: edgeH, width:w, height: h))
        imageS3.backgroundColor = UIColor.white
        imageS3.layer.cornerRadius = 4

        var imageS4 = UIImageView(frame: CGRect(x: edgeW * 7 + w * 3, y: edgeH, width: w, height: h))
        imageS4.backgroundColor = UIColor.white
        imageS4.layer.cornerRadius = 4

        var imageS5 = UIImageView(frame: CGRect(x: edgeW * 9 + w * 4, y: edgeH, width: w, height: h))
        imageS5.backgroundColor = UIColor.white
        imageS5.layer.cornerRadius = 4
        
        scrollView.addSubview(imageS1)
        scrollView.addSubview(imageS2)
        scrollView.addSubview(imageS3)
        scrollView.addSubview(imageS4)
        scrollView.addSubview(imageS5)
    }
    
    func setDefaultInfo() {
        
    }
    
    // load weather info
    
}
