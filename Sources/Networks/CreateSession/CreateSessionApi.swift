//
//  CreateSessionApi.swift
//  Networks
//
//  Created by GetGroup on 22/10/2024.
//

import Foundation
import Moya

public enum CreateSessionApi {
    case createSessionForUser(data: String)
}

extension CreateSessionApi: TargetType, BaseHeader {

    public var path: String {
        switch self {
        case .createSessionForUser:
            return EndPoints.CreateSession.createSessionForUser.rawValue
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .createSessionForUser:
            return .post
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .createSessionForUser(let data):
            return .requestData(data.data(using: .utf8)!)
        }
    }

    public var baseURL: URL {
        return URL(string: Bundle.IssuerBaseURL())!
    }
    
    var commonHeaders: [String : String] {
        switch self {
        case .createSessionForUser(let data):
            return ["Content-Type": "application/json-patch+json","accept": "text/plain"]
        }
    }
}

