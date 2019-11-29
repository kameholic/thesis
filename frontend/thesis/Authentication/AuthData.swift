//
//  AuthData.swift
//  thesis
//
//  Created by Mac on 2019. 11. 21..
//  Copyright © 2019. Mac. All rights reserved.
//

import Foundation
import JWTDecode

class AuthData {
    
    var accessToken: String
    static let shared = AuthData()
    
    func accessTokenIsValid() -> Bool
    {
        if accessToken == "" {
            return false
        }
        do {
            let jwt = try decode(jwt: accessToken)
            return !jwt.expired
        }
        catch {
            return false
        }
    }
    
    func getAccessToken() -> String
    {
        return accessToken
    }

    private init()
    {
        accessToken = ""
    }
}
