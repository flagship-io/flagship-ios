//
//  FSError.swift
//  Flagship
//
//  Created by Adel on 29/09/2021.
//


internal struct FSError: Error {
    
    enum ErrorKind {
        case sendRequest
        case badRequest
        case mismatchedTag
        case internalError
        case notModified

    }

    let codeError: Int
    let kind: ErrorKind
}
