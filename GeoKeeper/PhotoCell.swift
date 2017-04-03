//
//  PhotoCell.swift
//  GeoKeeper
//
//  Created by apple on 31/3/2017.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit

protocol PhotoCellDelegate {
    func changeColorOfButton(forCell: PhotoCell)
}

class PhotoCell: UICollectionViewCell {
    
    var photoImageView: UIImageView!
    var deleteButton: UIButton!
    var delegate: PhotoCellDelegate? = nil
    
    override func awakeFromNib() {
        photoImageView = UIImageView(frame: contentView.frame)
        photoImageView.contentMode = .scaleToFill
        photoImageView.clipsToBounds = true
        photoImageView.layer.cornerRadius = 4
        photoImageView.layer.masksToBounds = true
        contentView.addSubview(photoImageView)
        
        deleteButton = UIButton(frame: CGRect(x: (contentView.frame.origin.x + 5), y: (contentView.frame.origin.y + 5), width: 15, height: 15))
        let backgroundImage = UIImage(named: "deleteButton_Orange") as UIImage?
        deleteButton.setImage(backgroundImage, for: .normal)
        deleteButton.addTarget(self, action: #selector(deletePhoto), for: .touchUpInside)
        contentView.addSubview(deleteButton)
    }
    
    func deletePhoto() {
        delegate?.changeColorOfButton(forCell: self)
    }

}
