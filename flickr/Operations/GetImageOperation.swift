//
//  GetImageOperation.swift
//  flickr
//
//  Created by Jade McPherson on 10/13/18.
//  Copyright © 2018 Jade McPherson. All rights reserved.
//

import ProcedureKit
import SwiftyJSON
import Alamofire
import AlamofireImage

class GetImageOperation: APIOperation {
    var result: UIImage?
    var request: DataRequest?
    let imagePath: String
    
    init(imagePath: String) {
        self.imagePath = imagePath //"https://farm2.staticflickr.com/1914/44389053165_b9b416ab3b_m.jpg"
        super.init()
    }
    
    override func execute() {
        guard !isCancelled else { return }
        
        let imageRequest = Alamofire.request(imagePath)
        
        imageRequest.responseImage { response in
            guard !self.isCancelled else { return self.finish() }
            switch response.result {
            case .success(let img):
                self.result = img
                self.finish()
            case .failure(let e):
                self.finish(withError: e)
            }
        }
        request = imageRequest
        print("\(Date())[MM]\(imagePath)")
    }
}
