//
//  AddPhotoCell.swift
//  GeoKeeper
//
//  Created by apple on 15/5/2017.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit

protocol AddPhotoCellDelegate {
    func addPhoto(forCell: AddPhotoCell)
}

class AddPhotoCell: UICollectionViewCell {
    
    var addButton: UIButton!
    var buttonImageView: UIImageView!
    var delegate: AddPhotoCellDelegate? = nil
    
    override func awakeFromNib() {
        buttonImageView = UIImageView(frame: contentView.frame)
        buttonImageView.clipsToBounds = true
        buttonImageView.layer.cornerRadius = 4
        buttonImageView.layer.masksToBounds = true
        
        addButton = UIButton(frame: contentView.frame)
        addButton.clipsToBounds = true
        addButton.layer.cornerRadius = 4
        addButton.layer.masksToBounds = true
        addButton.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        
        contentView.addSubview(buttonImageView)
        contentView.addSubview(addButton)
    }
    
    func addImage() {
        delegate?.addPhoto(forCell: self)
    }
    
}
