//
//  File.swift
//  Networks
//
//  Created by GetGroup on 09/01/2025.
//

import Foundation
// MARK: - ValidatePasswordResponse
public struct ValidatePasswordResponse: Codable {
    let cedulaUsuario, claveUsuario, clientKeyAplicacion: String?
    let mensaje, respuesta, sessionDataKey: String?
    let tokenAcceso: String?
}
