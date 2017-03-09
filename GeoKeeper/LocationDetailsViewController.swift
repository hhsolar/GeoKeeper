//
//  LocationDetailsViewController.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/1/17.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

class LocationDetailsViewController:UITableViewController {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    var managedObjectContext: NSManagedObjectContext!
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var categoryName = "No Category"
    var date = Date()
    var image: UIImage?
    var observer: AnyObject!

    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    var descriptionText = ""
    
    func show(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        imageView.frame = CGRect(x:10, y:10, width: 260, height: 260)
        addPhotoLabel.isHidden = true
    }
    
//    deinit {
//        print("*** deinit \(self)")
//        NotificationCenter.default.removeObserver(observer)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let location = locationToEdit {
            title = "Edit Location"
        }
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = ""
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        categoryLabel.text = categoryName
        dateLabel.text = formatDate(date: date)
        
        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark: placemark)
        } else {
            addressLabel.text = "No Adddress Found"
        }
        dateLabel.text = formatDate(date: date)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(gestureRecognizer:)))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }

    
    func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if indexPath != nil && indexPath!.section == 0  && indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }
    
    func formatDate(date:Date) -> String {
        return dateFormatter.string(from: date)
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
            text += s + ","
        }
        if let s = placemark.country {
            text += s
        }
        
        return text
    }
    
    @IBAction func done() {
        let hudView = HudView.hudInView(view: navigationController!.view, animated: true)
        let location: Location
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
        } else {
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext)
        }
        
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        do {
            try managedObjectContext.save()
            afterDelay(seconds: 0.6) {
                self.dismiss(animated: true, completion: nil)
            }
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    
    
    //Mark - UITableViewDelegate
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            pickPhoto()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return 88
        case (1, _):
            return imageView.isHidden ? 44 : 280
        case (2, 2):
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20
        default:
            return 44
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    
}

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibray()
        }
    }
    
    func takePhotoWithCamera() {
        let imagePicker = MyImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibray() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        if let theImage = image {
            show(image: theImage)
        }
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    

    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: {_ in self.takePhotoWithCamera()})
        alertController.addAction(takePhotoAction)
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in self.choosePhotoFromLibray()})
        alertController.addAction(chooseFromLibraryAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func listenForBackgroundNotification() {
        observer = NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidEnterBackground, object: nil, queue: OperationQueue.main) {
            [weak self] _ in
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil{
                    strongSelf.dismiss(animated: false, completion: nil)
                }
                strongSelf.descriptionTextView.resignFirstResponder()
            }
        
        }
    }
}
