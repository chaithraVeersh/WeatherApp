//
//  NetworkHandler.swift
//  WeatherApp
//
//  Created by Chaithra T V on 17/02/20.
//  Copyright © 2020 Chaithra TV. All rights reserved.
//

import Foundation

class NetworkHandler {
    func getData(urlString: String, completion: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            return
        }

        if Reach().isNetworkReachable() == true {
            let request = URLRequest(url: url)
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let responseData = data else {
                    completion(nil, error)
                    return
                }
                completion(responseData, nil)
            }.resume()
        }
    }
    
     func postData(params:String, urlString:String, completionHandler:@escaping (_ dict:AnyObject?, _ error: NSError?) -> ())
    {
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = params.data(using: .utf8)
        
        if Reach().isNetworkReachable() == true {
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for
                    print("error=\(String(describing: error))")
                    completionHandler(nil, error! as NSError)
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                        completionHandler(json, nil)
                    }
                } catch let error {
                    print(error.localizedDescription)
                    completionHandler(nil, error as NSError)
                }
            }
            task.resume()
        }
        else {
            completionHandler(nil, self.noNetworkError())
        }
    }
    
    func noNetworkError() ->  NSError
    {
        let userInfo: [String : Any] =
            [
                NSLocalizedDescriptionKey :  NSLocalizedString("Connection Failed", value: "Please check your internet connnection", comment: "") ,
                NSLocalizedFailureReasonErrorKey : NSLocalizedString("Connection Failed", value: "Please check your internet connnection", comment: "")
        ]
        return NSError(domain: "", code: 1001, userInfo: userInfo)
    }
}
