//
//  AddPhotoCell.swift
//  GeoKeeper
//
//  Created by apple on 15/5/2017.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit

protocol AddPhotoCellDelegate {
    func addPhoto()
}

class AddPhotoCell: UICollectionViewCell {
    
    var addButton: UIButton!
    var delegate: AddPhotoCellDelegate? = nil
    
    override func awakeFromNib() {
        addButton = UIButton(frame: contentView.frame)
        let image = UIImage(named: "addPhotoIcon") as UIImage?
        addButton.setImage(image, for: .normal)
        addButton.clipsToBounds = true
        addButton.layer.cornerRadius = 4
        addButton.layer.masksToBounds = true
        addButton.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        
        contentView.addSubview(addButton)
    }
    
    func addImage() {
        delegate?.addPhoto()
    }
    
}
