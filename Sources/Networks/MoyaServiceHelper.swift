//
//  MoyaServiceHelper.swift
//  DLCitizen
//
//  Created by GetGroup on 09/10/2024.
//  Copyright © 2024 Scytales. All rights reserved.
//

import Foundation
 import Moya
internal import Alamofire
// import MdlModels

class MoyaServiceProvider<T: TargetType> {
    let provider: MoyaProvider<T>
    init(type: ServiceType = .live) {
        let serviceType = type == .live ? MoyaProvider<T>.neverStub : MoyaProvider<T>.immediatelyStub
        let formatter = NetworkLoggerPlugin.Configuration.Formatter(responseData: { data in
            data.prettyPrinted as? String ?? "####"
        })
        let loggerCofig = NetworkLoggerPlugin.Configuration(formatter: formatter, logOptions: .verbose)
        let networkLogger = NetworkLoggerPlugin(configuration: loggerCofig)
        provider = MoyaProvider<T>(stubClosure: serviceType, plugins: [networkLogger])
    }
    
    deinit {
        print("deinit\(Self.self)")
    }
    
    func request<M: Codable>(target: T, completion: @escaping (Result<BaseResponse<M>, Error>)->Void) {
        defaultRequest(target: target) { (result: Result<BaseResponse<M>, Error>) in
            switch result {
            case .success(let response):
                if response.status == .fail {
                    let error = NetworkError(status: response.code ?? 0, title: response.message?.first ?? "")
                    completion(.failure(error))
                } else{
                    completion(.success(response))
                }
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    func defaultRequest<M: Codable>(target: T, completion: @escaping (Result<M, Error>)-> Void)  {
        guard  NetworkReachabilityManager()?.isReachable ?? false else {
            let error = NetworkError(status: 0, title: "NoInterNet")
            completion(.failure(error))
            return
        }
        print("🤩 Network Call: \(T.self), \(target.path)")
        provider.request(target) { result in
            switch result {
            case .success(let value):
                do {
                    let decoder = JSONDecoder()
                    
                    let response = try decoder.decode(M.self, from: value.data)
                    completion(.success(response))
                } catch (let decodeError){
                    let error = NetworkError(
                        status: 0,
                        title: "L10n.App.somethingwentwrongtryagainlater"
                    )
                                            print("🤯 Decoder Failure in \(T.self) for \(M.self) \nError: \(decodeError)")
                                            completion(.failure(error))
                }
            case .failure(let error):
                print("🤯 Network Call Failure For \(T.self) \nError: \(error)")
                
            }
        }
    }
    
    func stringRequest(target: T, completion: @escaping (Result<String, NetworkError>)-> Void)  {
        guard  NetworkReachabilityManager()?.isReachable ?? false else {
            let error = NetworkError(status: 0, title: "NoInterNet")
            completion(.failure(error))
            return
        }
        provider.request(target) { result in
            switch result {
            case.success(let value):
            
                    guard value.statusCode == 200 else {
                        do {
                            let decode = JSONDecoder()
                            let response = try decode.decode(NetworkError.self, from: value.data)
                            let error = NetworkError(
                                status: response.status,
                                title: response.title
                            )
                            completion(.failure(error))
                           
                        } catch {
                            print(error.localizedDescription)
                        }
                        return
                    }
                    let string = String(data: value.data, encoding: .utf8)
                    completion(.success(string ?? ""))
              
            case .failure(let error):
                print("🤯 Network Call Failure For \(T.self) \nError: \(error)")
            }
        }
//         var session : Alamofire.Session = {
//            Session(serverTrustManager: MyServerTrustManager(useCerts:false))
//        }()
//     
//        var req = URLRequest(url: URL(string: "https://idm.getgroup.com:7201/api/Citizen/CitizenGetToken")!)
//        req.httpMethod = HTTPMethod.post.rawValue
//        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        req.setValue(Bundle.versionString(), forHTTPHeaderField: "X-App-Version")
//        
//        req.httpBody = data
//        session.request(req).responseString { value in
//            switch value.result {
//            case .success(let response):
//                completion(.success(response))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
        print("🤩 Network Call: \(T.self), \(target.path)")
    }
    
//    func stringRequest(target: T,data: Data, completion: @escaping (Result<String, Error>)-> Void)  {
//        guard  NetworkReachabilityManager()?.isReachable ?? false else {
//            let error = NetworkError(code: 0, message: "NoInterNet")
//            completion(.failure(error))
//            return
//        }
//         var session : Alamofire.Session = {
//            Session(serverTrustManager: MyServerTrustManager(useCerts:false))
//        }()
//     
//        var req = URLRequest(url: URL(string: "https://idm.getgroup.com:7201/api/Citizen/CitizenGetToken")!)
//        req.httpMethod = HTTPMethod.post.rawValue
//        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        req.setValue(Bundle.versionString(), forHTTPHeaderField: "X-App-Version")
//        
//        req.httpBody = data
//        session.request(req).responseString { value in
//            switch value.result {
//            case .success(let response):
//                completion(.success(response))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//        print("🤩 Network Call: \(T.self), \(target.path)")
//    }
    
    private func handleFailure<R: Codable>(_ target: T,
                                               response: Response?,
                                               completion: @escaping (Swift.Result<R, Error>) -> Void) {
            if response?.statusCode == 401 {

                return
            } else {
                self.extractError(from: response?.data, completion: completion)
            }
        }

    private func extractError<R: Codable>(from response: Data?,
                                              completion: @escaping (Swift.Result<R, Error>) -> Void) {
            let resultJSON = response?.asDictionary ?? [:]
            
            if let message = resultJSON["title"] as? [String], !message.isEmpty {
                let error = NetworkError(status: 0, title: message.first!)
                completion(.failure(error))
                return
        }
        
        }
}


