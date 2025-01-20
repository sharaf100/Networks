//
//  File.swift
//  Networks
//
//  Created by GetGroup on 09/01/2025.
//

import Foundation
import Moya

enum GetTokenIdentifier {
    case authanticateApplication
    case validateUser(sessionDataKey: String, nationalId: String)
    case validatePasseword(nationalId: String)
    case validateOtp(sessionDataKey: String, otp: String)
}

extension GetTokenIdentifier: TargetType, BaseHeader {

    public var path: String {
        switch self {
        case .authanticateApplication:
            return EndPoints.GetTokenIdentifier.authanticateApplication.rawValue
        case .validateUser:
            return EndPoints.GetTokenIdentifier.validateUser.rawValue
        case .validatePasseword:
            return EndPoints.GetTokenIdentifier.validatePassword.rawValue
        case .validateOtp:
            return EndPoints.GetTokenIdentifier.validateOtp.rawValue
        }
    }
    
    public var method: Moya.Method {
        return .post
    }
    
    public var task: Moya.Task {
        switch self {
        case .authanticateApplication:
            return .requestParameters(parameters: [ "urlAplicacion":"https://sau.dinardap.gob.ec/sau-administracion/index.html",
                                                    "clientKeyAplicacion":"JjkzhQS3YdB_MJNd5lq9XGZRbvQa",
                                                    "clientSecretAplicacion":"ZAIbqPFZg7Hs8dB02gffeVHOYXQa"], encoding: JSONEncoding.default)
        case .validateUser(let sessionDataKey, let nationalId):
            return .requestParameters(parameters: ["cedulaUsuario": nationalId, "sessionDataKey": sessionDataKey], encoding: JSONEncoding.default)
        case .validatePasseword( let nationalId):
            return .requestParameters(parameters: ["urlAplicacion":"www.gob.ec", // obligatorio
                                                   "clientKeyAplicacion":"JjkzhQS3YdB_MJNd5lq9XGZRbvQa",
                                                   "cedulaUsuario": nationalId,
                                                   "claveUsuario": "Anderson1997"], encoding: JSONEncoding.default)
        case .validateOtp(let sessionDataKey, let otp):
            return .requestParameters(parameters: ["sessionDataKey":sessionDataKey,
                                                   "totp": otp], encoding: JSONEncoding.default)
        }
    }
    
    var baseURL: URL {
        return URL(string: "http://52.179.176.215:10000/api/sau/")!
    }

}
