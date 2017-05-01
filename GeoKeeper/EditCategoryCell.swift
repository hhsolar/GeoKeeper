//
//  EditCategoryCell.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 4/4/17.
//  Copyright © 2017 204. All rights reserved.
//


import UIKit

class EditCategoryCell: UICollectionViewCell {
    @IBOutlet weak var EditCategoryImageView: UIImageView!
    @IBOutlet weak var EditCategoryLabel: UILabel!
    
    var photoImageView: UIImageView!
    var deleteButton: UIButton!
    var delegate: PhotoCellDelegate? = nil
    
    
    deleteButton = UIButton(frame: CGRect(x: (contentView.frame.origin.x + 5), y: (contentView.frame.origin.y + 5), width: 15, height: 15))
    let backgroundImage = UIImage(named: "deleteButton_Orange") as UIImage?
    deleteButton.setImage(backgroundImage, for: .normal)
    contentView.addSubview(deleteButton)
}
