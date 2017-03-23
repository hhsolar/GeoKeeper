//
//  RoundedCornersView.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/18/17.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedCornersView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
}
