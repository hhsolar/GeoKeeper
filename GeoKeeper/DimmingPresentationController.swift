//
//  DimmingPresentationController.swift
//  GeoKeeper
//
//  Created by apple on 27/3/2017.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    lazy var dimmingView = UIView(frame: CGRect.zero)
    
    override func presentationTransitionWillBegin() {
        
        dimmingView.frame = containerView!.bounds
        dimmingView.frame.size.height -= 64
        dimmingView.frame.origin.y += 64
        dimmingView.backgroundColor = UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 0.5)
        containerView!.insertSubview(dimmingView, at: 0)
                
        dimmingView.alpha = 0
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 1
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin()  {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0
            }, completion: nil)
        }
    }
}

