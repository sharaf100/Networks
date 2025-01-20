//
//  ServiceType.swift
//  DLCitizen
//
//  Created by GetGroup on 09/10/2024.
//  Copyright © 2024 Scytales. All rights reserved.
//

import Foundation

enum ResponseStatus:String,Codable {
    case success = "success"
    case fail = "fail"
}

struct BaseResponse<T:Codable>:Codable {
    let message: [String]?
    let status: ResponseStatus?
    let response: T?
    let code: Int?
   
}

enum ServiceType:String {
    case live = "live"
    case test = "test"
}
