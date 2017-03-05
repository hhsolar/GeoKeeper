//
//  Functions.swift
//  GeoKeeper
//
//  Created by Jingfu Ju on 3/5/17.
//  Copyright © 2017 204. All rights reserved.
//

import Foundation
import Dispatch

func afterDelay(seconds: Double, closure: @escaping () -> ()) {
    let when = DispatchTime.now() + seconds
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}
