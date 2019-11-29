//
//  UserData.swift
//  thesis
//
//  Created by Mac on 2019. 11. 24..
//  Copyright © 2019. Mac. All rights reserved.
//

import Foundation

class UserData {
    
    struct Allergy : Codable {
        let id: Int
        let name: String
        var checked: Bool
        
        public init(id: Int, name: String, checked: Bool = false) {
            self.id = id
            self.name = name
            self.checked = checked
        }
    }
    
    static let shared = UserData()
    
    var gender: String
    var age: Int
    var lifestyle: String
    var weight: Double
    var allergies: [Allergy]
    
    private init()
    {
        gender = ""
        age = 0
        lifestyle = ""
        weight = 0
        allergies = [Allergy]()
    }
}
