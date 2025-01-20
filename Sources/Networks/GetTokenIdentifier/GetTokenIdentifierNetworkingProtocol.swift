//
//  File.swift
//  Networks
//
//  Created by GetGroup on 09/01/2025.
//

import Foundation
public protocol GetTokenIdentifierNetworkingProtocol {
    func authanticateApplication(compeletion: @escaping(Result<AuthanticateApplicationResponse, Error>)-> Void)
    func validateUser(sessionDataKey: String, nationalId: String, completion: @escaping(Result<ValidateUserResponse, Error>)-> Void)
    func validatePassword(nationalId: String, compeletion: @escaping(Result<ValidatePasswordResponse, Error>)-> Void)
    func validateOtp(sessionDataKey: String, otp: String, compeltion: @escaping(Result<ValidateOtpResponse, Error>)-> Void)
}

extension GetTokenIdentifierNetworkingProtocol {
    var repo: GetTokenIdentifierRepo {
        return GetTokenIdentifierRepo()
    }
    
    func validateUser(sessionDataKey: String, nationalId: String, completion: @escaping(Result<ValidateUserResponse, Error>)-> Void) {
        repo.defaultRequest(target: .validateUser(sessionDataKey: sessionDataKey, nationalId: nationalId), completion: completion)
    }
    
    func authanticateApplication(compeletion: @escaping(Result<AuthanticateApplicationResponse, Error>)-> Void) {
        repo.defaultRequest(target: .authanticateApplication, completion: compeletion)
    }
    
    func validatePassword(nationalId: String, compeletion: @escaping(Result<ValidatePasswordResponse, Error>)-> Void) {
        repo.defaultRequest(target: .validatePasseword(nationalId: nationalId), completion: compeletion)
    }
    
    func validateOtp(sessionDataKey: String, otp: String, compeltion: @escaping(Result<ValidateOtpResponse, Error>)-> Void) {
        repo.defaultRequest(target: .validateOtp(sessionDataKey: sessionDataKey, otp: otp), completion: compeltion)
    }
}
