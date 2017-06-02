//
//  CategoryCell.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/20/17.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var itemsCountLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10.0
        let width = frame.width
        categoryImageView?.contentMode = UIViewContentMode.scaleAspectFit
        categoryLabel?.frame = CGRect(x:0, y:width - 40, width:width, height:20)
        categoryLabel?.font = UIFont(name: "TrebuchetMS-Bold", size: 13)
        categoryLabel?.textAlignment = .center
        contentView.addSubview(categoryLabel)
    }
}
