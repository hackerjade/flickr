//
//  APIOperation.swift
//  flickr
//
//  Created by Jade McPherson on 10/13/18.
//  Copyright © 2018 Jade McPherson. All rights reserved.
//

import Foundation
import ProcedureKit
import Alamofire
import SwiftyJSON

enum ServiceResults<JSON> {
    case success(JSON)
    case failure(NSError)
}

class APIOperation: Procedure {
    func makeRequest(url: String, method: HTTPMethod, _ completion: @escaping ((ServiceResults<JSON>) -> Void)) -> DataRequest {
        let request = Alamofire.request(url, method: method, parameters: nil, encoding: JSONEncoding.default, headers: [:])
        
        request.responseJSON { (response: DataResponse<Any>) in
            let err = NSError(domain: "server", code: response.response?.statusCode ?? 0, userInfo: nil)
            var result: ServiceResults<JSON> = .failure(err) // TODO: pass descriptive error to result
            
            switch response.result {
            case .success(let data):
                if response.response?.statusCode ?? 0 == 200 {
                    let json = JSON(data)
                    result = .success(json)
                }
            default: break
            }
            
            completion(result)
        }
        
        return request
    }
}
