//
//  SimiNetworkManager.swift
//  simitracking
//
//  Created by Hai Nguyen on 11/7/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//
import Alamofire
import UIKit

extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
}

class SimiNetworkManager: NSObject {
    
    var header:HTTPHeaders!
    var dataRequest:DataRequest!
    var _sharedInstance:SimiNetworkManager!
    
    public func sharedInstance()->SimiNetworkManager{
        if (_sharedInstance == nil) {
            _sharedInstance = SimiNetworkManager()
        }
        return _sharedInstance
    }
    
    func reachable()->Bool {
        //return NetworkReachabilityManager reachable
        return false
    }
    
    public func requestWithMethod(method: String, urlPath: String, parameters: Dictionary<String, Any>, target: NSObject, selector:Selector, header:Dictionary<String, String>) {
        let header = HTTPHeaders(dictionaryLiteral: ("Upgrade-Insecure-Requests","1"),
                                 ("Cache-Control","max-age=0"),
                                 ("Accept-Encoding","gzip"))
        
        var params: Parameters = [:]
        for (index, item) in parameters {
            params[index] = item
        }
        params["session_id"] = SimiGlobalVar.sessionId
        var requestMethod:HTTPMethod
        var requestedParamString = ""
        switch method {
            //get
            case "GET":
                requestMethod = .get
                break
            //post
            case "POST":
                requestMethod = .post
                requestedParamString = dictToJsonString(parameters: parameters)
                break
            //put
            case "PUT":
                requestedParamString = dictToJsonString(parameters: parameters)
                requestMethod = .put
                break
            //delete
            default: requestMethod = .delete
                break
        }
        
        if (requestedParamString != "") {
            Alamofire.request(urlPath, method: requestMethod, parameters: params, encoding: requestedParamString, headers: header)
                .response(
                    queue: nil,
                    responseSerializer: DataRequest.jsonResponseSerializer(),
                    completionHandler: {response in
                        print(response.result.value ?? "no value")
                        if let value = response.result.value as? [String: AnyObject] {
                            target.perform(selector, with: value)
                        }
                        else {
                            switch response.result {
                            case .failure(let error):
                                let result = ["errors":[["code":2,"message":error.localizedDescription]]]
                                target.perform(selector, with: result)
                            default:
                                return
                            }
                        }
                }
            )
        }
        else {
            Alamofire.request(urlPath, method: requestMethod, parameters: params, encoding: URLEncoding(destination: .methodDependent), headers: header)
                .response(
                    queue: nil,
                    responseSerializer: DataRequest.jsonResponseSerializer(),
                    completionHandler: {response in
                        print(response.result.value ?? "no value")
                        if let value = response.result.value as? [String: AnyObject] {
                            target.perform(selector, with: value)
                        }
                        else {
                            switch response.result {
                            case .failure(let error):
                                let result = ["errors":[["code":2,"message":error.localizedDescription]]]
                                target.perform(selector, with: result)
                            default:
                                return
                            }
                        }
                }
            )
        }
    }
    
    func dictToJsonString(parameters: Dictionary<String, Any>)->String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            return (NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as! String)
        } catch {
            return ""
        }
    }
}
