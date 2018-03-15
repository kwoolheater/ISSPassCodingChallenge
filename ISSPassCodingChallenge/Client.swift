//
//  Client.swift
//  ISSPassCodingChallenge
//
//  Created by Kiyoshi Woolheater on 3/14/18.
//  Copyright © 2018 Kiyoshi Woolheater. All rights reserved.
//

import Foundation

class Client: NSObject {
    
    // create a session to call api through
    let sharedSession = URLSession.shared
    
    // call api and save data in PassArray to be displayed on tableview
    func callAPI(latitude: String, longitude: String, completionHandlerForAPICall: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> URLSessionDataTask {
        // create url request
        let url = URL(string: "http://api.open-notify.org/iss-pass.json?lat=\(latitude)&lon=\(longitude)")
        let urlRequest = URLRequest(url: url!)
        
        let task = sharedSession.dataTask(with: urlRequest) { data, response, error in
            // if an error occurs and print it
            func displayError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                print(userInfo)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                let userInfo = [NSLocalizedDescriptionKey : "There was a network error. Check your connection."]
                completionHandlerForAPICall(false, NSError(domain: "Task", code: 1, userInfo: userInfo))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                let userInfo = [NSLocalizedDescriptionKey : "There was a network error. Check your connection."]
                completionHandlerForAPICall(false, NSError(domain: "Task", code: 1, userInfo: userInfo))
                return
            }
            
            // Parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            // sort through the result to create an array of data in PassArray class
            for (key, result) in parsedResult {
                
                if key == "response" {
                    guard let array = result as? NSArray else {
                        displayError("Could not cast \(result)")
                        return
                    }
                    
                    for items in array {
                        guard let pass = items as? NSDictionary else {
                            displayError("Could not cast \(items)")
                            return
                        }
                        
                        let newPass = Pass.init()
                        
                        for (key, value) in pass {
                            
                            // convert duration to a string from nsnumber
                            if key as? String == "duration" {
                                let duration = value as! NSNumber
                                newPass.duration = String(describing: duration)
                            }
                            
                            // convert unix time stamp to readable date
                            if key as? String == "risetime" {
                                let unixTimestamp = value as? Double
                                let date = Date(timeIntervalSince1970: unixTimestamp!)
                                let dateFormatter = DateFormatter()
                                dateFormatter.timeZone = TimeZone(abbreviation: "EST")
                                dateFormatter.locale = NSLocale.current
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                                let strDate = dateFormatter.string(from: date)
                                newPass.timestamp = strDate
                            }
                        }
                        
                        // add to pass to passarray
                        PassArray.sharedInstance().array.append(newPass)
                    }
                    
                    completionHandlerForAPICall(true, nil)
                }
            }
        }
        
        task.resume()
        return task
    }
    
    // create a shared instance 
    class func sharedInstance() -> Client {
        
        struct Singleton {
            static var sharedInstance = Client()
        }
        return Singleton.sharedInstance
    }
}
