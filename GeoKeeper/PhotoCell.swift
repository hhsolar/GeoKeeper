//
//  PhotoCell.swift
//  GeoKeeper
//
//  Created by apple on 31/3/2017.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit

@objc protocol PhotoCellDelegate {
    @objc optional func deleteImage(forCell: PhotoCell)
    @objc optional func enlargeImage(forCell: PhotoCell)
}

class PhotoCell: UICollectionViewCell {
    
    var photoImageView: UIImageView!
    var deleteButton: UIButton!
    var cellButton: UIButton!
    var cellIndex = -1
    var delegate: PhotoCellDelegate? = nil
    
    override func awakeFromNib() {
        photoImageView = UIImageView(frame: contentView.frame)
        photoImageView.contentMode = .scaleToFill
        photoImageView.clipsToBounds = true
        photoImageView.layer.cornerRadius = 4
        photoImageView.layer.masksToBounds = true
        contentView.addSubview(photoImageView)
        
        cellButton = UIButton(frame: contentView.frame)
        cellButton.clipsToBounds = true
        cellButton.layer.cornerRadius = 4
        cellButton.layer.masksToBounds = true
        cellButton.addTarget(self, action: #selector(enlargeImage), for: .touchUpInside)
        contentView.addSubview(cellButton)
        
        deleteButton = UIButton(frame: CGRect(x: (contentView.frame.origin.x + 5), y: (contentView.frame.origin.y + 5), width: 15, height: 15))
        let backgroundImage = UIImage(named: "deleteButton_Orange") as UIImage?
        deleteButton.setImage(backgroundImage, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
        contentView.addSubview(deleteButton)
    }
    
    func deleteImage() {
        delegate?.deleteImage!(forCell: self)
    }
    
    func enlargeImage() {
        delegate?.enlargeImage!(forCell: self)
    }

}
