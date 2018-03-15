//
//  Pass.swift
//  ISSPassCodingChallenge
//
//  Created by Kiyoshi Woolheater on 3/13/18.
//  Copyright © 2018 Kiyoshi Woolheater. All rights reserved.
//

import Foundation

class Pass: NSObject {
    var duration: String?
    var timestamp: String?
}

class PassArray: NSObject {
    var array = [Pass]()
    
    class func sharedInstance() -> PassArray {
        struct Singleton {
            static var sharedInstance = PassArray()
        }
        return Singleton.sharedInstance
    }
}
