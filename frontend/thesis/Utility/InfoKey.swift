//
//  InfoKey.swift
//  thesis
//
//  Created by Mac on 2019. 11. 30..
//  Copyright © 2019. Mac. All rights reserved.
//

import Foundation

func infoForKey(key: String) -> String? {
    guard let object = Bundle.main.object(forInfoDictionaryKey:key) else {
        return ""
    }
    return (object as? String)?.replacingOccurrences(of: "\\", with: "")
}
