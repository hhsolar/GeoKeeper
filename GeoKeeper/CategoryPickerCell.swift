//
//  CategoryPickerCell.swift
//  GeoKeeper
//
//  Created by apple on 9/4/2017.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit

class CategoryPickerCell: UITableViewCell {

    var categoryNameLabel: UILabel!
    var checkmarkImage: UIImageView!
    var isChecked = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryNameLabel = UILabel(frame: CGRect(x: contentView.frame.origin.x + 20, y: (contentView.frame.height - 20) / 2, width: 200, height: 20))
        categoryNameLabel.font = UIFont(name: "TrebuchetMS", size: 17)
        contentView.addSubview(categoryNameLabel)
        
        checkmarkImage = UIImageView(frame: CGRect(x: contentView.frame.width - 50, y: (contentView.frame.height - 20) / 2, width: 23, height: 23))
        contentView.addSubview(checkmarkImage)
    }
    
    func configure(name: String, chosen: Bool) {
        categoryNameLabel.text = name
        isChecked = chosen
        if isChecked {
            checkmarkImage.image = UIImage(named: "checked")
        } else {
            checkmarkImage.image = nil
        }
    }
    
    func toggleChecked() {
        if isChecked {
            checkmarkImage.image = nil
        } else {
            checkmarkImage.image = UIImage(named: "checked")
        }
        isChecked = !isChecked
    }
}
