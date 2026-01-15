//
//  BoolExtension.swift
//  EuroScore
//
//  Created by Edward Bender on 1/14/26.
//

import Foundation

extension Bool {
    func toDouble() -> Double {
        if self {
            return 1.0
        }
        return 0
    }
    
    func toString() -> String {
        if self {
            return "True"
        }
        return "False"
    }
}

