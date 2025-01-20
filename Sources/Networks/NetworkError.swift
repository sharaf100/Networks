//
//  NetworkError.swift
//  DLCitizen
//
//  Created by GetGroup on 09/10/2024.
//  Copyright © 2024 Scytales. All rights reserved.
//

import Foundation

public struct NetworkError: Error, LocalizedError, Codable {
    let status: Int
    let title: String
    var localizedDescription: String {
        return title
    }
    init(status: Int, title: String) {
        self.status = status
        self.title = title
    }
}
