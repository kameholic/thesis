//
//  DataObject.swift
//  thesis
//
//  Created by Mac on 2019. 11. 30..
//  Copyright © 2019. Mac. All rights reserved.
//

import Foundation


class DataObject
{
    let name : String
    var children : [DataObject]
    
    init(name : String, children: [DataObject]) {
        self.name = name
        self.children = children
    }
    
    convenience init(name : String) {
        self.init(name: name, children: [DataObject]())
    }
    
    func addChild(_ child : DataObject) {
        self.children.append(child)
    }
    
    func removeChild(_ child : DataObject) {
        self.children = self.children.filter( {$0 !== child})
    }
}
