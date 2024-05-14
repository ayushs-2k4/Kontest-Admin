//
//  ErrorDomains.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import Foundation

struct ErrorInfo{
    let domain:String
    let code: Int
    let message: String?
}

enum ErrorDomains{
    static let adminNotInDatabase = ErrorInfo(domain: "AdminNotInDatabase", code: 1000, message: nil) 
}
