
//  DeviceEngagment.swift
//  DLCitizen
//
//  Created by GetGroup on 10/10/2024.
//  Copyright © 2024 Scytales. All rights reserved.


import Foundation
internal import MdlTransferHolder
import SwiftUI
internal import MdlModels
import Combine
internal import MdlTransfer

@MainActor
class DeviceEngagementPresentation {
    static let shared = DeviceEngagementPresentation()
    var mdlHolderViewModel: MDLHolderQrAllVM!
    @AppStorage(DefaultKeys.deSendTokenWhenRequested.rawValue) var deSendTokenWhenRequested: Bool?
    @AppStorage(DefaultKeys.enable_online_token.rawValue) var deEnableOnlineToken: Bool? // def.true
    @AppStorage(DefaultKeys.enable_offline_TOTP.rawValue) var deEnableOfflineTotp: Bool?
    let onError: PassthroughSubject<String, Never> = .init()
    let onSuccessGetImage: PassthroughSubject<UIImage, Never> = .init()
    let onSuccessGetQrValue: PassthroughSubject<String, Never> = .init()

    private init() { }
    
    func configureMDLHolderViewModel(
        _ shareType: ShareType,
        citizenToken: String
    ) {
        let loader = MDLCitizenClient.shared as MdlDataLoader
        let algorithm = UserDefaults.standard.integer(forKey: DefaultKeys.holderAlgorithm.rawValue)
        let deviceEngagment = DeviceEngagement(ofType: TransactionTypeEnum.qrWebApi, alg: 1)
        let webApiViewModel = MDLHolderQrWebApiVM(loader: loader, de: deviceEngagment)
        mdlHolderViewModel = MDLHolderQrAllVM(loader: loader, de: deviceEngagment, vmWebApi: webApiViewModel)
        mdlHolderViewModel.shareType = shareType
        mdlHolderViewModel.shareDocType = "org.iso.18013.5.1.mDL"

        if deSendTokenWhenRequested == nil || deEnableOnlineToken == nil || deEnableOfflineTotp == nil {
            mdlHolderViewModel.vmWebApi.citizenToken = citizenToken
        }
        do {
            try mdlHolderViewModel?.presentDeviceEngagement(shareType: shareType) {[weak self] image, error in
                guard image.size.width > 0 else {
                    Log.info(error?.localizedDescription ?? "")
                    self?.onError.send(error?.localizedDescription ?? "")
                    return
                }
                self?.onSuccessGetImage.send(image)
            }
        }
        catch let e {
            onError.send("MDLBaseClient.unexpectedStr")
        }
    }

}
