//
//  GetTokenCitizenNetworkingProtocol.swift
//  DLCitizen
//
//  Created by GetGroup on 09/10/2024.
//  Copyright © 2024 Scytales. All rights reserved.
//

import Foundation
//
public protocol GetTokenCitizenNetworkingProtocol {
    func getTokenCitizen(signedData: String, completion: @escaping(Result<String, NetworkError>)-> Void)
}

extension GetTokenCitizenNetworkingProtocol {
    var repo: GetTokenRepo {
        return GetTokenRepo()
    }
    
    public func getTokenCitizen(signedData: String, completion: @escaping(Result<String, NetworkError>)-> Void) {
        repo.stringRequest(target: .getTokenForCitizen(data: signedData), completion: completion)
    }
}
