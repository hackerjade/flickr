//
//  SearchImagesOperation.swift
//  flickr
//
//  Created by Jade McPherson on 10/13/18.
//  Copyright © 2018 Jade McPherson. All rights reserved.
//

import ProcedureKit
import Alamofire
import SwiftyJSON

public let BackgroundQueue: ProcedureQueue = {
    let queue = ProcedureQueue()
    queue.name = "background.api.queue"
    queue.maxConcurrentOperationCount = 2
    
    return queue
}()

class SearchImagesOperation: APIOperation {
    var result: JSON?
    var request: DataRequest? = nil
    var searchTerm: String
    var page: Int = 1
    
    init(searchTerm: String, page: Int) {
        self.searchTerm = searchTerm
        self.page = page
        
        super.init()
    }
    
    func cancelRequest() {
        request?.cancel()
    }
    
    override func execute() {
        guard !isCancelled else { return }
        let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=675894853ae8ec6c242fa4c077bcf4a0&text=\(searchTerm)&extras=url_s&format=json&nojsoncallback=1&page=\(page)"  //TODO: move the api key into a server config
        
        let method: HTTPMethod = .get
        request = makeRequest(url: url, method: .get) { (results) in
            guard !self.isCancelled else { return self.finish() }
            switch results {
            case .success(let json):
                self.result = json
                self.finish()
                
            case .failure(let error):
                self.finish(withError: error)
            }
        }
        
        print("\(Date())[\(method)]")
    }
}
