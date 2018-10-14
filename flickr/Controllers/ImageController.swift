//
//  ImageController.swift
//  flickr
//
//  Created by Jade McPherson on 10/13/18.
//  Copyright © 2018 Jade McPherson. All rights reserved.
//

import UIKit
import ProcedureKit
import SwiftyJSON

protocol ImageObserver: class {
    func newImagesLoaded()
}

class ImageController {
    static let shared = ImageController()
    
    //MARK :- Observer functions
    fileprivate static var Observers = ControllerObserver<ImageObserver>()
    
    static func AddObserver(_ observer: ImageObserver) {
        ImageController.Observers.addObserver(observer)
    }
    
    static func RemoveObserver(_ observer: ImageObserver) {
        ImageController.Observers.removeObserver(observer)
    }
    
    fileprivate static func NotifyObserversImagesFetched(page: Int) {
        ImageController.Observers.invoke { (o) in
            o.newImagesLoaded() // TODO: will the VC eventually care about the page number?
        }
    }
    
    fileprivate var imageUrlStrings: [Int: String] = [:] // TODO: use an ImageData model in the future to capture more than just url strings
    fileprivate var currentSearchTerm: String? // TODO: consider saving search history in memory
    fileprivate let imageCache = NSCache<NSString, UIImage>()
    
    func loadImageJsonData(_ json: JSON, page: Int) {
        let imageJsonData = json["photos"]["photo"].arrayValue
        guard imageJsonData.count > 0 else {return }
        for (index, imageData) in imageJsonData.enumerated() {
            if let imageUrlString = imageData["url_s"].string {
                imageUrlStrings[index] = imageUrlString
            }
        }
        ImageController.NotifyObserversImagesFetched(page: page)
    }
    
    //    TODO: first check if we're already fetched images for the given search term/page number
    func fetchImages(searchTerm: String, page: Int) {
        if currentSearchTerm != searchTerm {
            imageUrlStrings = [:]
        }
        currentSearchTerm = searchTerm
        let fetchImageOp = SearchImagesOperation(searchTerm: searchTerm, page: 1)
        fetchImageOp.add(observer: DidFinishObserver { (operation, errs) in
            if errs.isEmpty, let op = operation as? SearchImagesOperation, let result = op.result {
                self.loadImageJsonData(result, page: page)
            }
        })
        
        BackgroundQueue.addOperation(fetchImageOp)
    }
    
    func getImageByIndex(_ index: Int, _ completion: @escaping ((UIImage?) -> Void)) {
        guard let urlString = imageUrlStrings[index] else {
            completion(nil)
            return
        }
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            completion(cachedImage)
        } else {
            let imageOp = GetImageOperation(imagePath: urlString)
            imageOp.add(observer: DidFinishObserver {(operation, errors) in
                guard let op = operation as? GetImageOperation, let image = op.result, errors.isEmpty else {
                    completion(nil)
                    return
                }
                self.imageCache.setObject(image, forKey: urlString as NSString)
                completion(image)
            })
            BackgroundQueue.add(operation: imageOp)
        }
    }
    
    func imageCount() -> Int {
        return imageUrlStrings.count > 0 ? imageUrlStrings.count : 8
    }
}
