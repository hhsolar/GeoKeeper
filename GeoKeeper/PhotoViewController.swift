//
//  PhotoViewController.swift
//  GeoKeeper
//
//  Created by apple on 2/5/2017.
//  Copyright © 2017 204. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    var showIndex = 0
    var count = 0
    
    var locationWithPhoto = MyLocation()
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Photos"
        
        setupScrollView()
        scrollView.delegate = self
        self.view.addSubview(scrollView)
    }

    func setupScrollView() {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 64, width: kScreenWidth, height: kScreenHeight - 64))
        scrollView.backgroundColor = grayColor
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        
        if let photoIDs = locationWithPhoto.photoID {
            count = photoIDs.count
            
            scrollView.contentSize = CGSize(width: scrollView.bounds.size.width * CGFloat(count), height: scrollView.bounds.size.height - 64)

            for i in 0..<count {
                let imageView = UIImageView(frame: CGRect(x: scrollView.frame.width * CGFloat(i), y: -64, width: scrollView.frame.width, height: scrollView.frame.height))
                let index = photoIDs[i]
                imageView.image = locationWithPhoto.photoImages(photoIndex: Int(index))
                imageView.contentMode = UIViewContentMode.scaleAspectFit
                scrollView.addSubview(imageView)

            }
            scrollView.contentOffset = CGPoint(x: Int(kScreenWidth) * showIndex, y: 0)
        } else if imageArray.count > 0 {
            scrollView.contentSize = CGSize(width: scrollView.bounds.size.width * CGFloat(imageArray.count), height: scrollView.bounds.size.height - 64)

            for i in 0..<imageArray.count {
                let imageView = UIImageView(frame: CGRect(x: scrollView.frame.width * CGFloat(i), y: -64, width: scrollView.frame.width, height: scrollView.frame.height))
                imageView.image = imageArray[i]
                imageView.contentMode = UIViewContentMode.scaleAspectFit
                scrollView.addSubview(imageView)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
