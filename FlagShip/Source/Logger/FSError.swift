//
//  FSError.swift
//  Flagship
//
//  Created by Adel on 29/09/2021.
//

enum ErrorType {
    case sendRequest
    case badRequest
    case internalError
    case notModified
    case sql
    case unknown
}

// Flagship Error
public class FlagshipError: Error {
    var message = ""
    var error: ErrorType
    let codeError: Int
    init(message: String = "", type: ErrorType = ErrorType.unknown, code: Int = 0) {
        self.message = message
        self.error = type
        self.codeError = code
    }
}
