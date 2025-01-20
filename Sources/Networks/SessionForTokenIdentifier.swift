//
//  File.swift
//  Networks
//
//  Created by GetGroup on 09/01/2025.
//

import Foundation
import Combine

@MainActor
public class SessionForTokenIdentifier {
    private var cancellable = Set<AnyCancellable>()
    public static let shared = SessionForTokenIdentifier()
    private let getTokenIdentifierRepo: GetTokenIdentifierNetworkingProtocol
    public let onLoading: CurrentValueSubject<Bool,Never> = .init(false)
    public let onSusscessGetTokenIdentifer: PassthroughSubject<String, Never> = .init()
    private var sessionDataKey: String? = nil
    public let onError: PassthroughSubject<String, Never> = .init()
    private init(getTokenIdentifierRepo: GetTokenIdentifierNetworkingProtocol = GetTokenIdentifierRepo()) {
        self.getTokenIdentifierRepo = getTokenIdentifierRepo
    }
    
    public func createAuthanticateAppSession(nationalId: String) {
        onLoading.send(true)
        getTokenIdentifierRepo.authanticateApplication { [weak self] value in
            self?.onLoading.send(false)
            switch value {
            case .success(let response):
                guard let sessionDataKey = response.sessionDataKey else { return }
                self?.validateUser(sessionDataKey: sessionDataKey, nationalId: nationalId)
            case .failure(let error):
                self?.onError.send(error.localizedDescription)
            }
        }
    }
    
    private func validateUser(sessionDataKey: String, nationalId: String) {
        onLoading.send(true)
        getTokenIdentifierRepo.validateUser(sessionDataKey: sessionDataKey, nationalId: nationalId) { [weak self] value in
            self?.onLoading.send(false)
            switch value {
            case .success(let response):
                self?.validatePassword(nationalId: nationalId)
            case .failure(let error):
                self?.onError.send(error.localizedDescription)
            }
        }
    }
    
    private func validatePassword(nationalId: String) {
        getTokenIdentifierRepo.validatePassword(nationalId: nationalId) { [weak self] value in
            self?.onLoading.send(false)
            switch value {
            case .success(let response):
                guard let sessionDataKey = response.sessionDataKey else { return }
                self?.sessionDataKey = sessionDataKey
            case .failure(let error):
                self?.onError.send(error.localizedDescription)
            }
        }
    }
    
    public func validateOtp(otp: String) {
        guard sessionDataKey != nil else { return }
        getTokenIdentifierRepo.validateOtp(sessionDataKey: sessionDataKey!, otp: otp) { [weak self] value in
            self?.onLoading.send(false)
            switch value {
            case .success(let response):
                guard let tokenIdentifier = response.tokenAcceso else { return }
                self?.onSusscessGetTokenIdentifer.send(tokenIdentifier)
            case .failure(let error):
                self?.onError.send(error.localizedDescription)
            }
        }
    }
}
