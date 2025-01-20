//
//  File.swift
//  Networks
//
//  Created by GetGroup on 09/01/2025.
//

import Foundation
public struct ValidateUserResponse: Codable {
    let clientKeyAplicacion, cedulaUsuario, claveUsuario: String?
    let respuesta: String?
    let sessionDataKey: String?
    let mensaje: String?
    let tokenAcceso: String?
}
