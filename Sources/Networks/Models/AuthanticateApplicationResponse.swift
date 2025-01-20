//
//  File.swift
//  Networks
//
//  Created by GetGroup on 09/01/2025.
//

import Foundation
public struct AuthanticateApplicationResponse: Codable {
    let clientKeyAplicacion, cedulaUsuario, claveUsuario: String?
    let respuesta, sessionDataKey, mensaje: String?
    let tokenAcceso: String?
}
