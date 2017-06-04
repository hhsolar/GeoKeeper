//
//  LocationCell.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/6/17.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    func configure(for location: Location) {
//        if location.locationDescription.isEmpty {
//            descriptionLabel.text = "(No Description)"
//        } else {
            descriptionLabel.text = location.name
//        }
        if let placemark = location.placemark {
            var text = ""
            if let s = placemark.subThoroughfare {
                text += s + " "
            }
            if let s = placemark.thoroughfare {
                text += s + ", "
            }
            if let s = placemark.locality {
                text += s
            }
            addressLabel.text = text
        } else {
            addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
        }
        
        if location.hasPhoto {
            photoImageView.layer.cornerRadius = 5.0
            photoImageView.layer.borderWidth = 1
            photoImageView.layer.masksToBounds = true
            photoImageView.image = location.photoImage
        } else {
            photoImageView.image = locationDefaultImage
        }
    }
    
}
