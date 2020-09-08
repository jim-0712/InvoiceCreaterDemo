//
//  StringExtension.swift
//  invoiceDemo
//
//  Created by Fu Jim on 2020/9/8.
//  Copyright © 2020 Fu Jim. All rights reserved.
//

import UIKit
import Foundation
enum ChineseRange {
    case notFound, contain, all
}

extension String {
    var findChineseCharacters: ChineseRange {
        guard let a = self.range(of: "\\p{Han}*\\p{Han}", options: .regularExpression) else {
            return .notFound
        }
        var result: ChineseRange
        switch a {
        case nil:
            result = .notFound
        case self.startIndex..<self.endIndex:
            result = .all
        default:
            result = .contain
        }
        return result
    }
}
