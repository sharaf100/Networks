//
//  File.swift
//  Networks
//
//  Created by GetGroup on 09/01/2025.
//

import Foundation
public struct ValidateOtpResponse: Codable {
    let cedulaUsuario, claveUsuario, clientKeyAplicacion: String?
    let mensaje, respuesta: String?
    let sessionDataKey: String?
    let tokenAcceso: String?
}
