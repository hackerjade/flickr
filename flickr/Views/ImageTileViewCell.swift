//
//  ImageTileView.swift
//  flickr
//
//  Created by Jade McPherson on 10/13/18.
//  Copyright © 2018 Jade McPherson. All rights reserved.
//

import Foundation
import UIKit

class ImageTileViewCell: UICollectionViewCell {
    static let identifer = "kImageTileViewCell"
    
    var imageView = UIImageView()
    var imageRequest: GetImageOperation? = nil
    
    var image: UIImage? {
        didSet {
            if let i = image {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                        self.imageView.image = i
                        self.alpha = 1.0
                    }, completion: nil)
                    
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.autoresizesSubviews = true
        
        imageView.frame = self.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(imageView)
        
        backgroundColor = .lightGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageRequest?.cancel()
    }
}
