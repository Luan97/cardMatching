//
//  BaseError.swift
//  SharedService
//
//  Created by Luan Chiang on 3/20/19.
//  Copyright © 2019 Luan Chiang. All rights reserved.
//

import UIKit

@objcMembers
public class BaseError: NSObject {
    public var type: EnumBaseErrorType
    public var errorInformation: String?
    public var errorMessage: String?
    public var errorCode: Int = 0
    public var errorCodeString: String?
    public var informationDictionary: [AnyHashable: Any]?
    
    public convenience override init() {
        self.init(type: .GENERIC)
    }
    
    public init(type: EnumBaseErrorType) {
        self.type = type
    }
    
    // MARK: Public Methods
    
    /// information
    ///
    /// - Returns: String?
    @objc public func information() -> String? {
        guard let errorInformation = errorInformation else {
            return BaseErrorType.information(from: type)
        }
        return errorInformation
    }
    
    /// errorTitle
    ///
    /// - Returns: String?
    @objc public func errorTitle() -> String? {
        return BaseErrorType.title(from: type)
    }
    
    /// description
    ///
    /// - Returns: String?
    @objc public func errorDescription() -> String? {
        return "Error Type: \(BaseErrorType.information(from: type))"
    }
    
    /// getCustomDimensionMessage
    ///
    /// - Returns: String?
    @objc public func getCustomDimensionMessage() -> String! {
        let message = information() ?? errorMessage ?? errorDescription() ?? ""
        return String(format: "error code: %ld/error message: %@", errorCode , message)
    }
    
    /// errorwith
    ///
    /// - Parameter type: EnumBaseErrorType
    /// - Returns: BaseError
    public class func error(with type: EnumBaseErrorType) -> BaseError {
        return BaseError(type: type)
    }
    
    /// errorwithCode
    ///
    /// - Parameter code: Int
    /// - Returns: BaseError?
    public class func error(withCode code: Int) -> BaseError? {
        let errorType = BaseErrorType.type(withCode: code)
        let error = BaseError.error(with: errorType)
        
        error.errorCode = code
        // Default message can be overridden
        error.errorMessage = "Server returned error with code: \(String(describing: error.errorCode))"
        return error
    }
    
    /// errorwithApiErrorCode
    ///
    /// - Parameter apiErrorCode: String
    /// - Returns: BaseError
    public class func error(withApiErrorCode apiErrorCode: String) -> BaseError {
        let errorType = BaseErrorType.type(withApiCode: apiErrorCode)
        let error = BaseError.error(with: errorType)
        return error
    }

    public func getErrorCode()->Int{
        return errorCode 
    }
}
