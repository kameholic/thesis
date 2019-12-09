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
    
    struct Recipe : Codable {
        let name: String
        let portion: Double
        let description: String
        
        public init(name: String, portion: Double, description: String) {
            self.name = name
            self.portion = portion
            self.description = description
        }
    }
    
    struct Diet : Codable {
        var days: [[String:[Recipe]]]
        
        public init() {
            days = [[String:[Recipe]]]()
        }
    }
    
    static let shared = UserData()
    
    var gender: String
    var age: Int
    var lifestyle: String
    var weight: Double
    var height: Double
    var allergies: [Allergy]
    var diet: Diet
    
    private init() {
        gender = ""
        age = 0
        lifestyle = ""
        weight = 0
        height = 0
        allergies = [Allergy]()
        diet = Diet()
    }
}
