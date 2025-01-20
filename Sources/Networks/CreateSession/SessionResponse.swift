//
//  CreateSessionResponse.swift
//  SessionWithNationalId
//
//  Created by GetGroup on 28/10/2024.
//

import Foundation
public struct SessionResponse: Codable {
    public let totpSecretKey, data, customerId: String

    enum CodingKeys: String, CodingKey {
        case totpSecretKey = "TotpSecretKey"
        case data = "Data"
        case customerId = "CustomerId"
    }
}
