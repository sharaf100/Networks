//
//  OnlineSharing.swift
//  DLCitizen
//
//  Created by GetGroup on 09/10/2024.
//  Copyright © 2024 Scytales. All rights reserved.
//



internal import MdlModels
internal import CBORSwift
import Foundation
internal import MdlSecurity
import MdlIntroduction
internal import MdlTransfer
internal import Alamofire
internal import MdlTransferHolder
import Combine
internal import  BuildEnvironment
import KeychainAccess

@MainActor
public class OnlineSharing {
    private var cancellable = Set<AnyCancellable>()
    public static let shared = OnlineSharing()
    let deviceEngagment = DeviceEngagementPresentation.shared
    private var sbl: SettingsBusLogic?
    private let citizienRepo: GetTokenCitizenNetworkingProtocol
    public let citizenToken: PassthroughSubject<String, Never> = .init()
    public let onError: PassthroughSubject<String, Never> = .init()
    public let onSuccessGetQrImage: PassthroughSubject<UIImage, Never> = .init()

    private let onErrorMessageShowAlert: PassthroughSubject<NetworkError, Never> = .init()
    public let onLoading: CurrentValueSubject<Bool,Never> = .init(false)
    private init(citizienRepo: GetTokenCitizenNetworkingProtocol = GetTokenRepo()) {
        self.citizienRepo = citizienRepo
        setupObservers()
#if os(iOS)
        if let appDel = UIApplication.shared.delegate as? MdlAppDelegate {
            self.sbl = appDel.container.resolve(SettingsBusLogic.self)!
        } else {
            self.sbl = UserDefaultsSettingsInteractor.shared
        }
#else
        self.sbl = UserDefaultsSettingsInteractor.shared
#endif
    }
    
    public func getQrImage(
        privateKey: NSDictionary,
        customerId: String,
        dcoumentDiscrmentor: String,
        totpCode: String?,
        shareType: Int,
        updatedDataNeeded: Bool?,
        document: String) {
        onLoading.send(true)
//        let keyDictionary = Helpers.getDevicePrivateKeyObject()
        let res = SignUpResponse(data: document, totp: totpCode)
        MDLCitizenClient.shared.totpSecretKey = res.totpSecretKey
        do {
            let pair = try res.extractLicenceDto()
            MDLCitizenClient.shared.licenseDto = pair.licenceDto
            MDLCitizenClient.shared.mdlResp = pair.mDLResponse
            let xKey = privateKey[-2]
            let yKey = privateKey[-3]
            let dKey = privateKey[-4]
            let dict = [
                -1:1 as NSNumber,
                 -2: xKey,
                 -3: yKey,
                 -4: dKey,
                 1: 2 as NSNumber
            ] as NSDictionary
            let privateKey = CoseKey(decoded: dict)!
            let signedData = buildGetTokenBody(
                privKey: privateKey,
                customerId: customerId,
                dD: dcoumentDiscrmentor,
                totpCode: totpCode,
                shareType: ShareType(rawValue: shareType)!,
                getBitMask: MDLCitizenClient.shared.licenseDto.getShareShopesBitMask,
                updatedDataNeeded: updatedDataNeeded
            )
            citizienRepo.getTokenCitizen(signedData: signedData) { [weak self] value in
                self?.onLoading.send(false)
                switch value {
                case .success(let response):
                    self?.citizenToken.send(response)
                    self?.deviceEngagment.configureMDLHolderViewModel(ShareType(rawValue: shareType) ?? .shareAge,  citizenToken: response)
                case .failure(let error):
                    self?.onError.send(BEConfig.environmentGlobal != .staging ? error.localizedDescription : "")
                    self?.onErrorMessageShowAlert.send(error)
                    print(error.localizedDescription)
                    //Log.error("API Share \(shareType) error code: \(error.status) error description: \(error.localizedDescription)")
                }
            }
        } catch {
            onError.send(error.localizedDescription)
        }
    }
    
    public func setKeys(data: Data) {
        UserDefault.shared.setKeys(keys: data)
    }
    
    public func setKeys(dictionary: NSDictionary) {
      //  UserDefault.shared.setKeys(dictionary: dictionary)
    }
    
    public func loadKeys()-> NSDictionary? {
        return Helpers.getDevicePrivateKeyObject()
    }
    
    public func removeKeys() {
        let keychain = Keychain()
        do {
            try keychain.remove("signupKeys")
        } catch let error {
            print("Error\(error.localizedDescription)")
        }
    }
    
    public func shareQRViewBluetooth( privateKey: NSDictionary,
                                      customerId: String,
                                      dcoumentDiscrmentor: String,
                                      totpCode: String?,
                                      shareType: Int,
                                      updatedDataNeeded: Bool?,
                                      document: String
    ) {
        do {
            let shareType = ShareType.shareAll
            let shareDocType = "org.iso.18013.5.1.mDL"
            
            let res = SignUpResponse(data: document, totp: totpCode)
            MDLCitizenClient.shared.totpSecretKey = res.totpSecretKey
            let pair = try res.extractLicenceDto()
//            let adminstrativeNumber = pair.licenceDto.
            MDLCitizenClient.shared.licenseDto = pair.licenceDto
            MDLCitizenClient.shared.mdlResp = pair.mDLResponse
            
            let xKey = privateKey[-2]
            let yKey = privateKey[-3]
            let dKey = privateKey[-4]
            let dict = [
                -1:1 as NSNumber,
                 -2: xKey,
                 -3: yKey,
                 -4: dKey,
                 1: 2 as NSNumber
            ] as NSDictionary
            let privKey = CoseKey(decoded: dict)!
            
            var citizenToken = MDLCitizenClient.shared.getCustomerIdToken(
                privKey: privKey,
                customerId: customerId,
                dD: dcoumentDiscrmentor,
                totpCode: nil,
                shareType: shareType,
                getBitMask: MDLCitizenClient.shared.licenseDto.getShareShopesBitMask,
                forceUpdate: nil
            )
            self.citizenToken.send(citizenToken)
            MDLHolderQrAllVM.shared.shareType = shareType
            MDLHolderQrAllVM.shared.shareDocType = shareDocType
            deviceEngagment.configureMDLHolderViewModel(shareType, citizenToken: citizenToken)
           
            
        }
        catch  let e {
            onError.send(e.localizedDescription)
        }
    }
    

    private func setupObservers() {
        deviceEngagment.onError.sink { [weak self] value in
            self?.onError.send(value)
        }
        .store(in: &cancellable)
        deviceEngagment.onSuccessGetImage.sink { [weak self] image in
            self?.onSuccessGetQrImage.send(image)
        }
        .store(in: &cancellable)
    }
    
    private func buildGetTokenBody(
        privKey: CoseKey,
        customerId: String,
        dD: String,
        totpCode: String?,
        shareType: ShareType,
        getBitMask: ([String:[String]]) -> [NSByteString]?,
        updatedDataNeeded: Bool?
    ) -> String {
        
        var data = Data()
        if(updatedDataNeeded == nil ) {
            data = buildData(
                customerId: customerId,
                dD: dD,
                totpCode: totpCode,
                shareType: shareType,
                getBitMask: getBitMask
            )
        } else {
            data = buildUpdatedData(
                customerId: customerId,
                dD: dD,
                forceUpdate: updatedDataNeeded
            )
        }
        let signString  = signData(privKey: privKey, data: data)
        return signString
        
    }
    
    private func buildData(
        customerId: String,
        dD: String,
        totpCode: String?,
        shareType: ShareType,
        getBitMask: ([String:[String]]) -> [NSByteString]?
    ) -> Data{
        var data: Data
        let dict = NSMutableDictionary()
        let namespaces = getShareNameSpaces(sbl: sbl!, sharingType: shareType)
        dict[IdentityResult.CodingKeys.namespaces.stringValue] = namespaces as NSObject
        let bitmaskArray = getBitMask(namespaces)!
        var cborArr = [customerId as NSObject, dD as NSObject, bitmaskArray as NSObject]
        if let tc = totpCode {
            cborArr.append(tc as NSObject)
        }
        data = CBOR.encode(cborArr as NSArray)!.data!
        return data
    }
    
    private func buildUpdatedData(
        customerId: String,
        dD: String,
        forceUpdate: Bool?
    ) -> Data{
        var data: Data
        let dict = NSMutableDictionary()
        if forceUpdate == true {
            dict["force"] = 1 as NSObject
        }
        dict["customer_id"] = customerId as NSObject
        dict["document_discriminator"] = dD as NSObject
        data = CBOR.encode(dict as NSDictionary)!.data!
        return data
    }
    
    private func signData(privKey: CoseKey, data: Data) -> String {
        let va = VerifyAlgorithmType.fromCurveAlg(alg: privKey.alg)
        let arr = NSMutableArray(
            array: [
                va.coseProtectedMapValue,
                NSDictionary(),
                NSByteString(bytes: data.arr),
                NSByteString("")
            ]
        )
        let sign1Value = privKey.computeCoseSign1(arr, onlyValue: true)
        arr[3] = NSByteString(bytes:sign1Value.arr)
        let resData = CBOR.encode(NSTag(tag: 18, arr))!.data!
        Log.info(resData.toHexString());
        return "\"\(resData.base64urlEncodedString())\""
    }
    
    private func getShareNameSpaces(sbl: SettingsBusLogic, sharingType: ShareType) -> [String: [String]] {
        if sharingType == .shareOther {
            getShareNamespacesItemsForSharingOther(sbl: sbl)
        } else {
            getShareNamespacedItems(shareType: sharingType)
        }
    }
    
    private  func getShareNamespacesItemsForSharingOther(sbl: SettingsBusLogic) -> [String: [String]] {
        var namespaces: [String: [String]]
        _ = sbl.configureSettingsReader(response: nil)
        namespaces = [
            MdlResponse.IsoNamespace: Array(sbl.getCustomFilterKeys(response: nil, for: MdlResponse.IsoNamespace))]
        namespaces[MdlResponse.ScytalesNamespace] = Array(sbl.getCustomFilterKeys(response: nil, for: MdlResponse.ScytalesNamespace))
        namespaces[MdlResponse.AamvaIsoNamespace] = Array(sbl.getCustomFilterKeys(response: nil, for: MdlResponse.AamvaIsoNamespace))
        namespaces[MdlResponse.AamvaNamespace] = Array(sbl.getCustomFilterKeys(response: nil, for: MdlResponse.AamvaNamespace))
        if IdentityResult.NameSpaces.CodingKeys.orgCustom.stringValue.count > 0 {
            namespaces[MdlResponse.CustomNamespace] = Array(sbl.getCustomFilterKeys(response: nil, for: MdlResponse.CustomNamespace))
        }
        return namespaces
    }
    
    private func getShareNamespacedItems(shareType: ShareType) -> [String: [String]] {
        var namespaces: [String: [String]]
        namespaces = [
            MdlResponse.IsoNamespace: IdentityResult.OrgIso.getShareKeys(for: shareType).map {$0.stringValue},
            IdentityResult.NameSpaces.CodingKeys.comAamvaIso.stringValue: IdentityResult.ComAamvaIso.getScopes(for: shareType),
            IdentityResult.NameSpaces.CodingKeys.comAamva.stringValue: IdentityResult.ComAamva.getScopes(for: shareType),
            IdentityResult.NameSpaces.CodingKeys.comScytales.stringValue: IdentityResult.ComScytales.getScopes(for: shareType)
        ]
        if IdentityResult.hasCustomNamespace {
            namespaces[IdentityResult.NameSpaces.CodingKeys.orgCustom.stringValue] = IdentityResult.OrgCustom.getScopes(for: shareType)
        }
        return namespaces
    }
}
