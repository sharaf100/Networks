//
//  EndPoints.swift
//  DLCitizen
//
//  Created by GetGroup on 09/10/2024.
//  Copyright © 2024 Scytales. All rights reserved.
//

import Foundation
internal import MdlModels
enum EndPoints {
    enum GetToken: String {
        case getTokenForCitizen = "Citizen/CitizenGetToken"
    }
    
    enum GetTokenIdentifier: String {
        case authanticateApplication = "autenticarAplicacion"
        case validateUser = "validarUsuario"
        case validatePassword = "validarUsuarioPassword"
        case validateOtp = "validarTotp"
    }
    
    enum CreateSession: String {
        case createSessionForUser = "mdl/Issue"
    }
}
