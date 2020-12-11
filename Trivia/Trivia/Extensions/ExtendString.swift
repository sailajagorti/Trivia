//
//  ExtendString.swift
//  Trivia
//
//  Created by Sailaja Gorti on 12/7/20.
//

import UIKit

extension String {
    public func replacingMultipleOccurrences<T: StringProtocol, U: StringProtocol>(using array: (of: T, with: U)...) -> String {
        var str = self
        for (a,b) in array {
            str = str.replacingOccurrences(of: a, with: b)
        }
        return str
    }
}


