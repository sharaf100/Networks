//
//  Data+extension.swift
//  DLCitizen
//
//  Created by GetGroup on 09/10/2024.
//  Copyright © 2024 Scytales. All rights reserved.
//

import Foundation
extension Data {
     var prettyPrinted: NSString? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return ""}
         return prettyPrintedString
    }
    
    var asDictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: self, options: .allowFragments)).flatMap({$0 as? [String: Any]})  ?? [:]
    }
}
