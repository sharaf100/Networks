//
//  CreateSessionNetworkingProtocol.swift
//  Networks
//
//  Created by GetGroup on 22/10/2024.
//

import Foundation

protocol CreateSessionNetworkingProtocol {
    func createUserSession(signedData: String, completion: @escaping(Result<SessionResponse, Error>)-> Void)
}

extension CreateSessionNetworkingProtocol {
    var repo: CreateSessionRepo {
        return CreateSessionRepo()
    }
    
    func createUserSession(
        signedData: String,
        completion: @escaping(Result<SessionResponse, Error>)-> Void) {
         repo.defaultRequest(target: .createSessionForUser(data: signedData), completion: completion)
    }
}
