//
//  File.swift
//  Networks
//
//  Created by GetGroup on 23/10/2024.
//

import Foundation
import UIKit
internal import CBORSwift
import SwiftCBOR
import DeviceGuru
internal import MdlModels
internal import MdlSecurity
import Combine
internal import MdlTransferHolder
internal import Alamofire

final public class CreateSessionHandler {
   
    
    private let repo: CreateSessionNetworkingProtocol
    public static var shared: CreateSessionHandler {
        CreateSessionHandler()
    }
    public let onSuccess: PassthroughSubject<SessionResponse, Never> = .init()
    public let onError: PassthroughSubject< String, Never> = .init()
    private init(repo: CreateSessionNetworkingProtocol = CreateSessionRepo()) {
        self.repo = repo
    }
    
    @MainActor
    public func createSession(with nationalId: String, tokenIdentifier: String,  coseKeyDictionary: NSDictionary) {
        let devGuru = DeviceGuruImplementation()
        let model = devGuru.hardwareString
        let hardware = (try? devGuru.hardwareSimpleDescription()) ?? ""
        var dictStr = [
            "os": "iOS",
            "os_sdk": "17.3",
            "manufacturer":"Apple",
            "model": model,
            "hardware": hardware,
            "locale":(Locale.current.regionCode ?? ""),
            "language": (Locale.current.languageCode ?? ""),
            "national_id": nationalId,
            "token_identifier": tokenIdentifier
        ]
#if os(iOS)
        dictStr["os_version"] = UIDevice.current.systemVersion
#endif
        let dictBytes = SwiftCBOR.CBOR.encodeMap(dictStr)
        //let coseKey = CoseKey(isEphemeralPrivate: true, alg: 1)
        let coseKey = CoseKey(x: coseKeyDictionary[-2] as! String, y: coseKeyDictionary[-3] as! String, d: coseKeyDictionary[-4] as! String)
        let arr = [NSByteString(bytes: coseKey.cosePublicData.arr), NSByteString(bytes: dictBytes)]
        print(coseKey.publicKey.cosePublicData.base64EncodedString())

        let data =  prepareCreateSessionRequest(object: arr as NSObject, privateKey: coseKey)
        print("Body: \(data)")
        repo.createUserSession(signedData: data) {[weak self]  value in
            switch value {
            case .success(let result):
                //print("succeess Created session\(result)")
                //self?.delegate.didsessionCreated(result: result)
                self?.onSuccess.send(result)
            case .failure(let error):
                print("Error From Backend \( error)")
              //  self?.delegate.didSendError(error: error.localizedDescription)
            self?.onError.send(error.localizedDescription)
            }
        }
    }
    
    
    private func prepareCreateSessionRequest(object: NSObject, privateKey: CoseKey)-> String {
        let resultData = MDLCitizenClient.shared.encodeSignedCborObject(object, with: privateKey)
        //        if urlLast == .mobileNumber { Log.info("CBOR request for \(urlLast): \(resData.hexString)\n Key: \(privKey.publicKeyDescription)")}
        let signedCborObject = "\"" + resultData.base64EncodedString() + "\""
        return signedCborObject
        // req.httpBody = str.data(using: .utf8)!
    }
    
//    @MainActor public func createSession() -> AnyPublisher<String, Error> {
//        let devGuru = DeviceGuruImplementation()
//        let model = devGuru.hardwareString
//        let hardware = (try? devGuru.hardwareSimpleDescription()) ?? ""
//        var dictStr = ["os": "iOS", "os_sdk": "17.3", "manufacturer":"Apple", "model": model, "hardware": hardware, "locale":(Locale.current.regionCode ?? ""), "language": (Locale.current.languageCode ?? "")]
//#if os(iOS)
//        dictStr["os_version"] = UIDevice.current.systemVersion
//#endif
//        let dictBytes = SwiftCBOR.CBOR.encodeMap(dictStr)
//        let priKey = CoseKey(isEphemeralPrivate: true, alg: 1)
//        let privKey = CoseKey(decoded: Helpers.getDevicePrivateKeyObject())!
//        let arr = [NSByteString(bytes: privKey.cosePublicData.arr), NSByteString(bytes: dictBytes)]
//        
//
//        print(privKey.publicKey.cosePublicData.base64EncodedString())
//        
//        let resData = encodeSignedCborObject(obj, with: privKey)
//
//        let str = "\"" + resData.base64EncodedString() + "\""
//        rep
//    }
    
//    func createSignupStepFuture(_ obj:NSObject) -> Future<String, Error> {
//        Future { promise in self.callSignupStep(obj) { (result, err) in
//            if let err = err {
//                promise(.failure(err))
//            }
//            else {
////                if urlLast == .cancelSession || urlLast == .sessionFinish { self.signupJwt = nil; self.signupExp = nil  }
////                if urlLast != .sessionFinish { Log.info("Signup step \(urlLast) result: \(result ?? "")")}
//                promise(.success(result ?? "")) }
//        } // end callback
//        }
//    }
    
//    public func callSignupStep(_ obj:NSObject, callback: @escaping(String?, Error?) -> Void) -> Void {
//        let req = prepareSignupStepRequest(obj)
//        callSignupSteps(req: req, callback: callback)
//    }
    
    func prepareSignupStepRequest(_ obj: NSObject) -> URLRequest {
        let privKey = CoseKey(decoded: Helpers.getDevicePrivateKeyObject())!
        let url: String = "https://idm.getgroup.com:7201/api/Citizen/SignUp/CreateSession"
        var req = URLRequest(url: URL(string: url)!)
        req.httpMethod = HTTPMethod.post.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(Bundle.versionString(), forHTTPHeaderField: "X-App-Version")
        if req.httpMethod == HTTPMethod.post.rawValue {
            let resData = encodeSignedCborObject(obj, with: privKey)
   
            let str = "\"" + resData.base64EncodedString() + "\""
            
            
            print("------------ request -----------------")
            print("\(req)")
            print("-----------------------------------")
            
            
            print("------------ body -----------------")
            print("\(str)")
            print("-----------------------------------")
            req.httpBody = str.data(using: .utf8)!
        }
        
        return req
    }
    
    
//    func callSignupSteps(req: URLRequest, callback: @escaping(String?, Error?) -> Void) -> Void {
//            callback(nil, NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("signup_network_not_available", comment: "")]))
//            
//       
//        Self.ApiManager.request(req).uploadProgress(closure: { [unowned self] p in self.progress = p.fractionCompleted}).responseString(completionHandler: {
//            [unowned self] in apiRεquestHandler($0, callback)
//        })
//    }
    
    public var progress: Double = 0

     func encodeSignedCborObject(_ obj: NSObject, with privKey: CoseKey) -> Data {
            let content = CBOR.encode(obj)!
            let va = VerifyAlgorithmType.fromCurveAlg(alg: privKey.alg)
            let arr = NSMutableArray(array: [va.coseProtectedMapValue, NSDictionary(), NSByteString(bytes: content), NSByteString("")])
            let sign1Value = privKey.computeCoseSign1(arr, onlyValue: true)
            arr[3] = NSByteString(bytes:sign1Value.arr)
            let resData = CBOR.encode(NSTag(tag: 18, arr))!.data!
            return resData
        }
    
    func apiRεquestHandler(_ res: AFDataResponse<String>, _ callback: @escaping(String?, Error?) -> Void) {
        print("code \(res.response?.statusCode):  response \(res)")
        switch res.result {
        case .success where (res.response?.statusCode ?? 500) <= 204:
            callback(res.value, nil) //happy path
        case .success:
            let json = res.value ?? ""
            let error = Self.parseError(from: json) as NSError
            callback(nil, error)
        case .failure(let error):
            callback(nil, error) // NSError(domain: "DLCitizen", code: res.response?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey:error.localizedDescription]))
        }
    }
    
    public static func parseError(from json: String) -> Error {
        let errorModel = try? JSONDecoder().decode(ErrorResult.self, from: json.data(using: .utf8)!)
        var errStr = errorModel?.error ?? errorModel?.title
        if errStr == nil, let d = json.data(using: .utf8) {
            let json1 = try? JSONSerialization.jsonObject(with: d, options: .allowFragments) as? [String: [String]]
            let json2 = try? JSONSerialization.jsonObject(with: d, options: .allowFragments) as? [String: String]
            if json1 != nil {errStr = json1?[json1?.keys.first ?? ""]?[0]} else { errStr = json2?[json2?.keys.first ?? ""]}
        }
        let statusCode: Int = errorModel?.status ?? 400
       // if (errStr?.count ?? 0) == 0 { errStr = "\(Self.unexpectedStr) (\(statusCode))" }
        return NSError(domain: "WebApi", code: statusCode, userInfo: [NSLocalizedDescriptionKey:errStr!])
    }
}
