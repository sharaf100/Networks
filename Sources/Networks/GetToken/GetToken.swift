//
//  GetToken.swift
//  DLCitizen
//
//  Created by GetGroup on 09/10/2024.
//  Copyright © 2024 Scytales. All rights reserved.
//

import Foundation
import Moya

enum GetToken {
    case getTokenForCitizen(data: String)
}

extension GetToken: TargetType, BaseHeader {

    public var path: String {
        switch self {
        case .getTokenForCitizen:
            return EndPoints.GetToken.getTokenForCitizen.rawValue
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getTokenForCitizen:
            return .post
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .getTokenForCitizen(let data):
            return .requestData(data.data(using: .utf8)!)
        }
    }
    
    var baseURL: URL {
        return URL(string: Bundle.holderBaseURL())!
    }

}

protocol BaseHeader {
    var commonHeaders: [String: String] { get }
}

extension BaseHeader {
    public var headers:[String:String]? {
        return commonHeaders
    }
    
    var commonHeaders: [String: String] {
        return ["Content-Type": "application/json; charset=UTF-8"]
    }
}
