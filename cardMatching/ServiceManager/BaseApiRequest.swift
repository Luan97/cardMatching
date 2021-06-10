//
//  BaseApiRequest.swift
//  SharedService
//
//  Created by Luan Chiang on 3/20/19.
//  Copyright © 2019 Luan Chiang. All rights reserved.
//

import Foundation

@objcMembers
public class BaseApiRequest {
    private static let kContentType = "Content-Type"
    private static let kApplicationJson = "application/json"
    private static let kContentLength = "Content-Length";
    private static let kAcceptEncoding = "Accept-Encoding"
    private static let kAccept = "Accept"
    private static let kGZip = "gzip";
    
    // Pexels specific
    private static let kTokenKey = "Authorization"
    private static let kToken = "563492ad6f917000010000017241767ea46b454390ac44fb6c7cdfd6"
    
    /**
     prepareCookieHeader
     
     - Returns: [String: String] */
    private class func prepareCookieHeader() -> [String: String] {
        //guard let dict = CookieManager.sharedInstance.retrieveCookies() as? [String: String] else {
            return [String: String]()
        //}
        // prepare cookie header
        //return dict
    }
    
    /**
     processCommonRequest
     
     - Parameters:
        - url: URL
     - Returns: URLRequest */
    private static func processCommonRequest(url:URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = prepareCookieHeader()
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        request.setValue(BaseApiRequest.kApplicationJson, forHTTPHeaderField: BaseApiRequest.kContentType)
        
        //Pexels specific
        request.setValue(kToken, forHTTPHeaderField: kTokenKey)
        return request
    }
    
    /**
     prepareHttpBody

     - Parameters:
        - arguments: post body arguments
     - Returns: Data? */
    private static func prepareHttpBody(_ arguments:[String: AnyObject]?) -> Data? {
        guard let postData = try? JSONSerialization.data(withJSONObject: arguments as Any, options: []) else {
            return nil
        }
        return postData
    }
    
    /**
     processGetArguments
     
     - Parameters:
        - url: URL
        - arguments: [String: AnyObject]?
     - Returns: URL!
     */
    private static func processGetArguments(url:URL, arguments:[String: AnyObject]?) -> URL! {
        var comp = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if (arguments != nil){
            comp!.queryItems = arguments!.map { item in
                URLQueryItem(name: item.key, value: String(describing: item.value))
            }
        }
        return comp!.url
    }
    
    /**
     composeRequest
     
     - Parameters:
        - type: ApiRequestType
        - url: URL!
        - arguments: [String: AnyObject]?
     - Returns: URLRequest
     */
    public static func composeRequest(type:ApiRequestType, url:URL, arguments:[String: AnyObject]?) -> URLRequest {
        let url = type == ApiRequestType.GET ? processGetArguments(url:url, arguments: arguments): url
        var request = processCommonRequest(url: url!)
        request.httpMethod = type.rawValue
        request.timeoutInterval = 60
        if let arguments = arguments {
            if (type != ApiRequestType.GET) {
                if let postBody = prepareHttpBody(arguments) {
                    let postBodyLength = String(postBody.count)
                    request.httpBody = postBody
                    request.setValue(postBodyLength, forHTTPHeaderField: BaseApiRequest.kContentLength)
                }
            }
        }
        
        return request
    }
}
