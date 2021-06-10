//
//  BaseErrorType.swift
//  SharedService
//
//  Created by Luan Chiang on 3/20/19.
//  Copyright © 2019 Luan Chiang. All rights reserved.
//

import UIKit

@objc public enum EnumBaseErrorType : Int {
    case GENERIC
    case UNDEFINED
    case CANCELLED
    case INTERNET_LOST
    case FORBIDDEN
    case USER_NOT_LOGGED_IN
    case NETWORK_PROBLEM
}

struct BaseErrorType {
    private static let kCodeUnauthorized: Int = 401
    private static let kCodeForbidden: Int = 403
    private static let kCodeNotFound: Int = 404
    private static let kCodeInternalServerError: Int = 500
    private static let kCodeBadGateway: Int = 502
    private static let kApiGeneric = "error.generic"
    
    
    /// typewithApiCode
    ///
    /// - Parameter apiErrorCode: String?
    /// - Returns: EnumBaseErrorType
    static func type(withApiCode apiErrorCode: String?) -> EnumBaseErrorType {
        print("apiErrorCode %@", apiErrorCode ?? "")
        guard let apiErrorCode = apiErrorCode else {
            return EnumBaseErrorType.GENERIC
        }
        
        if (apiErrorCode == kApiGeneric) {
            return EnumBaseErrorType.GENERIC
        }
        
        return EnumBaseErrorType.GENERIC
    }
    
    /// typewithCode
    ///
    /// - Parameter code: code
    /// - Returns: EnumBaseErrorType
    static func type(withCode code: Int) -> EnumBaseErrorType {
        switch code {
        case NSURLErrorCannotFindHost, NSURLErrorDNSLookupFailed, NSURLErrorCannotConnectToHost, NSURLErrorUnsupportedURL:
            return EnumBaseErrorType.NETWORK_PROBLEM
        case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
            return EnumBaseErrorType.INTERNET_LOST
        case NSURLErrorCancelled:
            return EnumBaseErrorType.CANCELLED
        case kCodeForbidden:
            return EnumBaseErrorType.FORBIDDEN
        default:
            print(String(format: "Error Code: %ld not handled correctly", code))
            return EnumBaseErrorType.GENERIC
        }
    }
    
    /// titlefrom
    ///
    /// - Parameter type: type
    /// - Returns: String
    static func title(from type: EnumBaseErrorType) -> String {
        switch type {
        case .GENERIC:
            return NSLocalizedString("Internet Connection Problem", comment: "")
        default:
            return ""
        }
    }
    
    
    /// informationfrom
    ///
    /// - Parameter type: EnumBaseErrorType
    /// - Returns: String
    static func information(from type: EnumBaseErrorType) -> String {
        switch type {
        case .USER_NOT_LOGGED_IN:
            return NSLocalizedString("User is not logged in", comment: "")
        case .NETWORK_PROBLEM:
            return NSLocalizedString("There is a problem with the network", comment: "")
        
        case .GENERIC:
            return NSLocalizedString("Generic Api Error", comment: "")
//        case .SERVER_INTERNAL:
//            return NSLocalizedString("Server Internal Error", comment: "")
//        case .BAD_GATEWAY:
//            return NSLocalizedString("Bad Gateway", comment: "")
        default:
            return ""
        }
    }
    
}
