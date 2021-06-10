//
//  BaseApiEndpoints.swift
//  SharedService
//
//  Created by Luan Chiang on 3/21/19.
//  Copyright © 2019 Luan Chiang. All rights reserved.
//

import Foundation


public enum ApiRequestType: String{
    case POST = "POST"
    case GET = "GET"
    case DELETE = "DELETE"
    case PUT = "PUT"
}

public enum BaseEnumEndpoint: Int {
    case POST
    case DELETE
    case PUT
    case GET
    case GET_CARD_IMAGE
    
    public var urlPath: String {
        switch self {
        // this is tempoary usage for sub path
        case .GET_CARD_IMAGE:
            return ""
        default:
            return ""
        }
    }
    
    public var requestMethod: ApiRequestType {
        switch self {
        case .POST:
            return ApiRequestType.POST
        case .PUT:
            return ApiRequestType.PUT;
        case .DELETE:
            return ApiRequestType.DELETE;
        default:
            return ApiRequestType.GET
        }
    }
}

final public class BaseApiEndpoints {
    static let kBaseURL = "https://api.pexels.com/v1/search"
    
    /**
     urlWithEndpoint
     
     - Parameters:
        - endPoint: BaseEnumEndpoint
     
     - Returns: String
     */
    public static func urlWithEndpoint(_ endPoint:BaseEnumEndpoint) -> String {
        if (endPoint.urlPath .contains("http") || endPoint.urlPath .contains("https")) {
            return endPoint.urlPath
        }
        // add up sub path if applicable
        let endpointURL = endPoint.urlPath
        return kBaseURL+"/"+endpointURL
    }
}
